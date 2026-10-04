import 'dart:typed_data';

import 'package:hr_management_system/domain/payroll/entity/salary_slip_entity.dart';

abstract class SalarySlipPdfRepository {
  Future<Uint8List> generatePdf(SalarySlipDocument document);

  Future<void> printPdf(Uint8List pdf, {required String name});

  Future<void> sharePdf(Uint8List pdf, {required String fileName});
}
