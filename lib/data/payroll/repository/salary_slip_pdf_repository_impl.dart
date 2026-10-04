import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:hr_management_system/domain/payroll/entity/salary_slip_entity.dart';
import 'package:hr_management_system/domain/payroll/entity/salary_slip_texts.dart';
import 'package:hr_management_system/domain/payroll/repository/salary_slip_pdf_repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

final PdfColor _inkColor = PdfColor.fromHex('#111827');
final PdfColor _mutedColor = PdfColor.fromHex('#64748B');
final PdfColor _borderColor = PdfColor.fromHex('#E2E8F0');
final PdfColor _softColor = PdfColor.fromHex('#F8FAFC');
final PdfColor _darkBlueColor = PdfColor.fromHex('#0F172A');
final PdfColor _primaryColor = PdfColor.fromHex('#2563EB');
final PdfColor _netRowColor = PdfColor.fromHex('#EAF3FF');

class SalarySlipPdfRepositoryImpl implements SalarySlipPdfRepository {
  static const String _regularFontPath = 'assets/fonts/Tajawal-Regular.ttf';
  static const String _boldFontPath = 'assets/fonts/Tajawal-Bold.ttf';

  Future<ByteData>? _regularFont;
  Future<ByteData>? _boldFont;

  @override
  Future<Uint8List> generatePdf(SalarySlipDocument document) async {
    final theme = await _buildTheme();
    final pdf = pw.Document(theme: theme);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        textDirection: document.rtl
            ? pw.TextDirection.rtl
            : pw.TextDirection.ltr,
        build: (context) => _buildContent(document),
        footer: (context) => _buildFooter(document, context),
      ),
    );

    return pdf.save();
  }

  @override
  Future<void> printPdf(Uint8List pdf, {required String name}) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdf,
      name: name,
      format: PdfPageFormat.a4,
    );
  }

  @override
  Future<void> sharePdf(Uint8List pdf, {required String fileName}) async {
    final directory = await getTemporaryDirectory();
    final safeName = fileName.endsWith('.pdf') ? fileName : '$fileName.pdf';
    final file = File('${directory.path}/$safeName');

    await file.writeAsBytes(pdf, flush: true);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], title: safeName),
    );
  }

  Future<pw.ThemeData> _buildTheme() async {
    _regularFont ??= rootBundle.load(_regularFontPath);
    _boldFont ??= rootBundle.load(_boldFontPath);

    return pw.ThemeData.withFont(
      base: pw.Font.ttf(await _regularFont!),
      bold: pw.Font.ttf(await _boldFont!),
    );
  }

  List<pw.Widget> _buildContent(SalarySlipDocument document) {
    return [
      _buildHeader(document.texts),
      pw.SizedBox(height: 16),
      _buildMetaGrid(document),
      pw.SizedBox(height: 20),
      _buildTable(document),
      pw.SizedBox(height: 24),
      _buildApprovals(document.texts),
    ];
  }

  pw.Widget _buildFooter(SalarySlipDocument document, pw.Context context) {
    final label = document.texts.pageLabel
        .replaceAll('{current}', '${context.pageNumber}')
        .replaceAll('{total}', '${context.pagesCount}');

    return pw.Container(
      alignment: pw.Alignment.center,
      child: pw.Text(
        label,
        style: pw.TextStyle(fontSize: 8, color: _mutedColor),
      ),
    );
  }

  pw.Widget _buildHeader(SalarySlipTexts texts) {
    return pw.Center(
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            texts.confidentialTitle,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: _mutedColor,
              letterSpacing: 1.5,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            texts.appName,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: _inkColor,
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Divider(height: 12, thickness: 1, color: _borderColor),
        ],
      ),
    );
  }

  pw.Widget _buildMetaGrid(SalarySlipDocument document) {
    final texts = document.texts;

    return pw.Column(
      children: [
        pw.Row(
          children: [
            _metaCell(texts.employeeNameLabel, document.slip.employeeName),
            pw.SizedBox(width: 8),
            _metaCell(texts.departmentLabel, document.slip.departmentName),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Row(
          children: [
            _metaCell(texts.monthLabel, document.periodValue),
            pw.SizedBox(width: 8),
            _metaCell(texts.referenceLabel, document.slip.reference),
          ],
        ),
      ],
    );
  }

  pw.Widget _metaCell(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: _softColor,
          border: pw.Border.all(color: _borderColor, width: 0.75),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(fontSize: 8, color: _mutedColor),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              value,
              maxLines: 2,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: _inkColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget _buildTable(SalarySlipDocument document) {
    final texts = document.texts;
    final rtl = document.rtl;

    final headerStyle = pw.TextStyle(
      fontSize: 9,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.white,
    );
    final bodyStyle = pw.TextStyle(fontSize: 10, color: _inkColor);
    final netStyle = pw.TextStyle(
      fontSize: 11,
      fontWeight: pw.FontWeight.bold,
      color: _primaryColor,
    );

    final labelAlignment = rtl ? pw.Alignment.centerRight : pw.Alignment.centerLeft;
    final valueAlignment = rtl ? pw.Alignment.centerLeft : pw.Alignment.centerRight;

    pw.Widget cell(
      String text,
      pw.TextStyle style,
      pw.Alignment alignment,
    ) {
      return pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: pw.Align(
          alignment: alignment,
          child: pw.Text(text, maxLines: 2, style: style),
        ),
      );
    }

    List<pw.Widget> cells(List<pw.Widget> order) {
      return rtl ? order.reversed.toList() : order;
    }

    return pw.Table(
      border: pw.TableBorder.all(color: _borderColor, width: 0.75),
      children: [
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _darkBlueColor),
          children: cells([
            cell(texts.descriptionLabel, headerStyle, labelAlignment),
            cell(texts.amountLabel, headerStyle, valueAlignment),
          ]),
        ),
        for (final line in document.lines)
          pw.TableRow(
            children: cells([
              cell(line.label, bodyStyle, labelAlignment),
              cell(line.value, bodyStyle, valueAlignment),
            ]),
          ),
        pw.TableRow(
          decoration: pw.BoxDecoration(color: _netRowColor),
          children: cells([
            cell(document.netLine.label, netStyle, labelAlignment),
            cell(document.netLine.value, netStyle, valueAlignment),
          ]),
        ),
      ],
    );
  }

  pw.Widget _buildApprovals(SalarySlipTexts texts) {
    pw.Widget badge(String label) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: _borderColor, width: 1),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
            color: _mutedColor,
          ),
        ),
      );
    }

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [badge(texts.stampLabel), badge(texts.approvedLabel)],
    );
  }
}
