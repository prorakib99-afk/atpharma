import 'package:atpharma/features/auth/presentation/pages/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('login form submits identifier and password', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? submittedIdentifier;
    String? submittedPassword;

    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(
          onSignIn: (String identifier, String password, bool rememberMe) {
            submittedIdentifier = identifier;
            submittedPassword = password;
          },
        ),
      ),
    );

    final Finder fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'user@example.com');
    await tester.enterText(fields.at(1), 'secret-password');
    await tester.ensureVisible(find.text('Sign In'));
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    expect(submittedIdentifier, 'user@example.com');
    expect(submittedPassword, 'secret-password');
  });
}
