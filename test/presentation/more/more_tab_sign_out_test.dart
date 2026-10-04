import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/auth/entity/user_entity.dart';
import 'package:hr_management_system/domain/auth/repository/auth_repo.dart';
import 'package:hr_management_system/injection.dart';
import 'package:hr_management_system/main.dart';
import '../../helpers/authorization_test_data.dart';
import '../../helpers/localization_test_helper.dart';
import 'package:hr_management_system/presentation/auth/providers/auth_state_provider.dart';
import 'package:hr_management_system/presentation/auth/providers/login_notifier.dart';
import 'package:hr_management_system/presentation/components/custom_button/custom_button.dart';
import 'package:hr_management_system/presentation/more/tab/more_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRepo implements AuthRepo {
  FakeAuthRepo({this.shouldFail = false});

  final bool shouldFail;

  int logoutCallCount = 0;

  @override
  Future<UserEntity> login({required String email, required String password}) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {
    logoutCallCount++;

    if (shouldFail) {
      throw Exception('sign out failed');
    }
  }

  @override
  Future<UserEntity?> getUserByUid(String uid) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateUserGroup({
    required String uid,
    required String employeeId,
    String? groupId,
  }) {
    throw UnimplementedError();
  }
}

void main() {
  Future<void> pumpMoreTab(WidgetTester tester, FakeAuthRepo authRepo) async {
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrapWithLocalization(
        ProviderScope(
          overrides: [
            fullAccessAuthorizationOverride(),
            authRepoProvider.overrideWithValue(authRepo),
            authStateProvider.overrideWith((ref) => Stream.value(null)),
          ],
          child: TestApp(
            navigatorKey: navigatorKey,
            home: const MoreTab(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  Future<void> openConfirmation(WidgetTester tester) async {
    await tester.tap(find.text('Sign Out Account'));
    await tester.pumpAndSettle();
  }

  /// The confirm button of the sign out dialog (`common.sign_out`).
  ///
  /// The dialog title (`more.sign_out`) renders the same words, so the button
  /// must be located through its `CustomButton` wrapper.
  Finder signOutConfirmButton() =>
      find.widgetWithText(CustomButton, 'Sign Out');

  group('More tab sign out', () {
    testWidgets('asks for confirmation before signing out', (tester) async {
      final authRepo = FakeAuthRepo();

      await pumpMoreTab(tester, authRepo);
      await openConfirmation(tester);

      // Dialog title + confirm button.
      expect(find.text('Sign Out'), findsNWidgets(2));
      expect(signOutConfirmButton(), findsOneWidget);
      expect(find.text('Delete'), findsNothing);
      expect(
        find.text('Are you sure you want to sign out of your account?'),
        findsOneWidget,
      );
      expect(authRepo.logoutCallCount, 0);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(authRepo.logoutCallCount, 0);
      expect(find.text('Sign Out Account'), findsOneWidget);
    });

    testWidgets('signs out and returns to the login screen', (tester) async {
      SharedPreferences.setMockInitialValues({'user': 'cached user'});
      final preferences = await SharedPreferences.getInstance();
      getIt.registerSingleton<SharedPreferences>(preferences);
      addTearDown(getIt.reset);

      final authRepo = FakeAuthRepo();

      await pumpMoreTab(tester, authRepo);
      await openConfirmation(tester);

      await tester.tap(signOutConfirmButton());
      await tester.pumpAndSettle();

      expect(authRepo.logoutCallCount, 1);
      expect(find.text('Sign Out Account'), findsNothing);
      expect(find.text('Human Resources Management System'), findsOneWidget);
      expect(preferences.getString('user'), isNull);
    });

    testWidgets('keeps the user signed in when signing out fails', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({'user': 'cached user'});
      final preferences = await SharedPreferences.getInstance();
      getIt.registerSingleton<SharedPreferences>(preferences);
      addTearDown(getIt.reset);

      final authRepo = FakeAuthRepo(shouldFail: true);

      await pumpMoreTab(tester, authRepo);
      await openConfirmation(tester);

      await tester.tap(signOutConfirmButton());
      await tester.pumpAndSettle();

      expect(authRepo.logoutCallCount, 1);
      expect(find.text('Sign Out Account'), findsOneWidget);
      expect(find.text('Human Resources Management System'), findsNothing);
      expect(find.text('Failed to sign out. Please try again'), findsOneWidget);
      expect(preferences.getString('user'), 'cached user');
    });
  });
}
