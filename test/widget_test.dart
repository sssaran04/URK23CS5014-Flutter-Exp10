import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_login_firestore/main.dart';
import 'package:user_login_firestore/screens/login_screen.dart';
import 'package:user_login_firestore/services/auth_service.dart';
import 'package:user_login_firestore/utils/password_hasher.dart';

const invalidMessage = 'Invalid email or password';

Future<void> pumpApp(
  WidgetTester tester,
  FakeFirebaseFirestore firestore,
) async {
  await firestore.collection('users').add({
    'name': 'Arun Kumar',
    'email': 'arun@example.com',
    'phone': '9876543210',
    'salt': 'testsalt',
    'password': hashPassword('testsalt', 'Arun@123'),
  });
  await tester.pumpWidget(
    UserLoginApp(authService: AuthService(firestore: firestore)),
  );
}

Future<void> login(WidgetTester tester, String email, String password) async {
  await tester.enterText(find.byType(TextFormField).at(0), email);
  await tester.enterText(find.byType(TextFormField).at(1), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() => firestore = FakeFirebaseFirestore());

  test('hasher gives the SHA-256 hex of salt + password', () {
    expect(
      hashPassword('abc', '123'),
      '6ca13d52ca70c883e0f0bb101e425a89e8624de51db2d2392593af6a84118090',
    );
  });

  testWidgets('valid login opens the dashboard', (tester) async {
    await pumpApp(tester, firestore);
    await login(tester, ' Arun@Example.com ', 'Arun@123');
    expect(find.text('Welcome, Arun Kumar'), findsOneWidget);
    expect(find.text('arun@example.com'), findsOneWidget);
    expect(find.text('9876543210'), findsOneWidget);
  });

  testWidgets('wrong password shows the generic error', (tester) async {
    await pumpApp(tester, firestore);
    await login(tester, 'arun@example.com', 'Wrong@123');
    expect(find.text(invalidMessage), findsOneWidget);
    expect(find.text('Welcome, Arun Kumar'), findsNothing);
  });

  testWidgets('unknown email shows the same error', (tester) async {
    await pumpApp(tester, firestore);
    await login(tester, 'nobody@example.com', 'Arun@123');
    expect(find.text(invalidMessage), findsOneWidget);
  });

  testWidgets('validation errors appear under the fields', (tester) async {
    await pumpApp(tester, firestore);
    await login(tester, '', '');
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);

    await login(tester, 'not-an-email', '123');
    expect(find.text('Enter a valid email address'), findsOneWidget);
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('logout returns to login and clears the stack', (tester) async {
    await pumpApp(tester, firestore);
    await login(tester, 'arun@example.com', 'Arun@123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Logout'));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Welcome, Arun Kumar'), findsNothing);
    expect(
      tester.state<NavigatorState>(find.byType(Navigator)).canPop(),
      isFalse,
    );
  });

  testWidgets('a Firestore error shows a readable message', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(authService: _FailingAuthService(firestore)),
      ),
    );
    await login(tester, 'arun@example.com', 'Arun@123');
    expect(find.text('Permission denied while reading users.'), findsOneWidget);
  });
}

class _FailingAuthService extends AuthService {
  _FailingAuthService(FirebaseFirestore firestore)
    : super(firestore: firestore);

  @override
  Future<Never> login(String email, String password) async {
    throw FirebaseException(plugin: 'firestore', code: 'permission-denied');
  }
}
