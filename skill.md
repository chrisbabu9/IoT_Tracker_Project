# skill.md — cheap tool recipes for this repo

## Rebuild repomix index (after re-running repomix)
```
awk '/<file path="/{match($0,/path="[^"]+"/);p=substr($0,RSTART+6,RLENGTH-7);s=NR}
/<\/file>/{if(p!=""){print p"\t"s"\t"NR"\t"(NR-s-1);p=""}}' repomix-output.xml > tools/repomix.index
```
Columns: path, start line, end line, body lines (sort by col 4 to find big files).

## Read one file / one symbol
```
REPOMIX=repomix-output.xml tools/rp.sh lib/domain/tag_presence.dart            # whole file
REPOMIX=repomix-output.xml tools/rp.sh lib/features/alerts/alert_monitor.dart '_onReport|offline'  # grep -n
```
Then `sed -n 'A,Bp'` on the real file (or repomix with offset S+A) for the window you need.

## Find who uses a symbol (no file reads)
`grep -n "activeTileUrlProvider" repomix-output.xml | cut -c1-120`

## Priority read order for a new task
status.md -> tests.md row -> `rp.sh` on the single file -> edit -> flutter analyze -> test.

## Environment notes
- Claude sandbox has NO Flutter/Dart SDK and no flutter.dev network access: analysis there is
  static (reading). Run `flutter analyze` and `flutter test` locally and paste only the failures.
- Cheap local triage: `flutter analyze --no-pub 2>&1 | grep -E "error|warning" | head -40`.
- Real-device checklist (production mode): see status.md "Manual QA".

## Where things are (one-liners)
- Entry: lib/main.dart -> app.dart (router + global hosts: SosBannerHost, AlertToastHost)
- Mode switch: auth_state.dart `simulationModeProvider` -> `bleServiceProvider`
- Cloud model (RTDB): users/{uid}/devices/{id}; devices/{id}/{meta,history,commands,config,lastSeenNear}
- BLE GATT: tp_ble_protocol.dart (service 7a1c0001; 0002 info, 0003 buzzer, 0004 status, 0005 cmd)
