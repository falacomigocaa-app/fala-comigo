import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../aac_grid/data/providers/cards_provider.dart';

/// Tela usada pelos pais/educadores para cadastrar um novo cartão:
/// escolhem uma foto (câmera ou galeria) e digitam o rótulo que
/// será falado pelo TTS.
class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  final TextEditingController _labelController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  String _category = 'personalizado';

  Future<void> _pickImage(ImageSource source) async {
    final XFile? picked = await _picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  void _saveCard() {
    if (_selectedImage == null || _labelController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escolha uma foto e digite um nome para o cartão.')),
      );
      return;
    }

    ref.read(cardsListProvider.notifier).addCard(
          label: _labelController.text.trim(),
          imagePath: _selectedImage!.path,
          isCustomImage: true,
          category: _category,
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Adicionar Cartão'), backgroundColor: AppTheme.surface),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Wrap(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.photo_library_outlined),
                        title: const Text('Escolher da Galeria'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_camera_outlined),
                        title: const Text('Tirar Foto'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              child: Container(
                height: 160,
                width: 160,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.cardBorder, width: 1.5),
                ),
                child: _selectedImage == null
                    ? const Center(
                        child: Icon(Icons.add_a_photo_outlined, size: 40, color: AppTheme.primary),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Nome do cartão (o que será falado)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Categoria', border: OutlineInputBorder()),
              items: AppConstants.categoryLabels.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v ?? 'personalizado'),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCard,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  backgroundColor: AppTheme.accentGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar Cartão', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
