#!/bin/bash
# runs pure-dart tests with stub shim; usage: ./tools_run.sh
D=/tmp/dartpkg/bin/dart; cd /home/claude/repo
FILES="test/core/geo_test test/core/units_test test/core/time_utils_test test/core/result_test test/domain/lost_policy_test test/domain/distance_zone_test test/domain/tag_presence_test test/domain/tag_mode_test test/domain/geofence_tracker_test test/domain/trip_stats_test test/domain/alert_evaluator_test test/domain/history_utils_test test/data/tp_ble_protocol_test test/data/fake_ble_test test/data/fake_repos_test test/data/models_test"
{ i=0; for f in $FILES; do echo "import '../$f.dart' as t$i;"; i=$((i+1)); done
echo "import 'package:flutter_test/flutter_test.dart' as ft; Future<void> main() async {"
i=0; for f in $FILES; do echo "t$i.main();"; i=$((i+1)); done
echo "if (await ft.runAll()!=0) throw 'failures'; }"; } > /tmp/run_all.dart
mkdir -p tool && cp /tmp/run_all.dart tool/run_all.dart && $D --packages=.dart_tool/package_config.json tool/run_all.dart 2>&1 | tail -${1:-25}
