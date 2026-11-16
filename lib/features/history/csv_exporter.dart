import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Hands a CSV file to the OS share sheet. Replaced by a fake in tests.
abstract class CsvExporter {
  Future<void> share({required String fileName, required String csv});
}

class ShareCsvExporter implements CsvExporter {
  const ShareCsvExporter();

  @override
  Future<void> share({required String fileName, required String csv}) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csv);
    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/csv')],
      subject: fileName,
    );
  }
}
