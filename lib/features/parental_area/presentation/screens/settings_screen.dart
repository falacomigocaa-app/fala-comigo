import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../aac_grid/data/providers/cards_provider.dart';
import 'add_card_screen.dart';
import 'behavior_log_screen.dart';

/// Painel dos Pais & Educadores.
///
/// Permite:
/// - Adicionar novos cartões (fotos da galeria/câmera);
/// - Ajustar o tamanho dos botões da grade;
/// - Remover cartões existentes.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(cardsListProvider);
    final scale = ref.watch(buttonScaleProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Painel dos Pais & Educadores'),
        backgroundColor: AppTheme.surface,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddCardScreen()),
        ),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Novo cartão'),
        backgroundColor: AppTheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Tamanho dos botões', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          Slider(
            value: scale,
            min: 0.8,
            max: 1.6,
            divisions: 8,
            label: '${(scale * 100).round()}%',
            activeColor: AppTheme.primary,
            onChanged: (v) => ref.read(buttonScaleProvider.notifier).state = v,
          ),
          const Divider(height: 32),
ListTile(
  leading: const Icon(Icons.fact_check_outlined),
  title: const Text('Registro de Comportamento'),
  subtitle: const Text('Registrar gatilhos (modelo ABC)'),
  onTap: () => Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const BehaviorLogScreen()),
  ),
),
const Divider(height: 16),
          Text('Cartões cadastrados (${cards.length})',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 8),
          ...cards.map(
            (card) => Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                title: Text(card.label),
                subtitle: Text(card.category),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => ref.read(cardsListProvider.notifier).removeCard(card.id),
                ),
              ),
            ),
          ),
          const SizedBox(height: 80), // espaço para o FAB não cobrir a lista
        ],
      ),
    );
  }
}
