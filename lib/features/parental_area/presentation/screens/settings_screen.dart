import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/hyperfocus_theme.dart';
import '../../../../core/services/data_wipe_service.dart';
import '../../../aac_grid/data/providers/cards_provider.dart';
import 'add_card_screen.dart';
import 'behavior_log_screen.dart';

import 'video_diary_screen.dart';
import 'patient_profile_screen.dart';
import 'change_pin_screen.dart';
import 'parental_gate_screen.dart';
import 'plan_status_screen.dart';
import 'transition_alerts_list_screen.dart';
import '../../../transition_alerts/data/providers/transition_alerts_provider.dart';

/// Painel dos Pais & Educadores.
///
/// Permite:
/// - Adicionar, editar e reordenar cartões (arraste para reordenar);
/// - Ajustar o tamanho dos botões da grade;
/// - Escolher o tema visual de hiperfoco da criança;
/// - Remover cartões existentes.
///
/// Ao sair desta tela (voltando para a comunicação da criança), a
/// orientação volta a ser travada em paisagem.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Future<void> _deleteAllLocalData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Apagar todos os dados?'),
        content: const Text(
          'Esta ação remove cartões personalizados, perfil, registros, vídeos, áudios, configurações e o PIN deste aparelho. Não pode ser desfeita pelo aplicativo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Apagar tudo'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await DataWipeService.deleteAllLocalData();
    if (!mounted) return;
    ref.invalidate(cardsBoxProvider);
    ref.invalidate(cardsListProvider);
    ref.invalidate(transitionAlertsListProvider);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const ParentalGateScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cards = ref.watch(cardsListProvider);
    final scale = ref.watch(buttonScaleProvider);
    final tapBehavior = ref.watch(cardTapBehaviorProvider);
    final currentTheme = ref.watch(hyperfocusThemeProvider);

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
          const SizedBox(height: 8),
          const Text('Ao tocar em um cartão',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            'Escolha se o toque fala, monta uma mensagem ou faz as duas coisas.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          RadioListTile<CardTapBehavior>(
            contentPadding: EdgeInsets.zero,
            value: CardTapBehavior.speakAndAdd,
            groupValue: tapBehavior,
            title: const Text('Falar e adicionar à frase'),
            onChanged: (value) {
              if (value != null) {
                ref.read(cardTapBehaviorProvider.notifier).setBehavior(value);
              }
            },
          ),
          RadioListTile<CardTapBehavior>(
            contentPadding: EdgeInsets.zero,
            value: CardTapBehavior.addOnly,
            groupValue: tapBehavior,
            title: const Text('Adicionar sem falar'),
            subtitle: const Text('Recomendado para montar frases com calma.'),
            onChanged: (value) {
              if (value != null) {
                ref.read(cardTapBehaviorProvider.notifier).setBehavior(value);
              }
            },
          ),
          RadioListTile<CardTapBehavior>(
            contentPadding: EdgeInsets.zero,
            value: CardTapBehavior.speakOnly,
            groupValue: tapBehavior,
            title: const Text('Falar sem adicionar à frase'),
            onChanged: (value) {
              if (value != null) {
                ref.read(cardTapBehaviorProvider.notifier).setBehavior(value);
              }
            },
          ),
          const Divider(height: 24),
          const Text('Tema por Hiperfoco', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            'Deixa a tela da criança com a cara do interesse favorito dela.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: HyperfocusTheme.values.map((theme) {
              final selected = theme == currentTheme;
              return ChoiceChip(
                label: Text('${theme.emoji} ${theme.displayName}'),
                selected: selected,
                onSelected: (_) => ref.read(hyperfocusThemeProvider.notifier).setTheme(theme),
                selectedColor: theme.primaryColor.withValues(alpha: 0.2),
                labelStyle: TextStyle(
                  color: selected ? theme.primaryColor : AppTheme.textDark,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: selected ? theme.primaryColor : AppTheme.cardBorder),
                ),
                backgroundColor: AppTheme.surface,
              );
            }).toList(),
          ),
          const Divider(height: 24),
          ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: const Text('Registro de Comportamento'),
            subtitle: const Text('Registrar gatilhos (modelo ABC)'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BehaviorLogScreen()),
            ),
          ),
          const Divider(height: 16),
          ListTile(
            leading: const Icon(Icons.videocam_outlined),
            title: const Text('Diário de Vídeo'),
            subtitle: const Text('Gravar momentos para o especialista avaliar'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VideoDiaryScreen()),
            ),
          ),
          const Divider(height: 16),
          ListTile(
            leading: const Icon(Icons.alarm_on_outlined),
            title: const Text('Alertas de Transição'),
            subtitle: const Text('Avisa a criança antes de mudar de atividade'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const TransitionAlertsListScreen()),
            ),
          ),
          const Divider(height: 16),
          ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: const Text('Plano e recursos'),
            subtitle: const Text('Ver o acesso local e os planos disponíveis'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PlanStatusScreen()),
            ),
          ),
          const Divider(height: 16),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Perfil do Paciente'),
            subtitle: const Text('Dados da criança para os relatórios'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PatientProfileScreen()),
            ),
          ),
          const Divider(height: 16),
          ListTile(
            leading: const Icon(Icons.lock_reset_outlined),
            title: const Text('Trocar PIN'),
            subtitle: const Text('Alterar o PIN de acesso a esta área'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChangePinScreen()),
            ),
          ),
          const Divider(height: 16),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.redAccent),
            title: const Text('Apagar todos os dados'),
            subtitle: const Text('Remove os dados locais e o PIN deste aparelho'),
            onTap: _deleteAllLocalData,
          ),
          const Divider(height: 16),
          Text('Cartões cadastrados (${cards.length})',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          const Text(
            'Segure e arraste um cartão para reordenar.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cards.length,
            onReorder: (oldIndex, newIndex) {
              ref.read(cardsListProvider.notifier).reorderCards(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final card = cards[index];
              return Card(
                key: ValueKey(card.id),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.drag_indicator, color: Colors.grey),
                  title: Text(card.label),
                  subtitle: Text(card.category),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppTheme.primary),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => AddCardScreen(existingCard: card)),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => ref.read(cardsListProvider.notifier).removeCard(card.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 80), // espaço para o FAB não cobrir a lista
        ],
      ),
    );
  }
}
