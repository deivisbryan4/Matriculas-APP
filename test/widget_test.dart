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
          ChangeNotifierProvider(create: (_) => SystemProvider()),
        ],
        child: const UnajMatriculaApp(),
      ),
    );

    expect(find.text('UNAJ'), findsWidgets);
    expect(find.text('Sistema de Matriculas'), findsWidgets);
    expect(find.text('Ingresar'), findsOneWidget);
  });
}
