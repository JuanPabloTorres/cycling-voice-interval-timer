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
    await _ttsService.speak('Prueba de voz. ¡Vamos, tú puedes!');
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ajustes de Voz'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimens.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Voice selection
                  _buildSectionHeader('Voz', Icons.record_voice_over),
                  const SizedBox(height: AppDimens.paddingM),
                  _buildVoiceSelector(),
                  
                  const SizedBox(height: AppDimens.paddingXL),
                  
                  // Speech rate
                  _buildSectionHeader('Velocidad', Icons.speed),
                  const SizedBox(height: AppDimens.paddingM),
                  _buildSlider(
                    value: _speechRate,
                    min: 0.25,
                    max: 0.75,
                    divisions: 10,
                    label: _getSpeechRateLabel(_speechRate),
                    onChanged: _onSpeechRateChanged,
                  ),
                  
                  const SizedBox(height: AppDimens.paddingXL),
                  
                  // Pitch
                  _buildSectionHeader('Tono', Icons.tune),
                  const SizedBox(height: AppDimens.paddingM),
                  _buildSlider(
                    value: _pitch,
                    min: 0.5,
                    max: 1.5,
                    divisions: 10,
                    label: _getPitchLabel(_pitch),
                    onChanged: _onPitchChanged,
                  ),
                  
                  const SizedBox(height: AppDimens.paddingXL),
                  
                  // Volume
                  _buildSectionHeader('Volumen', Icons.volume_up),
                  const SizedBox(height: AppDimens.paddingM),
                  _buildSlider(
                    value: _volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_volume * 100).round()}%',
                    onChanged: _onVolumeChanged,
                  ),
                  
                  const SizedBox(height: AppDimens.paddingXL * 2),
                  
                  // Test button
                  _buildTestButton(),
                  
                  const SizedBox(height: AppDimens.paddingL),
                  
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
          padding: const EdgeInsets.all(AppDimens.paddingS),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimens.radiusS),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: AppDimens.paddingM),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSelector() {
    if (_voices.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimens.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.textSecondary),
            SizedBox(width: AppDimens.paddingM),
            Expanded(
              child: Text(
                'No se encontraron voces en español. Se usará la voz predeterminada del sistema.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.divider),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TtsVoice>(
          value: _selectedVoice,
          hint: const Text('Seleccionar voz'),
          isExpanded: true,
          dropdownColor: AppColors.surface,
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
          items: _voices.map((voice) {
            return DropdownMenuItem<TtsVoice>(
              value: voice,
              child: Text(
                voice.displayName,
                style: const TextStyle(color: AppColors.textPrimary),
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
            inactiveTrackColor: AppColors.divider,
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
    if (rate < 0.35) return 'Muy lenta';
    if (rate < 0.45) return 'Lenta';
    if (rate < 0.55) return 'Normal';
    if (rate < 0.65) return 'Rápida';
    return 'Muy rápida';
  }

  String _getPitchLabel(double pitch) {
    if (pitch < 0.7) return 'Muy grave';
    if (pitch < 0.9) return 'Grave';
    if (pitch < 1.1) return 'Normal';
    if (pitch < 1.3) return 'Agudo';
    return 'Muy agudo';
  }

  Widget _buildTestButton() {
    return GradientButton(
      text: 'Probar Voz',
      icon: Icons.play_arrow,
      onPressed: _testVoice,
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimens.paddingL),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimens.radiusM),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimens.paddingS),
              const Text(
                'Consejos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimens.paddingM),
          const Text(
            '• Para mayor claridad durante el ciclismo, usa velocidad "Lenta"\n'
            '• En Windows, instala voces Microsoft desde Configuración → Hora e Idioma → Voz\n'
            '• Las voces "Microsoft Helena" o "Microsoft Laura" suenan más naturales',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
