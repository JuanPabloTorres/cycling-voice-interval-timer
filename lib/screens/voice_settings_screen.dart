import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import '../services/tts_service.dart';
import '../ui/ui.dart';

/// Screen for configuring TTS voice settings.
class VoiceSettingsScreen extends StatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  State<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends State<VoiceSettingsScreen> {
  late TtsService _ttsService;
  bool _isLoading = true;
  List<TtsVoice> _voices = [];
  TtsVoice? _selectedVoice;
  double _speechRate = 0.45;
  double _pitch = 1.0;
  double _volume = 1.0;

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    final provider = context.read<TimerProvider>();
    _ttsService = provider.ttsService;
    
    await _ttsService.initialize();
    
    setState(() {
      _voices = _ttsService.availableVoices;
      _selectedVoice = _ttsService.selectedVoice;
      _speechRate = _ttsService.speechRate;
      _pitch = _ttsService.pitch;
      _volume = _ttsService.volume;
      _isLoading = false;
    });
  }

  Future<void> _testVoice() async {
    await _ttsService.speak('Voice test. Let\'s go, you can do it!');
  }

  Future<void> _onVoiceChanged(TtsVoice? voice) async {
    if (voice == null) return;
    
    setState(() => _selectedVoice = voice);
    await _ttsService.setVoice(voice);
    await _testVoice();
  }

  Future<void> _onSpeechRateChanged(double value) async {
    setState(() => _speechRate = value);
    await _ttsService.setSpeechRate(value);
  }

  Future<void> _onPitchChanged(double value) async {
    setState(() => _pitch = value);
    await _ttsService.setPitch(value);
  }

  Future<void> _onVolumeChanged(double value) async {
    setState(() => _volume = value);
    await _ttsService.setVolume(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FC),
      appBar: AppBar(
        title: const Text(
          'Voice Settings',
          style: TextStyle(
            color: AppColors.textPrimaryLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimaryLight),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Voice selection
                  _buildSectionHeader('Voice', Icons.record_voice_over),
                  const SizedBox(height: AppDimens.md),
                  _buildVoiceSelector(),
                  
                  const SizedBox(height: AppDimens.xl),
                  
                  // Speech rate
                  _buildSectionHeader('Speed', Icons.speed),
                  const SizedBox(height: AppDimens.md),
                  _buildSlider(
                    value: _speechRate,
                    min: 0.25,
                    max: 0.75,
                    divisions: 10,
                    label: _getSpeechRateLabel(_speechRate),
                    onChanged: _onSpeechRateChanged,
                  ),
                  
                  const SizedBox(height: AppDimens.xl),
                  
                  // Pitch
                  _buildSectionHeader('Pitch', Icons.tune),
                  const SizedBox(height: AppDimens.md),
                  _buildSlider(
                    value: _pitch,
                    min: 0.5,
                    max: 1.5,
                    divisions: 10,
                    label: _getPitchLabel(_pitch),
                    onChanged: _onPitchChanged,
                  ),
                  
                  const SizedBox(height: AppDimens.xl),
                  
                  // Volume
                  _buildSectionHeader('Volume', Icons.volume_up),
                  const SizedBox(height: AppDimens.md),
                  _buildSlider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_volume * 100).round()}%',
                    onChanged: _onVolumeChanged,
                  ),
                  
                  const SizedBox(height: AppDimens.xxl),
                  
                  // Test button
                  _buildTestButton(),
                  
                  const SizedBox(height: AppDimens.lg),
                  
                  // Tips
                  _buildTipsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppDimens.sm),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppDimens.radiusSm),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppDimens.md),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSelector() {
    if (_voices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimens.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
          border: Border.all(color: AppColors.textDisabledLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.textSecondaryLight),
            const SizedBox(width: AppDimens.md),
            Expanded(
              child: Text(
                'No English voices found. The default system voice will be used.',
                style: TextStyle(color: AppColors.textSecondaryLight),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.textDisabledLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TtsVoice>(
          value: _selectedVoice,
          hint: Text('Select voice', style: TextStyle(color: AppColors.textSecondaryLight)),
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          items: _voices.map((voice) {
            return DropdownMenuItem<TtsVoice>(
              value: voice,
              child: Text(
                voice.displayName,
                style: const TextStyle(color: AppColors.textPrimaryLight),
              ),
            );
          }).toList(),
          onChanged: _onVoiceChanged,
        ),
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.textDisabledLight,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            onChangeEnd: (_) => _testVoice(),
          ),
        ),
      ],
    );
  }

  String _getSpeechRateLabel(double rate) {
    if (rate < 0.35) return 'Very slow';
    if (rate < 0.45) return 'Slow';
    if (rate < 0.55) return 'Normal';
    if (rate < 0.65) return 'Fast';
    return 'Very fast';
  }

  String _getPitchLabel(double pitch) {
    if (pitch < 0.7) return 'Very low';
    if (pitch < 0.9) return 'Low';
    if (pitch < 1.1) return 'Normal';
    if (pitch < 1.3) return 'High';
    return 'Very high';
  }

  Widget _buildTestButton() {
    return ElevatedButton.icon(
      onPressed: _testVoice,
      icon: const Icon(Icons.play_arrow),
      label: const Text('Test Voice'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: AppDimens.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        ),
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimens.sm),
              const Text(
                'Tips',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.md),
          Text(
            '• For better clarity while cycling, use "Slow" speed\n'
            '• On Windows, install Microsoft voices from Settings → Time & Language → Speech\n'
            '• "Microsoft Helena" or "Microsoft Laura" voices sound more natural',
            style: TextStyle(
              color: AppColors.textSecondaryLight,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
