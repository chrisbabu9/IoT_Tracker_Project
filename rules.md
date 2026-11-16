# rules.md — working rules for TrackPoint (read this first, ~1 min)

## Token rules (highest priority)
1. NEVER load whole files/`repomix-output.xml`. Use `tools/rp.sh <path> [regex]`
   (reads only that file's line range via `tools/repomix.index`). Regenerate the index after
   re-running repomix (command in skill.md).
2. Read `status.md` (architecture + bug register) before opening any code. Bugs are already
   located by file + symbol; open only that symbol (`rp.sh <file> 'symbolName'`, then `sed -n`).
3. Do not re-paste code in chat. Edit with `str_replace`; report as `file:symbol — change`.
4. One question per response at most; plan -> confirm -> change -> update status.md.
5. After each work item update ONLY the matching row in `status.md` (ID, state, date).

## Architecture rules
- Layers: `core/` (pure utils, no Flutter I/O) -> `domain/` (pure logic, no Firebase/BLE imports)
  -> `data/` (ble, firebase, models) -> `features/*` (UI + providers).
- Every Firebase/BLE dependency sits behind an interface (`*Repository`, `TagBleService`) with a
  Fake. New repo method => add to interface, Firebase impl AND Fake in the same change.
- Providers: no side effects inside `build()` of widgets (no `initialize()`, `setState`,
  navigation). Use `ref.listen` / `initState` / post-frame callbacks.
- UI strings go in `AppStrings`; colours via `Theme.of(context)`/`ColorScheme`, NOT `AppTheme.dark*`
  (light theme is currently broken for this reason — see B-20).
- Fakes must behave like real impls: emit current value first, never mutate stored lists.
- Never default `simulationModeProvider` to true in release (`kReleaseMode`).
- Never write simulated tags to production RTDB (use emulator or a `sim_` prefix + cleanup).

## Testing rules
- Pure logic (`core/`, `domain/`, `data/models`, `tp_ble_protocol`) = unit tests, no mocks.
- Widgets = `ProviderScope(overrides: [...Fake repos...])`; set
  `SharedPreferences.setMockInitialValues({})`; disable map tiles via
  `geofenceMapEnabledProvider`/`historyMapEnabledProvider` (must be consumed — B-24).
- Every new public function gets a row in `tests.md` and a test in the same PR.
- Run: `flutter analyze && flutter test --coverage`. Gate: no analyzer errors, tests green.

## Style
- Dart 3 records/switch expressions ok. Flutter >= 3.35 required (uses `CardThemeData`,
  `Color.withValues`, `DropdownButtonFormField.initialValue`) — set in pubspec (B-25).
- Keep files < 400 lines; split screens into widgets/ when larger (dashboard, map, pair already are).
