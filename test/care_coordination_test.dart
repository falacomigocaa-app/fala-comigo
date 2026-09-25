import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/features/parental_area/data/care_coordination.dart';

void main() {
  final reviewAt = DateTime.utc(2026, 10, 20);
  final now = DateTime.utc(2026, 9, 23, 20);

  test('preserva o perfil funcional na serialização', () {
    final profile = CommunicationProfile(
      subjectId: 'subject-1',
      communicationModes: 'Símbolos e gestos',
      preferredAccess: 'Toque com tempo de resposta',
      facilitators: 'Antecipação visual',
      avoid: 'Pressa',
      contingencyPlan: 'Cartões impressos',
      partners: 'Família e escola',
      reviewAt: reviewAt,
      updatedAt: now,
    );

    final restored = CommunicationProfile.fromMap(profile.toMap());

    expect(restored.subjectId, 'subject-1');
    expect(restored.communicationModes, 'Símbolos e gestos');
    expect(restored.reviewAt, reviewAt);
    expect(restored.avoid, 'Pressa');
  });

  test('preserva o estado do plano e as ações por rede', () {
    final plan = CommunicationPlan(
      id: 'plan-1',
      title: 'Pedido de pausa',
      context: 'Escola',
      functionalGoal: 'Pedir pausa antes de sair da atividade',
      strategy: 'Modelar o cartão sem exigir repetição',
      familyAction: 'Praticar em uma rotina natural',
      schoolAction: 'Disponibilizar o cartão na chegada',
      reviewAt: reviewAt,
      status: CarePlanStatus.active,
      createdAt: now,
      updatedAt: now,
    );

    final restored = CommunicationPlan.fromMap(plan.toMap());

    expect(restored.status, CarePlanStatus.active);
    expect(restored.statusLabel, 'Ativo');
    expect(restored.schoolAction, contains('chegada'));
  });

  test('mantém a agenda orientada à preparação da família', () {
    final appointment = Appointment(
      id: 'appointment-1',
      title: 'Sessão de fonoaudiologia',
      organization: 'Clínica Caminhos',
      professional: 'Profissional autorizado',
      startsAt: now,
      durationMinutes: 45,
      preparation: 'Levar a prancha de pausa',
      status: AppointmentStatus.confirmed,
      reminderEnabled: true,
    );

    final restored = Appointment.fromMap(appointment.toMap());

    expect(restored.status, AppointmentStatus.confirmed);
    expect(restored.statusLabel, 'Confirmado');
    expect(restored.preparation, 'Levar a prancha de pausa');
    expect(restored.reminderEnabled, isTrue);
  });
}
