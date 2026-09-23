import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/config/public_links.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/hyperfocus_theme.dart';
import '../../../../core/services/app_orientation_service.dart';
import '../../../../core/services/data_wipe_service.dart';
import '../../../aac_grid/data/providers/cards_provider.dart';
import 'add_card_screen.dart';
import 'behavior_log_screen.dart';

import 'video_diary_screen.dart';
import 'patient_profile_screen.dart';
import 'parent_reminders_screen.dart';
import 'change_pin_screen.dart';
import 'data_export_screen.dart';
import 'parental_gate_screen.dart';
import 'plan_status_screen.dart';
import 'privacy_settings_screen.dart';
import 'progress_report_screen.dart';
import 'transition_alerts_list_screen.dart';
import 'weekly_trends_screen.dart';
import '../../../transition_alerts/data/providers/transition_alerts_provider.dart';
import '../../../aac_grid/presentation/screens/visual_routine_screen.dart';

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
  Future<void> _openInstitutionalSite() async {
    final uri = Uri.parse(PublicLinks.institutionalSite);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o site agora.')),
      );
    }
  }

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
    AppOrientationService.applyChildOrientation();
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
        title: const Text('Área do Responsável'),
        backgroundColor: AppTheme.professionalBackground,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddCardScreen()),
              ),
              icon: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: const Text('Novo cartão'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          const _SettingsHero(),
          const SizedBox(height: 16),
          _LocationHeroCard(onConnect: _showLocationRoadmap),
          const SizedBox(height: 20),
          _DashboardSection(
            title: 'Acompanhamento & Relatórios',
            description: 'Acesse rapidamente os recursos usados no dia a dia.',
            children: [
              _DashboardActionCard(
                icon: Icons.bar_chart_rounded,
                title: 'Tendências semanais',
                description: 'Resumo de uso e registros',
                color: const Color(0xFF315BFF),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const WeeklyTrendsScreen())),
              ),
              _DashboardActionCard(
                icon: Icons.picture_as_pdf_rounded,
                title: 'Relatórios em PDF',
                description: 'Exportar dados escolhidos',
                color: const Color(0xFFB45309),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const DataExportScreen())),
              ),
              _DashboardActionCard(
                icon: Icons.videocam_rounded,
                title: 'Diário de vídeo',
                description: 'Registrar momentos importantes',
                color: const Color(0xFF7A5FC7),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const VideoDiaryScreen())),
              ),
              _DashboardActionCard(
                icon: Icons.view_timeline_rounded,
                title: 'Rotina visual',
                description: 'Organizar os passos do dia',
                color: const Color(0xFF15803D),
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) =>
                        const VisualRoutineScreen(readOnly: false))),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _SettingsSection(
            icon: Icons.accessibility_new_outlined,
            title: 'Acessibilidade da comunicação',
            description:
                'Ajuste o tamanho, o som e o comportamento dos cartões para a rotina da criança.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tamanho dos botões',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                Slider(
                  value: scale,
                  min: 0.8,
                  max: 1.6,
                  divisions: 8,
                  label: '${(scale * 100).round()}%',
                  activeColor: AppTheme.primary,
                  onChanged: (v) =>
                      ref.read(buttonScaleProvider.notifier).state = v,
                ),
                const SizedBox(height: 8),
                const Text('Orientação da tela da criança',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                const Text(
                  'A paisagem é recomendada para mostrar cartões maiores e reduzir mudanças na rotina. Escolha vertical se o aparelho for usado normalmente em pé.',
                  style: TextStyle(fontSize: 13, color: AppTheme.mutedText),
                ),
                const SizedBox(height: 8),
                SegmentedButton<ChildOrientation>(
                  segments: ChildOrientation.values
                      .map((orientation) => ButtonSegment<ChildOrientation>(
                            value: orientation,
                            icon: Text(childOrientationIcon(orientation)),
                            label: Text(childOrientationLabel(orientation)),
                          ))
                      .toList(),
                  selected: {ref.watch(childOrientationProvider)},
                  onSelectionChanged: (selection) {
                    ref
                        .read(childOrientationProvider.notifier)
                        .setOrientation(selection.first);
                  },
                ),
                const SizedBox(height: 8),
                const Text('Ao tocar em um cartão',
                    style:
                        TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                const Text(
                  'Escolha se o toque fala, monta uma mensagem ou faz as duas coisas.',
                  style: TextStyle(fontSize: 13, color: AppTheme.mutedText),
                ),
                RadioListTile<CardTapBehavior>(
                  contentPadding: EdgeInsets.zero,
                  value: CardTapBehavior.speakAndAdd,
                  groupValue: tapBehavior,
                  title: const Text('Falar e adicionar à frase'),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(cardTapBehaviorProvider.notifier)
                          .setBehavior(value);
                    }
                  },
                ),
                RadioListTile<CardTapBehavior>(
                  contentPadding: EdgeInsets.zero,
                  value: CardTapBehavior.addOnly,
                  groupValue: tapBehavior,
                  title: const Text('Adicionar sem falar'),
                  subtitle:
                      const Text('Recomendado para montar frases com calma.'),
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(cardTapBehaviorProvider.notifier)
                          .setBehavior(value);
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
                      ref
                          .read(cardTapBehaviorProvider.notifier)
                          .setBehavior(value);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            icon: Icons.palette_outlined,
            title: 'Tema e estímulos visuais',
            description:
                'Escolha uma identidade visual para a tela de comunicação sem alterar os cartões.',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: HyperfocusTheme.values.map((theme) {
                final selected = theme == currentTheme;
                return ChoiceChip(
                  label: Text('${theme.emoji} ${theme.displayName}'),
                  selected: selected,
                  onSelected: (_) => ref
                      .read(hyperfocusThemeProvider.notifier)
                      .setTheme(theme),
                  selectedColor: theme.primaryColor.withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: selected ? theme.primaryColor : AppTheme.textDark,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                        color: selected
                            ? theme.primaryColor
                            : AppTheme.cardBorder),
                  ),
                  backgroundColor: AppTheme.surface,
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            icon: Icons.insights_outlined,
            title: 'Registros e rotina',
            description:
                'Organize observações, vídeos e avisos para apoiar a rotina e as conversas com a equipe.',
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fact_check_outlined),
                  title: const Text('Registro de Comportamento'),
                  subtitle: const Text('Registrar gatilhos (modelo ABC)'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const BehaviorLogScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.insights_outlined),
                  title: const Text('Relatórios de progresso'),
                  subtitle: const Text(
                      'Ver um resumo local e exportar dados escolhidos'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ProgressReportScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.picture_as_pdf_outlined),
                  title: const Text('Exportar relatórios em PDF'),
                  subtitle: const Text(
                      'Escolher resumo, ABC ou rotina para compartilhar'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const DataExportScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.bar_chart_outlined),
                  title: const Text('Tendências semanais'),
                  subtitle: const Text(
                      'Ver registros ABC e vídeos das últimas 8 semanas'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const WeeklyTrendsScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.videocam_outlined),
                  title: const Text('Diário de Vídeo'),
                  subtitle:
                      const Text('Gravar momentos para o especialista avaliar'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VideoDiaryScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.alarm_on_outlined),
                  title: const Text('Alertas de Transição'),
                  subtitle:
                      const Text('Avisa a criança antes de mudar de atividade'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const TransitionAlertsListScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.view_timeline_outlined),
                  title: const Text('Rotina visual diária'),
                  subtitle: const Text(
                      'Criar passos simples para a criança consultar'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            const VisualRoutineScreen(readOnly: false)),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_none_outlined),
                  title: const Text('Lembretes do responsável'),
                  subtitle: const Text(
                      'Agendar avisos locais para consultar a rotina'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ParentRemindersScreen()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            icon: Icons.admin_panel_settings_outlined,
            title: 'Conta, plano e privacidade',
            description:
                'Consulte o acesso, os dados usados nos relatórios e as proteções desta área.',
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.workspace_premium_outlined),
                  title: const Text('Plano e recursos'),
                  subtitle:
                      const Text('Ver o acesso local e os planos disponíveis'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlanStatusScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.public_outlined),
                  title: const Text('Conheça o Fala Comigo'),
                  subtitle:
                      const Text('Abrir a página institucional no navegador'),
                  trailing: const Icon(Icons.open_in_new_outlined, size: 20),
                  onTap: _openInstitutionalSite,
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Perfil do Paciente'),
                  subtitle: const Text('Dados da criança para os relatórios'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PatientProfileScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacidade e dados'),
                  subtitle: const Text(
                      'Ver armazenamento, compartilhamento e exclusão'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const PrivacySettingsScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.lock_reset_outlined),
                  title: const Text('Trocar PIN'),
                  subtitle: const Text('Alterar o PIN de acesso a esta área'),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ChangePinScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever_outlined,
                      color: Colors.redAccent),
                  title: const Text('Apagar todos os dados'),
                  subtitle: const Text(
                      'Remove os dados locais e o PIN deste aparelho'),
                  onTap: _deleteAllLocalData,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            icon: Icons.grid_view_outlined,
            title: 'Cartões de comunicação',
            description:
                'Adicione, edite ou reordene os cartões que aparecem na tela principal.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cartões cadastrados (${cards.length})',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 16)),
                const SizedBox(height: 4),
                const Text(
                  'Segure e arraste um cartão para reordenar.',
                  style: TextStyle(fontSize: 12, color: AppTheme.mutedText),
                ),
                const SizedBox(height: 8),
                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cards.length,
                  onReorder: (oldIndex, newIndex) {
                    ref
                        .read(cardsListProvider.notifier)
                        .reorderCards(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final card = cards[index];
                    return Card(
                      key: ValueKey(card.id),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.drag_indicator,
                            color: AppTheme.mutedText),
                        title: Text(card.label),
                        subtitle: Text(card.category),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined,
                                  color: AppTheme.primary),
                              onPressed: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        AddCardScreen(existingCard: card)),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () => ref
                                  .read(cardsListProvider.notifier)
                                  .removeCard(card.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showLocationRoadmap() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Localização segura'),
        content: const Text(
          'O mapa em tempo real será conectado ao painel web autenticado somente depois de configurar consentimento, permissão de localização no aparelho da criança e sincronização segura. Até lá, nenhum local é inventado ou enviado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }
}

class _LocationHeroCard extends StatelessWidget {
  final VoidCallback onConnect;

  const _LocationHeroCard({required this.onConnect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFC9D9F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _IconBubble(
                icon: Icons.location_on_rounded,
                color: Color(0xFF315BFF),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Localização & Segurança',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800)),
                    SizedBox(height: 3),
                    Text('Módulo web autenticado em preparação',
                        style: TextStyle(color: AppTheme.mutedText)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('OFFLINE',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.mutedText)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 148,
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFFDCE8F7),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                CustomPaint(painter: _MapPreviewPainter()),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Color(0x3314253D), blurRadius: 12),
                      ],
                    ),
                    child: const Icon(Icons.lock_outline,
                        color: AppTheme.mutedText, size: 28),
                  ),
                ),
                const Positioned(
                  left: 14,
                  bottom: 12,
                  child: Text('Nenhuma localização compartilhada',
                      style: TextStyle(
                          color: AppTheme.mutedText,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Para proteger a criança, este painel só mostrará local, atualização e bateria depois que a família ativar o consentimento e a conexão segura do aparelho.',
            style: TextStyle(color: AppTheme.mutedText, height: 1.35),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onConnect,
            icon: const Icon(Icons.admin_panel_settings_outlined),
            label: const Text('Ver como a conexão será feita'),
          ),
        ],
      ),
    );
  }
}

class _DashboardSection extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;

  const _DashboardSection({
    required this.title,
    required this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(description, style: const TextStyle(color: AppTheme.mutedText)),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth > 650
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(spacing: 12, runSpacing: 12, children: [
              for (final child in children)
                SizedBox(width: width, child: child),
            ]);
          },
        ),
      ],
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _DashboardActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppTheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppTheme.cardBorder),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _IconBubble(icon: icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    Text(description,
                        style: const TextStyle(
                            color: AppTheme.mutedText, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.mutedText),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _IconBubble({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _MapPreviewPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x5580A4C7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (var x = 0.0; x < size.width; x += 42) {
      canvas.drawLine(Offset(x, 0), Offset(x + 70, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 12), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SettingsHero extends StatelessWidget {
  const _SettingsHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.professionalBackground,
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            AppTheme.professionalBackground,
            AppTheme.professionalSurface
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F14213D),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppTheme.professionalAccent,
            child: Icon(Icons.shield_outlined,
                color: AppTheme.professionalBackground),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajustes protegidos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Personalize a comunicação com calma e mantenha o controle dos dados locais.',
                  style: TextStyle(
                      color: Color(0xFFD8E7F0), fontSize: 13, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  const _SettingsSection({
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F14213D),
            blurRadius: 12,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppTheme.primary, size: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800, fontSize: 17)),
                    const SizedBox(height: 4),
                    Text(description,
                        style: const TextStyle(
                            color: AppTheme.mutedText,
                            fontSize: 13,
                            height: 1.35)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
