import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/domain/payroll/entity/salary_slip_entity.dart';
import 'package:hr_management_system/domain/payroll/repository/salary_slip_pdf_repository.dart';
import 'package:hr_management_system/main.dart';
import 'package:hr_management_system/presentation/payroll/provider/salary_slip_provider.dart';
import 'package:hr_management_system/presentation/payroll/screens/official_salary_slip_screen.dart';

import '../../helpers/attendance_test_data.dart';
import '../../helpers/localization_test_helper.dart';
import '../../helpers/payroll_test_data.dart';

class FakeSalarySlipPdfRepository implements SalarySlipPdfRepository {
  int generateCount = 0;
  int printCount = 0;
  int shareCount = 0;
  bool failGenerate = false;

  String? printedName;
  String? sharedFileName;

  @override
  Future<Uint8List> generatePdf(SalarySlipDocument document) async {
    generateCount++;

    if (failGenerate) {
      throw Exception('pdf generation failed');
    }

    return Uint8List.fromList([1, 2, 3]);
  }

  @override
  Future<void> printPdf(Uint8List pdf, {required String name}) async {
    printCount++;
    printedName = name;
  }

  @override
  Future<void> sharePdf(Uint8List pdf, {required String fileName}) async {
    shareCount++;
    sharedFileName = fileName;
  }
}

Future<void> pumpSlipScreen(
  WidgetTester tester,
  ProviderContainer container,
) async {
  tester.view.physicalSize = const Size(480, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    wrapWithLocalization(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          navigatorKey: navigatorKey,
          home: const OfficialSalarySlipScreen(employeeId: testEmployeeId),
        ),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  group('Official salary slip screen', () {
    testWidgets('renders the slip content', (tester) async {
      final repository = FakeSalarySlipPdfRepository();
      final container = await createPayrollTestContainer(
        extraOverrides: [
          salarySlipPdfRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await pumpSlipScreen(tester, container);

      expect(find.text('Official Salary Slip'), findsOneWidget);
      expect(find.text('CONFIDENTIAL PAY SLIP'), findsOneWidget);
      expect(find.text('HR Management System'), findsOneWidget);

      expect(find.text('Employee Name'), findsOneWidget);
      expect(find.text('Ahmed Mohamed'), findsOneWidget);
      expect(find.text('Department'), findsOneWidget);
      expect(find.text('Engineering'), findsOneWidget);
      expect(find.text('Month'), findsOneWidget);
      expect(find.text('September 2026'), findsOneWidget);
      expect(find.text('Reference'), findsOneWidget);
      expect(find.text('PAY-EMP001-202609'), findsOneWidget);

      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Amount (EGP)'), findsOneWidget);
      expect(find.text('Basic Salary'), findsOneWidget);
      expect(find.text('15,000'), findsOneWidget);
      expect(find.text('Attendance Work Days'), findsOneWidget);
      expect(find.text('Absence Days'), findsOneWidget);
      expect(find.textContaining('Overtime ('), findsOneWidget);
      expect(find.textContaining('Deductions ('), findsOneWidget);

      expect(find.text('Net Transfer Salary'), findsOneWidget);
      expect(find.text('Authorized Digital Stamp'), findsOneWidget);
      expect(find.text('HR Approved & Verified'), findsOneWidget);
      expect(find.text('Page 1 of 1'), findsOneWidget);

      expect(find.text('Print Salary Slip'), findsOneWidget);
      expect(find.text('Share Slip'), findsOneWidget);
    });

    testWidgets('generates and prints the salary slip', (tester) async {
      final repository = FakeSalarySlipPdfRepository();
      final container = await createPayrollTestContainer(
        extraOverrides: [
          salarySlipPdfRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await pumpSlipScreen(tester, container);

      await tester.tap(find.text('Print Salary Slip'));
      await tester.pumpAndSettle();

      expect(repository.generateCount, 1);
      expect(repository.printCount, 1);
      expect(repository.printedName, 'PAY-EMP001-202609');
      expect(repository.shareCount, 0);
    });

    testWidgets('generates and shares the salary slip', (tester) async {
      final repository = FakeSalarySlipPdfRepository();
      final container = await createPayrollTestContainer(
        extraOverrides: [
          salarySlipPdfRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await pumpSlipScreen(tester, container);

      await tester.tap(find.text('Share Slip'));
      await tester.pumpAndSettle();

      expect(repository.generateCount, 1);
      expect(repository.shareCount, 1);
      expect(repository.sharedFileName, 'PAY-EMP001-202609');
      expect(repository.printCount, 0);
    });

    testWidgets('shows an error when PDF generation fails', (tester) async {
      final repository = FakeSalarySlipPdfRepository();
      final container = await createPayrollTestContainer(
        extraOverrides: [
          salarySlipPdfRepositoryProvider.overrideWithValue(repository),
        ],
      );

      await pumpSlipScreen(tester, container);

      repository.failGenerate = true;

      await tester.tap(find.text('Print Salary Slip'));
      await tester.pumpAndSettle();

      expect(repository.printCount, 0);
      expect(find.text('Unable to generate the salary slip'), findsOneWidget);
    });
  });
}
