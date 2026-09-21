import 'package:flutter_test/flutter_test.dart';

import 'package:fala_comigo/core/services/parental_session_service.dart';

void main() {
  tearDown(() {
    ParentalSessionService.lock();
    ParentalSessionService.onExpired = null;
  });

  test('sessão começa bloqueada', () {
    expect(ParentalSessionService.isAuthenticated, isFalse);
    expect(ParentalSessionService.requireSession(), isFalse);
  });

  test('autenticação abre uma sessão temporária', () {
    ParentalSessionService.authenticate();

    expect(ParentalSessionService.isAuthenticated, isTrue);
    expect(ParentalSessionService.requireSession(), isTrue);
  });

  test('bloqueio invalida a sessão e cancela a expiração', () {
    ParentalSessionService.authenticate();
    ParentalSessionService.lock();

    expect(ParentalSessionService.isAuthenticated, isFalse);
    expect(ParentalSessionService.requireSession(), isFalse);
  });
}
