import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/payroll/repository/salary_slip_pdf_repository_impl.dart';
import 'package:hr_management_system/domain/payroll/entity/salary_slip_entity.dart';
import 'package:hr_management_system/domain/payroll/entity/salary_slip_texts.dart';

SalarySlipDocument buildPdfDocument({required bool rtl}) {
  const texts = SalarySlipTexts(
    appName: 'HR Management System',
    confidentialTitle: 'CONFIDENTIAL PAY SLIP',
    employeeNameLabel: 'Employee Name',
    departmentLabel: 'Department',
    monthLabel: 'Month',
    referenceLabel: 'Reference',
    descriptionLabel: 'Description',
    amountLabel: 'Amount (EGP)',
    stampLabel: 'Authorized Digital Stamp',
    approvedLabel: 'HR Approved & Verified',
    pageLabel: 'Page {current} of {total}',
  );

  const slip = SalarySlipEntity(
    employeeId: 'EMP001',
    employeeName: 'Ahmed Mohamed',
    departmentName: 'Engineering',
    year: 2026,
    month: 9,
    reference: 'PAY-EMP001-202609',
    basicSalary: 12500,
    overtimeHours: 5,
    overtimeAmount: 275,
    deductionHours: 0,
    totalDeductions: 0,
    presentDays: 20,
    absentDays: 2,
    workingDays: 22,
    netSalary: 12775,
  );

  return SalarySlipDocument(
    slip: slip,
    texts: texts,
    lines: const [
      SalarySlipLine(label: 'Basic Salary', value: '12,500'),
      SalarySlipLine(label: 'Attendance Work Days', value: '20 Days'),
      SalarySlipLine(label: 'Absence Days', value: '2 Days'),
      SalarySlipLine(label: 'Overtime (5 hrs)', value: '+275'),
      SalarySlipLine(label: 'Deductions (0 hrs)', value: '-0'),
    ],
    netLine: const SalarySlipLine(
      label: 'Net Transfer Salary',
      value: '12,775 EGP',
    ),
    periodValue: 'September 2026',
    rtl: rtl,
  );
}

class CmapFormat4 {
  final List<List<int>> segments;

  const CmapFormat4(this.segments);

  bool contains(int codePoint) {
    for (final segment in segments) {
      if (segment[0] <= codePoint && codePoint <= segment[1]) {
        return true;
      }
    }

    return false;
  }
}

CmapFormat4 parseCmap(ByteData data) {
  int readUint16(int offset) => data.getUint16(offset, Endian.big);
  int readUint32(int offset) => data.getUint32(offset, Endian.big);

  final numTables = readUint16(4);
  var cmapOffset = -1;

  for (var index = 0; index < numTables; index++) {
    final record = 12 + index * 16;
    final tag = String.fromCharCodes([
      data.getUint8(record),
      data.getUint8(record + 1),
      data.getUint8(record + 2),
      data.getUint8(record + 3),
    ]);

    if (tag == 'cmap') {
      cmapOffset = readUint32(record + 8);
    }
  }

  expect(cmapOffset, greaterThan(0));

  final numEncodings = readUint16(cmapOffset + 2);
  var subtable = -1;

  for (var index = 0; index < numEncodings; index++) {
    final record = cmapOffset + 4 + index * 8;
    final platform = readUint16(record);
    final offset = readUint32(record + 4) + cmapOffset;

    if (platform == 3 && readUint16(offset) == 4) {
      subtable = offset;
    }
  }

  expect(subtable, greaterThan(0));

  final segCountX2 = readUint16(subtable + 6);
  final segCount = segCountX2 ~/ 2;
  final endBase = subtable + 14;
  final startBase = endBase + segCountX2 + 2;

  final segments = <List<int>>[];

  for (var index = 0; index < segCount; index++) {
    segments.add([
      readUint16(startBase + index * 2),
      readUint16(endBase + index * 2),
    ]);
  }

  return CmapFormat4(segments);
}

CmapFormat4 loadFontCmap(String fileName) {
  final bytes = File('assets/fonts/$fileName').readAsBytesSync();

  return parseCmap(ByteData.sublistView(bytes));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Salary slip PDF', () {
    test('generates an English PDF with the embedded font', () async {
      final bytes = await SalarySlipPdfRepositoryImpl().generatePdf(
        buildPdfDocument(rtl: false),
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.sublist(0, 5)), startsWith('%PDF'));

      final content = String.fromCharCodes(bytes);

      expect(content, contains('/FontFile2'));
      expect(content, contains('Tajawal'));
    });

    test('generates an Arabic right-to-left PDF with the embedded font', () async {
      final bytes = await SalarySlipPdfRepositoryImpl().generatePdf(
        buildPdfDocument(rtl: true),
      );

      expect(bytes, isNotEmpty);
      expect(String.fromCharCodes(bytes.sublist(0, 5)), startsWith('%PDF'));

      final content = String.fromCharCodes(bytes);

      expect(content, contains('/FontFile2'));
      expect(content, contains('Tajawal'));
    });
  });

  group('Tajawal font coverage', () {
    for (final fileName in const ['Tajawal-Regular.ttf', 'Tajawal-Bold.ttf']) {
      test('$fileName covers Latin and Arabic base characters', () {
        final cmap = loadFontCmap(fileName);

        for (final codePoint in <int>[0x20, 0x41, 0x5A, 0x61, 0x7A, 0x30, 0x39]) {
          expect(
            cmap.contains(codePoint),
            isTrue,
            reason: 'missing ${codePoint.toRadixString(16)}',
          );
        }

        for (var codePoint = 0x0621; codePoint <= 0x063A; codePoint++) {
          expect(
            cmap.contains(codePoint),
            isTrue,
            reason: 'missing ${codePoint.toRadixString(16)}',
          );
        }

        for (var codePoint = 0x0640; codePoint <= 0x064A; codePoint++) {
          expect(
            cmap.contains(codePoint),
            isTrue,
            reason: 'missing ${codePoint.toRadixString(16)}',
          );
        }

        for (final codePoint in <int>[0x060C, 0x061F, 0x0660, 0x0669]) {
          expect(
            cmap.contains(codePoint),
            isTrue,
            reason: 'missing ${codePoint.toRadixString(16)}',
          );
        }

        for (final codePoint in <int>[0xFEEC, 0xFEDF, 0xFEF5, 0xFEFB]) {
          expect(
            cmap.contains(codePoint),
            isTrue,
            reason: 'missing presentation form ${codePoint.toRadixString(16)}',
          );
        }
      });
    }
  });
}
