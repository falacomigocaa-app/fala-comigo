import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/services/secure_box_service.dart';
import '../../../../core/theme/app_theme.dart';

/// Diário de Vídeo: grava vídeos curtos de momentos de uso do app,
/// anexando contexto (o que aconteceu), para os pais compartilharem
/// com o terapeuta/especialista avaliar.
///
/// Não faz nenhuma análise automática do vídeo — a gravação e o
/// contexto ficam salvos localmente, em uma Hive Box criptografada
/// com AES-256 (ver SecureBoxService), e cabe à família decidir
/// quando e com quem compartilhar.
class VideoDiaryScreen extends StatefulWidget {
  const VideoDiaryScreen({super.key});

  @override
  State<VideoDiaryScreen> createState() => _VideoDiaryScreenState();
}

class _VideoDiaryScreenState extends State<VideoDiaryScreen> {
  static const String _boxName = 'video_diary';

  final _contextController = TextEditingController();
  final _picker = ImagePicker();

  Box? _box;
  bool _loading = true;
  String? _pendingVideoPath;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    final box = await SecureBoxService.openSecureBox(_boxName);
    setState(() {
      _box = box;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }
  Future<void> _recordVideo() async {
    final video = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 3),
    );
    if (video == null) return;
    setState(() {
      _pendingVideoPath = video.path;
    });
  }

  Future<void> _saveEntry() async {
    if (_pendingVideoPath == null) return;

    final entry = {
      'timestamp': DateTime.now().toIso8601String(),
      'videoPath': _pendingVideoPath,
      'context': _contextController.text.trim(),
    };

    await _box?.add(entry);

    setState(() {
      _pendingVideoPath = null;
      _contextController.clear();
    });
    FocusScope.of(context).unfocus();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Vídeo salvo.')),
    );
  }

  void _deleteEntry(dynamic key, String? videoPath) {
    _box?.delete(key);
    if (videoPath != null) {
      final file = File(videoPath);
      file.exists().then((exists) {
        if (exists) file.delete();
      });
    }
  }

  Future<void> _shareEntry(String videoPath, String context) async {
  final file = File(videoPath);
  if (!await file.exists()) return;
  await Share.shareXFiles(
    [XFile(videoPath)],
    text: context.isNotEmpty
        ? 'Vídeo do Fala Comigo — contexto: $context'
        : 'Vídeo do Fala Comigo',
  );
  }

  String _formatDate(String isoString) {
    final date = DateTime.tryParse(isoString);
    if (date == null) return '';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m às $h:$min';
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Diário de Vídeo'),
        backgroundColor: AppTheme.surface,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Grave momentos para o especialista avaliar',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Grave um vídeo curto do momento e adicione um contexto. '
                    'Depois, compartilhe com o terapeuta ou a escola.',
                    styl
