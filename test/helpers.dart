import 'package:trackpoint/data/models/tag_report.dart';

/// Compact TagReport factory for tests.
TagReport rep({
  int fix = 1,
  double? lat,
  double? lon,
  int? acc,
  int bat = 80,
  int csq = 20,
  String mode = 'away',
  String why = 'periodic',
  int srv = 1000,
}) =>
    TagReport(
      fix: fix,
      lat: lat,
      lon: lon,
      acc: acc,
      bv: 3.9,
      bat: bat,
      csq: csq,
      mode: mode,
      why: why,
      srv: srv,
    );

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));
