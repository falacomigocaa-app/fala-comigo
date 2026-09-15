import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../core/services/transition_alert_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../transition_alerts/data/providers/transition_alerts_provider.dart';
import '../../../transition_alerts/domain/models/transition_alert.dart';

const Map<int, String> _weekdayLabels = {
  1: 'D',
  2: 'S',
  3: 'T',
  4: 'Q',
  5: 'Q',
  6: 'S',
  7: 'S',
};

/// Tela de criação/edição de um Alerta de Transição de Atividade:
/// título, áudio (gravado ou digitado/TTS), disparo manual e/ou
/// agendado, e os itens do checklist gamificado que aparece depois.
class TransitionAlertEditScreen extends ConsumerStatefulWidget {
  final TransitionAlert? existingAlert;

  const TransitionAlertEditScreen({super.key, this.existingAlert});

  @override
  ConsumerState<TransitionAlertEditScreen> createState() =>
      _TransitionAlertEditScreenState();
}

class _TransitionAlertEditScreenState
    extends ConsumerState<TransitionAlertEditScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _ttsController;
  final TextEditingController _checklistInputController =
      TextEditingController();

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _player = AudioPlayer();

  late String _alertId;
  late int _notificationId;
  late String _audioType; // 'gravado' ou 'tts'
  String? _recordedAudioPath;
  bool _isRecording = false;
  bool _isPlayingPreview = false;

  late bool _isScheduled;
  TimeOfDay? _scheduledTimeOfDay;
  late Set<int> _scheduledWeekdays;
  late int _countdownSeconds;
  late List<String> _checklistItems;

  bool get _isEditing => widget.existingAlert != null;
  @override
  void initState() {
    super.initState();
    final existing = widget.existingAlert;
    final notifier = ref.read(transitionAlertsListProvider.notifier);

    _alertId = existing?.id ?? notifier.generateId();
    _notificationId =
        existing?.notificationId ?? notifier.generateNotificationId();

    _titleController = TextEditingController(text: existing?.title ?? '');
    _audioType = existing?.audioType ?? 'tts';
    _ttsController = TextEditingController(text: existing?.ttsText ?? '');
    _recordedAu
Future<String> _recordingFilePath() async {
    final dir = await getApplicationDocumentsDirectory();
    final alertsDir = Directory('${dir.path}/transition_alerts_audio');
    if (!await alertsDir.exists()) {
      await alertsDir.create(recursive: true);
    }
    return '${alertsDir.path}/$_alertId.m4a';
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        _recordedAudioPath = path ?? _recordedAudioPath;
      });
      return;
    }

    if (!await _recorder.hasPermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('É preciso autorizar o uso do microfone para gravar.'),
          ),
        );
      }
      return;
    }

    final path = await _recordingFilePath();
    await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path);
    setState(() => _isRecording = true);
  }

  Future<void> _playPreview() async {
    if (_recordedAudioPath == null) return;
    setState(() => _isPlayingPreview = true);
    await _player.play(DeviceFileSource(_recordedAudioPath!));
    _player.onPlayerComplete.first.then((_) {
      if (mounted) setState(() => _isPlayingPreview = false);
    });
  }
    Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTimeOfDay ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _scheduledTimeOfDay = picked);
    }
  }

  void _addChecklistItem() {
    final text = _checklistInputController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _checklistItems.add(text);
      _checklistInputController.clear();
    });
  }

  TransitionAlert _buildAlert() {
    return TransitionAlert(
      id: _alertId,
      title: _titleController.text.trim(),
      audioType: _audioType,
      recordedAudioPath: _recordedAudioPath,
      ttsText: _ttsController.text.trim(),
      countdownSeconds: _countdownSeconds,
      checklistItems: _checklistItems,
      isScheduled: _isScheduled,
      scheduledHour: _scheduledTimeOfDay?.hour,
      scheduledMinute: _scheduledTimeOfDay?.minute,
      scheduledWeekdays: _scheduledWeekdays.toList(),
      notificationId: _notificationId,
    );
  }Future<void> _save() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Dê um nome para o alerta antes de salvar.')),
      );
      return;
    }
    final alert = _buildAleconst Text('Mensagem de áudio',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Gravar minha voz'),
                selected: _audioType == 'gravado',
                onSelected: (_) => setState(() => _audioType = 'gravado'),
              ),
              Chconst Text('Contagem visual',
              style: TextStyle(fontWeight: FontWeight.w700)),
          Text('$_countdownSeconds segundos',
              style: const TextStyle(color: Colors.grey)),
          Slider(
            value: _countdownSeconds.toDouble(),
            min: 10,
            max: 300,
            divisionconst Text('Checklist depois do alerta',
              style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'Dica: comece cada item com um emoji, ex: "🧸 Guardar os brinquedos".',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
