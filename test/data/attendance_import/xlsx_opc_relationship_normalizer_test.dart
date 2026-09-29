import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hr_management_system/data/attendance_import/xlsx/xlsx_opc_relationship_normalizer.dart';

void main() {
  const normalizer = XlsxOpcRelationshipNormalizer();

  const workbookPart = 'xl/_rels/workbook.xml.rels';
  const packagePart = '_rels/.rels';

  Uint8List buildWorkbook({String workbookRels = '', String packageRels = ''}) {
    final archive = Archive()
      ..addFile(ArchiveFile('[Content_Types].xml', 0, utf8.encode('<Types/>')))
      ..addFile(ArchiveFile(workbookPart, 0, utf8.encode(workbookRels)))
      ..addFile(ArchiveFile(packagePart, 0, utf8.encode(packageRels)));

    return Uint8List.fromList(ZipEncoder().encode(archive)!);
  }

  String readPart(Uint8List bytes, String partName) {
    final part = ZipDecoder().decodeBytes(bytes).findFile(partName)!;

    part.decompress();

    return utf8.decode(part.content as List<int>);
  }

  String wrap(String relationships) =>
      '<Relationships>$relationships</Relationships>';

  String relationship(String target, {String type = 'worksheet'}) =>
      '<Relationship Id="rId1" Type="http://schemas.openxmlformats.org'
      '/officeDocument/2006/relationships/$type" Target="$target"/>';

  test('rewrites an absolute worksheet target under the xl base', () {
    final bytes = buildWorkbook(
      workbookRels: wrap(relationship('/xl/worksheets/sheet1.xml')),
    );

    expect(
      readPart(normalizer.normalize(bytes), workbookPart),
      wrap(relationship('worksheets/sheet1.xml')),
    );
  });

  test('rewrites an absolute styles target under the xl base', () {
    final bytes = buildWorkbook(
      workbookRels: wrap(relationship('/xl/styles.xml', type: 'styles')),
    );

    expect(
      readPart(normalizer.normalize(bytes), workbookPart),
      wrap(relationship('styles.xml', type: 'styles')),
    );
  });

  test('rewrites an absolute target that sits outside the xl base', () {
    final bytes = buildWorkbook(
      workbookRels: wrap(relationship('/docProps/core.xml')),
    );

    expect(
      readPart(normalizer.normalize(bytes), workbookPart),
      wrap(relationship('../docProps/core.xml')),
    );
  });

  test('rewrites absolute targets in the package relationships part', () {
    final bytes = buildWorkbook(
      packageRels: wrap(
        relationship('/xl/workbook.xml', type: 'officeDocument'),
      ),
    );

    expect(
      readPart(normalizer.normalize(bytes), packagePart),
      wrap(relationship('xl/workbook.xml', type: 'officeDocument')),
    );
  });

  test('rewrites single quoted targets', () {
    final bytes = buildWorkbook(
      workbookRels:
          "<Relationships><Relationship Id='rId1' "
          "Type='http://schemas.openxmlformats.org/officeDocument/2006"
          "/relationships/worksheet' Target='/xl/worksheets/sheet1.xml'/>"
          '</Relationships>',
    );

    expect(
      readPart(normalizer.normalize(bytes), workbookPart),
      contains('Target=\'worksheets/sheet1.xml\''),
    );
  });

  test('leaves relative targets untouched', () {
    final bytes = buildWorkbook(
      workbookRels: wrap(relationship('worksheets/sheet1.xml')),
      packageRels: wrap(
        relationship('xl/workbook.xml', type: 'officeDocument'),
      ),
    );

    expect(normalizer.normalize(bytes), bytes);
  });

  test('returns the original bytes for a payload that is not a zip', () {
    final bytes = Uint8List.fromList([1, 2, 3, 4]);

    expect(normalizer.normalize(bytes), bytes);
  });

  test('returns the original bytes when no relationship part exists', () {
    final bytes = Uint8List.fromList(ZipEncoder().encode(Archive())!);

    expect(normalizer.normalize(bytes), bytes);
  });
}
