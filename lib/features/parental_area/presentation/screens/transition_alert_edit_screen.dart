import 'dart:io';
import 'package:audioplayers/audioplayers.dart'; import 'package:flutter/material.dart'; import 'package:flutter_riverpod/flutter_riverpod.dart'; import 'package:path_provider/path_provider.dart'; import 'package:record/record.dart';
import '../../../../core/services/transition_alert_service.dart'; import '../../../../core/theme/app_theme.dart'; import '../../../transition_alerts/data/providers/transition_alerts_provider.dart'; import '../../../transition_alerts/domain/models/transition_alert.dart';
const Map<int, String> _weekdayLabels = { 1: 'D', 2: 'S', 3: 'T', 4: 'Q', 5: 'Q', 6: 'S', 7: 'S', };
/// Tela de criação/edição de um Alerta de Transição de Atividade: /// título, áudio (gravado ou digitado/TTS), disparo manual e/ou /// agendado, e os itens do checklist gamificado que aparece depois. class TransitionAlertEditScreen extends ConsumerStatefulWidget { final TransitionAlert? existingAlert;
  const TransitionAlertEditScreen({super.key, this.existingAlert});
  @override ConsumerState<TransitionAlertEditScreen> createState() => _TransitionAlertEditScreenState(); }
class _TransitionAlertEditScreenState extends ConsumerState<TransitionAlertEditScreen> { late final TextEditingController _titleController; late final TextEditingController _ttsController; final TextEditingController _checklistInputController = TextEditingController();
  final AudioRecorder _recorder = AudioRecorder(); final AudioPlayer _player = AudioPlayer();
  late String _alertId; late int _notificationId; late String _audioType; // 'gravado' ou 'tts' String? _recordedAudioPath; bool _isRecording = false; bool _isPlayingPreview = false;
  late bool _isScheduled; TimeOfDay? _scheduledTimeOfDay; late Set<int> _scheduledWeekdays; late int _countdownSeconds; late List<String> _checklistItems;
  bool get _isEditing => widget.existingAlert != null;
  @override void initState() { super.initState(); final existing = widget.existingAlert; final notifier = ref.read(transitionAlertsListProvider.notifier);
_alertId = existing?.id ?? notifier.generateId();
_notificationId =
    existing?.notificationId ?? notifier.generateNotificationId();

_titleController = TextEditingController(text: existing?.title ?? '');
_audioType = existing?.audioType ?? 'tts';
_ttsController = TextEditingController(text: existing?.ttsText ?? '');
_recordedAudioPath = existing?.recordedAudioPath;

_isScheduled = existing?.isScheduled ?? false;
_scheduledWeekdays = {...(existing?.scheduledWeekdays ?? [])};
_countdownSeconds = existing?.countdownSeconds ?? 60;
_checklistItems = [...(existing?.checklistItems ?? [])];

if (existing?.scheduledHour != null &&
    existing?.scheduledMinute != null) {
  _scheduledTimeOfDay = TimeOfDay(
      hour: existing!.scheduledHour!, minute: existing.scheduledMinute!);
}
  }
  @override void dispose() { _titleController.dispose(); _ttsController.dispose(); _checklistInputController.dispose(); _recorder.dispose(); _player.dispose(); super.dispose(); }
  Future<String> _recordingFilePath() async { final dir = await getApplicationDocumentsDirectory(); final alertsDir = Directory('{dir.path}/transition_alerts_audio');
    if (!await alertsDir.exists()) {
      await alertsDir.create(recursive: true);
    }
    return '{alertsDir.path}/$_alertId.m4a'; }
  Future<void> _toggleRecording() async { if (_isRecording) { final path = await _recorder.stop(); setState(() { _isRecording = false; _recordedAudioPath = path ?? _recordedAudioPath; }); return; }
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
  Future<void> _playPreview() async { if (_recordedAudioPath == null) return; setState(() => _isPlayingPreview = true); await _player.play(DeviceFileSource(_recordedAudioPath!)); player.onPlayerComplete.first.then(() { if (mounted) setState(() => _isPlayingPreview = false); }); }
  Future<void> _pickTime() async { final picked = await showTimePicker( context: context, initialTime: _scheduledTimeOfDay ?? TimeOfDay.now(), ); if (picked != null) { setState(() => _scheduledTimeOfDay = picked); } }
  void _addChecklistItem() { final text = _checklistInputController.text.trim(); if (text.isEmpty) return; setState(() { _checklistItems.add(text); _checklistInputController.clear(); }); }
  TransitionAlert _buildAlert() { return TransitionAlert( id: _alertId, title: _titleController.text.trim(), audioType: _audioType, recordedAudioPath: _recordedAudioPath, ttsText: _ttsController.text.trim(), countdownSeconds: _countdownSeconds, checklistItems: _checklistItems, isScheduled: _isScheduled, scheduledHour: _scheduledTimeOfDay?.hour, scheduledMinute: _scheduledTimeOfDay?.minute, scheduledWeekdays: _scheduledWeekdays.toList(), notificationId: _notificationId, ); }
  Future<void> _save() async { if (_titleController.text.trim().isEmpty) { ScaffoldMessenger.of(context).showSnackBar( const SnackBar( content: Text('Dê um nome para o alerta antes de salvar.')), ); return; } final alert = _buildAlert(); if (_isEditing) { await ref.read(transitionAlertsListProvider.notifier).updateAlert(alert); } else { await ref.read(transitionAlertsListProvider.notifier).addAlert(alert); } await TransitionAlertService.instance.scheduleRecurring(alert); if (mounted) Navigator.of(context).pop(); }
  @override Widget build(BuildContext context) { return Scaffold( backgroundColor: AppTheme.background, appBar: AppBar( title: Text(_isEditing ? 'Editar Alerta' : 'Novo Alerta'), backgroundColor: AppTheme.surface, ), body: ListView( padding: const EdgeInsets.all(16), children: [ const Text('Nome do alerta', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 4), TextField( controller: _titleController, decoration: const InputDecoration( hintText: 'Ex: Hora do banho', border: OutlineInputBorder(), ), ), const Divider(height: 32),
      const Text('Mensagem de áudio',
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
          ChoiceChip(
            label: const Text('Digitar (o app fala)'),
            selected: _audioType == 'tts',
            onSelected: (_) => setState(() => _audioType = 'tts'),
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (_audioType == 'gravado')
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: _toggleRecording,
              icon: Icon(_isRecording ? Icons.stop : Icons.mic),
              label: Text(_isRecording ? 'Parar' : 'Gravar'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isRecording ? Colors.redAccent : AppTheme.primary,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            if (_recordedAudioPath != null)
              IconButton(
                onPressed: _isPlayingPreview ? null : _playPreview,
                icon: const Icon(Icons.play_circle,
                    color: AppTheme.accentGreen, size: 32),
                tooltip: 'Ouvir gravação',
              ),
          ],
        )
      else
        TextField(
          controller: _ttsController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Ex: Vamos guardar os brinquedos e ir para o banho!',
            border: OutlineInputBorder(),
          ),
        ),
      const Divider(height: 32),

      const Text('Contagem visual',
          style: TextStyle(fontWeight: FontWeight.w700)),
      Text('$_countdownSeconds segundos',
          style: const TextStyle(color: Colors.grey)),
      Slider(
        value: _countdownSeconds.toDouble(),
        min: 10,
        max: 300,
        divisions: 29,
        activeColor: AppTheme.primary,
        onChanged: (v) => setState(() => _countdownSeconds = v.round()),
      ),
      const Divider(height: 32),

      Row(
        children: [
          const Expanded(
            child: Text('Repetir em horário fixo',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          Switch(
            value: _isScheduled,
            activeColor: AppTheme.primary,
            onChanged: (v) => setState(() => _isScheduled = v),
          ),
        ],
      ),
      if (_isScheduled) ...[
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _pickTime,
          icon: const Icon(Icons.access_time),
          label: Text(
            _scheduledTimeOfDay == null
                ? 'Escolher horário'
                : _scheduledTimeOfDay!.format(context),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 6,
          children: _weekdayLabels.entries.map((entry) {
            final selected = _scheduledWeekdays.contains(entry.key);
            return FilterChip(
              label: Text(entry.value),
              selected: selected,
              selectedColor: AppTheme.primary.withValues(alpha: 0.2),
              onSelected: (sel) => setState(() {
                if (sel) {
                  _scheduledWeekdays.add(entry.key);
                } else {
                  _scheduledWeekdays.remove(entry.key);
                }
              }),
            );
          }).toList(),
        ),
      ],
      const Divider(height: 32),

      const Text('Checklist depois do alerta',
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
            child: TextField(
              controller: _checklistInputController,
              decoration: const InputDecoration(
                hintText: '🧸 Guardar os brinquedos',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addChecklistItem(),
            ),
          ),
          IconButton(
            onPressed: _addChecklistItem,
            icon: const Icon(Icons.add_circle,
                color: AppTheme.primary, size: 32),
          ),
        ],
      ),
      const SizedBox(height: 8),
      for (var i = 0; i < _checklistItems.length; i++)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(_checklistItems[i]),
          trailing: IconButton(
            icon: const Icon(Icons.close, color: Colors.redAccent),
            onPressed: () => setState(() => _checklistItems.removeAt(i)),
          ),
        ),
      const SizedBox(height: 24),

      ElevatedButton.icon(
        onPressed: _save,
        icon: const Icon(Icons.check),
        label: const Text('Salvar alerta'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
        ),
      ),
      const SizedBox(height: 40),
    ],
  ),
);
  } }
