import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../data/care_coordination.dart';
import '../widgets/parental_ui.dart';

class CareCoordinationScreen extends StatelessWidget {
  const CareCoordinationScreen({super.key});

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            title: const Text('Continuidade do cuidado'),
            backgroundColor: AppTheme.professionalBackground,
            foregroundColor: Colors.white,
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Perfil'),
                Tab(text: 'Plano'),
                Tab(text: 'Agenda'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _CommunicationProfileTab(),
              _CommunicationPlanTab(),
              _AgendaTab(),
            ],
          ),
        ),
      );
}

class _CommunicationProfileTab extends StatefulWidget {
  const _CommunicationProfileTab();

  @override
  State<_CommunicationProfileTab> createState() => _CommunicationProfileTabState();
}

class _CommunicationProfileTabState extends State<_CommunicationProfileTab> {
  final _modes = TextEditingController();
  final _access = TextEditingController();
  final _facilitators = TextEditingController();
  final _avoid = TextEditingController();
  final _contingency = TextEditingController();
  final _partners = TextEditingController();
  bool _loading = true;
  DateTime? _reviewAt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await CareCoordinationStore.loadProfile();
    _modes.text = profile.communicationModes;
    _access.text = profile.preferredAccess;
    _facilitators.text = profile.facilitators;
    _avoid.text = profile.avoid;
    _contingency.text = profile.contingencyPlan;
    _partners.text = profile.partners;
    if (!mounted) return;
    setState(() {
      _reviewAt = profile.reviewAt;
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final controller in [_modes, _access, _facilitators, _avoid, _contingency, _partners]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    await CareCoordinationStore.saveProfile(CommunicationProfile(
      subjectId: 'local-subject',
      communicationModes: _modes.text.trim(),
      preferredAccess: _access.text.trim(),
      facilitators: _facilitators.text.trim(),
      avoid: _avoid.text.trim(),
      contingencyPlan: _contingency.text.trim(),
      partners: _partners.text.trim(),
      reviewAt: _reviewAt,
      updatedAt: DateTime.now(),
    ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil funcional salvo localmente.')));
  }

  @override
  Widget build(BuildContext context) => _loading
      ? const Center(child: CircularProgressIndicator())
      : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const ParentalInfoBanner(
              icon: Icons.record_voice_over_outlined,
              eyebrow: 'PERFIL CONTROLADO PELA FAMÍLIA',
              message: 'Um resumo funcional para orientar escola e profissionais. Compartilhe somente a versão e a finalidade necessárias.',
            ),
            const SizedBox(height: 14),
            ParentalSurface(
              child: Column(
                children: [
                  _field(_modes, 'Como se comunica?', Icons.forum_outlined, 'Ex.: símbolos, fala, gestos, olhar, dispositivo'),
                  _field(_access, 'Como acessa o dispositivo?', Icons.touch_app_outlined, 'Ex.: toque, acionador, teclado, ajuda'),
                  _field(_facilitators, 'O que facilita a participação?', Icons.thumb_up_alt_outlined, 'Ex.: antecipação visual, duas opções, tempo de resposta'),
                  _field(_avoid, 'O que devemos evitar?', Icons.block_outlined, 'Ex.: pressa, excesso de estímulos, tocar sem avisar'),
                  _field(_contingency, 'Se o dispositivo não estiver disponível', Icons.health_and_safety_outlined, 'Ex.: cartões impressos, gestos combinados, parceiro de comunicação'),
                  _field(_partners, 'Parceiros que já conhecem este perfil', Icons.groups_outlined, 'Ex.: família, escola, clínica'),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_repeat_outlined),
                    title: const Text('Revisar perfil em'),
                    subtitle: Text(_reviewAt == null ? 'Ainda não definido' : _date(_reviewAt!)),
                    onTap: () async {
                      final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)), initialDate: _reviewAt ?? DateTime.now().add(const Duration(days: 30)));
                      if (date != null) setState(() => _reviewAt = date);
                    },
                  ),
                  const SizedBox(height: 10),
                  _saveButton(_save, 'Salvar perfil funcional'),
                ],
              ),
            ),
          ],
        );

  Widget _field(TextEditingController controller, String label, IconData icon, String hint) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controller,
          maxLines: 3,
          decoration: parentalInputDecoration(labelText: label, hintText: hint, icon: icon),
        ),
      );
}

class _CommunicationPlanTab extends StatefulWidget {
  const _CommunicationPlanTab();

  @override
  State<_CommunicationPlanTab> createState() => _CommunicationPlanTabState();
}

class _CommunicationPlanTabState extends State<_CommunicationPlanTab> {
  final _title = TextEditingController();
  final _context = TextEditingController(text: 'Casa');
  final _goal = TextEditingController();
  final _strategy = TextEditingController();
  final _family = TextEditingController();
  final _school = TextEditingController();
  DateTime? _reviewAt;
  CarePlanStatus _status = CarePlanStatus.draft;
  bool _saving = false;

  @override
  void dispose() {
    for (final controller in [_title, _context, _goal, _strategy, _family, _school]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _goal.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe um título e um objetivo funcional.')));
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    await CareCoordinationStore.savePlan(CommunicationPlan(
      id: 'plan-${now.microsecondsSinceEpoch}',
      title: _title.text.trim(),
      context: _context.text.trim(),
      functionalGoal: _goal.text.trim(),
      strategy: _strategy.text.trim(),
      familyAction: _family.text.trim(),
      schoolAction: _school.text.trim(),
      reviewAt: _reviewAt,
      status: _status,
      createdAt: now,
      updatedAt: now,
    ));
    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Plano de comunicação salvo localmente.')));
  }

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ParentalInfoBanner(
            icon: Icons.track_changes_outlined,
            eyebrow: 'PLANO FUNCIONAL',
            message: 'Um objetivo observável, uma estratégia simples e um próximo passo para casa e escola. Não substitui o prontuário profissional.',
          ),
          const SizedBox(height: 14),
          ParentalSurface(
            child: Column(
              children: [
                _field(_title, 'Título do plano', Icons.title_outlined),
                _field(_context, 'Contexto', Icons.place_outlined),
                _field(_goal, 'Objetivo funcional', Icons.flag_outlined),
                _field(_strategy, 'Estratégia combinada', Icons.lightbulb_outline),
                _field(_family, 'Próximo passo para a família', Icons.home_outlined),
                _field(_school, 'Próximo passo para escola ou clínica', Icons.school_outlined),
                DropdownButtonFormField<CarePlanStatus>(
                  initialValue: _status,
                  decoration: parentalInputDecoration(labelText: 'Estado', icon: Icons.published_with_changes_outlined),
                  items: CarePlanStatus.values.map((value) => DropdownMenuItem(value: value, child: Text(_statusLabel(value)))).toList(),
                  onChanged: (value) => setState(() => _status = value ?? CarePlanStatus.draft),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_repeat_outlined),
                  title: const Text('Revisar em'),
                  subtitle: Text(_reviewAt == null ? 'Ainda não definido' : _date(_reviewAt!)),
                  onTap: () async {
                    final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)), initialDate: _reviewAt ?? DateTime.now().add(const Duration(days: 30)));
                    if (date != null) setState(() => _reviewAt = date);
                  },
                ),
                const SizedBox(height: 10),
                _saveButton(_saving ? null : _save, 'Salvar plano de comunicação'),
              ],
            ),
          ),
        ],
      );

  Widget _field(TextEditingController controller, String label, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(controller: controller, maxLines: 3, decoration: parentalInputDecoration(labelText: label, icon: icon)),
      );

  String _statusLabel(CarePlanStatus status) => switch (status) {
        CarePlanStatus.draft => 'Rascunho',
        CarePlanStatus.active => 'Ativo',
        CarePlanStatus.needsReview => 'Precisa de revisão',
        CarePlanStatus.archived => 'Arquivado',
      };
}

class _AgendaTab extends StatefulWidget {
  const _AgendaTab();

  @override
  State<_AgendaTab> createState() => _AgendaTabState();
}

class _AgendaTabState extends State<_AgendaTab> {
  final _title = TextEditingController();
  final _organization = TextEditingController();
  final _professional = TextEditingController();
  final _preparation = TextEditingController();
  DateTime _startsAt = DateTime.now().add(const Duration(days: 1));
  bool _reminder = true;
  List<Appointment> _appointments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final appointments = await CareCoordinationStore.loadAppointments();
    if (!mounted) return;
    setState(() {
      _appointments = appointments;
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final controller in [_title, _organization, _professional, _preparation]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_title.text.trim().isEmpty || _professional.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Informe o compromisso e o profissional.')));
      return;
    }
    final appointment = Appointment(
      id: 'appointment-${DateTime.now().microsecondsSinceEpoch}',
      title: _title.text.trim(),
      organization: _organization.text.trim(),
      professional: _professional.text.trim(),
      startsAt: _startsAt,
      durationMinutes: 45,
      preparation: _preparation.text.trim(),
      status: AppointmentStatus.scheduled,
      reminderEnabled: _reminder,
    );
    await CareCoordinationStore.saveAppointment(appointment);
    if (!mounted) return;
    setState(() {
      _appointments = [..._appointments, appointment]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
      _title.clear();
      _organization.clear();
      _professional.clear();
      _preparation.clear();
    });
  }

  @override
  Widget build(BuildContext context) => _loading
      ? const Center(child: CircularProgressIndicator())
      : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const ParentalInfoBanner(
              icon: Icons.calendar_month_outlined,
              eyebrow: 'AGENDA DE TRANSIÇÕES',
              message: 'Prepare a próxima atividade com horário, pessoa, local e o que levar. A agenda local continua disponível sem internet.',
            ),
            const SizedBox(height: 14),
            ParentalSurface(
              child: Column(
                children: [
                  _field(_title, 'Compromisso', Icons.event_note_outlined),
                  _field(_organization, 'Clínica, escola ou local', Icons.apartment_outlined),
                  _field(_professional, 'Profissional ou pessoa', Icons.person_outline),
                  _field(_preparation, 'Como se preparar?', Icons.checklist_outlined),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text('Quando'),
                    subtitle: Text('${_date(_startsAt)} às ${_startsAt.hour.toString().padLeft(2, '0')}:${_startsAt.minute.toString().padLeft(2, '0')}'),
                    onTap: _pickDateTime,
                  ),
                  SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Lembrar no aparelho'), value: _reminder, onChanged: (value) => setState(() => _reminder = value)),
                  _saveButton(_save, 'Adicionar à agenda'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_appointments.isEmpty)
              const ParentalInfoBanner(icon: Icons.event_available_outlined, eyebrow: 'SEM COMPROMISSOS', message: 'Adicione a próxima sessão, reunião ou transição para preparar a família.'),
            ..._appointments.map(_appointmentCard),
          ],
        );

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 730)), initialDate: _startsAt);
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_startsAt));
    if (time == null) return;
    setState(() => _startsAt = DateTime(date.year, date.month, date.day, time.hour, time.minute));
  }

  Widget _appointmentCard(Appointment appointment) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: ParentalSurface(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const CircleAvatar(child: Icon(Icons.event_outlined)),
            title: Text(appointment.title, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text('${appointment.organization}\n${appointment.professional} · ${_date(appointment.startsAt)}'),
            isThreeLine: true,
            trailing: Chip(label: Text(appointment.statusLabel)),
          ),
        ),
      );

  Widget _field(TextEditingController controller, String label, IconData icon) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(controller: controller, maxLines: 2, decoration: parentalInputDecoration(labelText: label, icon: icon)),
      );
}

Widget _saveButton(VoidCallback? onPressed, String label) => SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.save_outlined),
        label: Text(label),
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52), backgroundColor: AppTheme.professionalBackground, foregroundColor: Colors.white),
      ),
    );

String _date(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
