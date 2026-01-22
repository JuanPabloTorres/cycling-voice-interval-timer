import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_tts/flutter_tts.dart';

/// Represents an available TTS voice.
class TtsVoice {
  final String name;
  final String locale;
  final String displayName;

  const TtsVoice({
    required this.name,
    required this.locale,
    required this.displayName,
  });

  @override
  String toString() => displayName;
}

/// Service for Text-to-Speech functionality.
/// 
/// Provides voice announcements in English for timer events.
/// Designed for reliable foreground operation with serialized speech.
class TtsService {
  FlutterTts? _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;
  
  // Available voices
  List<TtsVoice> _availableVoices = [];
  TtsVoice? _selectedVoice;
  
  // Voice settings - optimized for clarity during cycling
  double _volume = 1.0;
  double _speechRate = 0.45;  // Slower for better clarity
  double _pitch = 1.0;

  /// Available English voices on this device.
  List<TtsVoice> get availableVoices => List.unmodifiable(_availableVoices);
  
  /// Currently selected voice.
  TtsVoice? get selectedVoice => _selectedVoice;

  /// Current volume (0.0 to 1.0).
  double get volume => _volume;
  
  /// Current speech rate.
  double get speechRate => _speechRate;
  
  /// Current pitch.
  double get pitch => _pitch;

  /// Initializes the TTS engine with Spanish language.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _flutterTts = FlutterTts();
      
      // Load available Spanish voices
      await _loadAvailableVoices();
      
      // Set language to English
      await _flutterTts!.setLanguage('en-US');
      
      // If we have a preferred voice, use it
      if (_selectedVoice != null) {
        await _flutterTts!.setVoice({
          'name': _selectedVoice!.name,
          'locale': _selectedVoice!.locale,
        });
      }
      
      // Configure voice parameters - optimized for cycling
      await _flutterTts!.setVolume(_volume);
      await _flutterTts!.setSpeechRate(_speechRate);
      await _flutterTts!.setPitch(_pitch);
      
      // Platform-specific configuration
      if (!kIsWeb) {
        // iOS: Enable background audio
        await _flutterTts!.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.voicePrompt,
        );

        // Android: Wait for speech completion (serialization)
        await _flutterTts!.awaitSpeakCompletion(true);
      }
      
      // Set up handlers for speech serialization
      _flutterTts!.setStartHandler(() {
        _isSpeaking = true;
      });
      
      _flutterTts!.setCompletionHandler(() {
        _isSpeaking = false;
      });
      
      _flutterTts!.setErrorHandler((error) {
        _isSpeaking = false;
        print('[TtsService] Error: $error');
      });
      
      _isInitialized = true;
      print('[TtsService] Initialized with ${_availableVoices.length} English voices');
    } catch (e) {
      print('[TtsService] Initialization error: $e');
      _isInitialized = true;
    }
  }

  /// Loads available Spanish voices from the system.
  Future<void> _loadAvailableVoices() async {
    try {
      final voices = await _flutterTts!.getVoices;
      
      if (voices != null) {
        _availableVoices = (voices as List)
            .where((voice) {
              final locale = voice['locale']?.toString().toLowerCase() ?? '';
              return locale.startsWith('en');
            })
            .map((voice) {
              final name = voice['name']?.toString() ?? 'Unknown';
              final locale = voice['locale']?.toString() ?? 'es-ES';
              
              // Create a friendly display name
              String displayName = name;
              if (name.contains('Microsoft')) {
                // Extract Microsoft voice name (e.g., "Microsoft Helena" -> "Helena")
                final match = RegExp(r'Microsoft\s+(\w+)').firstMatch(name);
                if (match != null) {
                  displayName = '${match.group(1)} (Microsoft)';
                }
              } else if (name.contains('Google')) {
                displayName = name.replaceAll('Google', '').trim() + ' (Google)';
              } else {
                // Shorten long names
                if (name.length > 30) {
                  displayName = '${name.substring(0, 27)}...';
                }
              }
              
              return TtsVoice(
                name: name,
                locale: locale,
                displayName: displayName,
              );
            })
            .toList();
        
        // Sort by display name
        _availableVoices.sort((a, b) => a.displayName.compareTo(b.displayName));
        
        print('[TtsService] Found ${_availableVoices.length} English voices');
      }
    } catch (e) {
      print('[TtsService] Error loading voices: $e');
    }
  }

  /// Sets the voice to use for TTS.
  Future<void> setVoice(TtsVoice voice) async {
    _selectedVoice = voice;
    
    if (_flutterTts != null) {
      await _flutterTts!.setVoice({
        'name': voice.name,
        'locale': voice.locale,
      });
      print('[TtsService] Voice set to: ${voice.displayName}');
    }
  }

  /// Speaks the given message.
  /// Waits for completion to ensure serialized speech (no overlap).
  Future<void> speak(String message) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (message.trim().isEmpty) return;
    if (_flutterTts == null) return;

    try {
      // Process message for natural pauses
      final processedMessage = _processForFluency(message);
      
      await _flutterTts!.speak(processedMessage);
      print('[TtsService] Speaking: "$processedMessage"');
    } catch (e) {
      print('[TtsService] Speak error: $e');
    }
  }

  /// Processes text for more natural, coaching-style speech.
  /// 
  /// Applies the following improvements:
  /// - Adds proper punctuation for pauses
  /// - Inserts breathing pauses for longer phrases
  /// - Converts abbreviations for clarity
  String _processForFluency(String text) {
    var processed = text.trim();
    
    // Replace common abbreviations with spoken forms
    processed = processed
        .replaceAll('min.', 'minutes')
        .replaceAll('min', 'minutes')
        .replaceAll('seg.', 'seconds')
        .replaceAll('seg', 'seconds')
        .replaceAll('km/h', 'kilómetros por hora')
        .replaceAll('rpm', 'revoluciones por minuto');
    
    // Add commas for natural breathing pauses after time phrases
    processed = processed
        .replaceAllMapped(RegExp(r'(\d+)\s*(minutes|seconds)'), (m) => '${m[1]} ${m[2]},')
        .replaceAll(',,', ','); // Clean double commas
    
    // Ensure sentence ends with punctuation for proper pause
    if (!processed.endsWith('.') && 
        !processed.endsWith('!') && 
        !processed.endsWith('?') &&
        !processed.endsWith(',')) {
      processed = '$processed.';
    }
    
    // Clean up any trailing comma before period
    processed = processed.replaceAll(',.', '.');
    
    return processed;
  }

  /// Stops any ongoing speech.
  Future<void> stop() async {
    try {
      await _flutterTts?.stop();
      _isSpeaking = false;
    } catch (e) {
      print('[TtsService] Stop error: $e');
    }
  }

  /// Sets the speech volume (0.0 to 1.0).
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts?.setVolume(_volume);
  }

  /// Sets the speech rate (0.25 to 0.75).
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.25, 0.75);
    await _flutterTts?.setSpeechRate(_speechRate);
  }

  /// Sets the pitch (0.5 to 2.0).
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts?.setPitch(_pitch);
  }

  /// Tests the TTS with a motivational coaching message.
  Future<void> testVoice() async {
    await speak('Voz activada. Estoy listo para guiarte en tu entrenamiento.');
  }

  /// Whether speech is currently in progress.
  bool get isSpeaking => _isSpeaking;

  /// Disposes of the TTS resources.
  Future<void> dispose() async {
    await _flutterTts?.stop();
    _isInitialized = false;
  }
}
