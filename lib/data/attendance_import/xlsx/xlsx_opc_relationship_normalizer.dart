import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';

class XlsxOpcRelationshipNormalizer {
  const XlsxOpcRelationshipNormalizer();

  static const String workbookRelationshipsPart = 'xl/_rels/workbook.xml.rels';

  static const String packageRelationshipsPart = '_rels/.rels';

  static final RegExp _doubleQuotedTarget = RegExp('(Target=")([^"]*)(")');

  static final RegExp _singleQuotedTarget = RegExp("(Target=')([^']*)(')");

  Uint8List normalize(Uint8List bytes) {
    final Archive archive;

    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (error) {
      return bytes;
    }

    final workbookPatched = _patchPart(archive, workbookRelationshipsPart);
    final packagePatched = _patchPart(archive, packageRelationshipsPart);

    if (!workbookPatched && !packagePatched) {
      return bytes;
    }

    final List<int>? encoded;

    try {
      encoded = ZipEncoder().encode(archive);
    } catch (error) {
      return bytes;
    }

    if (encoded == null) {
      return bytes;
    }

    return Uint8List.fromList(encoded);
  }

  bool _patchPart(Archive archive, String partName) {
    final part = archive.findFile(partName);

    if (part == null) {
      return false;
    }

    part.decompress();

    final content = part.content;

    if (content is! List<int>) {
      return false;
    }

    final String original;

    try {
      original = utf8.decode(content);
    } catch (error) {
      return false;
    }

    final patched = _rewriteTargets(original, _baseDirectoryOf(partName));

    if (patched == original) {
      return false;
    }

    final rewritten = utf8.encode(patched);

    archive.addFile(ArchiveFile(partName, rewritten.length, rewritten));

    return true;
  }

  String _baseDirectoryOf(String partName) {
    const marker = '/_rels/';
    final index = partName.indexOf(marker);

    if (index == -1) {
      return '';
    }

    return partName.substring(0, index);
  }

  String _rewriteTargets(String xml, String base) {
    return xml
        .replaceAllMapped(
          _doubleQuotedTarget,
          (match) => '${match[1]}${_relativize(match[2]!, base)}${match[3]}',
        )
        .replaceAllMapped(
          _singleQuotedTarget,
          (match) => '${match[1]}${_relativize(match[2]!, base)}${match[3]}',
        );
  }

  String _relativize(String target, String base) {
    if (!target.startsWith('/')) {
      return target;
    }

    final path = target.substring(1);

    if (base.isEmpty) {
      return path;
    }

    if (path.startsWith('$base/')) {
      return path.substring(base.length + 1);
    }

    var depth = 0;
    var directory = base;

    while (directory.isNotEmpty) {
      depth++;

      final separator = directory.indexOf('/');

      directory = separator == -1 ? '' : directory.substring(separator + 1);
    }

    return '${'../' * depth}$path';
  }
}
