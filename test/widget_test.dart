import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:unaj_matricula/main.dart';
import 'package:unaj_matricula/providers.dart';

void main() {
  testWidgets('muestra el login del sistema de matricula', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => EnrollmentProvider()),
        ],
        child: const UnajMatriculaApp(),
      ),
    );

    expect(find.text('UNAJ'), findsOneWidget);
    expect(find.text('Sistema de Matricula'), findsOneWidget);
    expect(find.text('INGRESAR'), findsOneWidget);
  });
}
