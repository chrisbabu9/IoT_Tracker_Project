/// Centralized UI string constants for localization readiness.
class AppStrings {
  AppStrings._();

  // App & General
  static const String appTitle = 'TrackPoint';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String save = 'Save';
  static const String saved = 'Saved';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
  static const String back = 'Back';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String unknown = 'Unknown';
  static const String never = 'Never';

  // Auth & Account
  static const String signIn = 'Sign In';
  static const String signUp = 'Sign Up';
  static const String signOut = 'Sign Out';
  static const String deleteAccount = 'Delete Account';
  static const String deleteAccountConfirmation =
      'Are you sure you want to permanently delete your account and all associated tags? This cannot be undone.';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String currentPassword = 'Current Password';
  static const String newPassword = 'New Password (min 10 chars)';
  static const String forgotPassword = 'Forgot password?';
  static const String resetPassword = 'Reset Password';
  static const String resetPasswordSent =
      'Password reset link has been sent to your email.';
  static const String noAccountPrompt = "Don't have an account? Sign Up";
  static const String alreadyHaveAccount = 'Already have an account? Sign In';
  static const String invalidEmail = 'Please enter a valid email address.';
  static const String passwordTooShort = 'Password must be at least 10 characters long.';
  static const String passwordsDoNotMatch = 'Passwords do not match.';
  static const String enterCurrentPassword = 'Enter your current password.';
  static const String account = 'Account';
  static const String displayTimezone = 'Display Timezone';
  static const String changePassword = 'Change Password';
  static const String passwordChanged = 'Password successfully changed.';

  // Navigation
  static const String navHome = 'Home';
  static const String navMap = 'Map';
  static const String navFind = 'Find';
  static const String navAlerts = 'Alerts';
  static const String navMore = 'More';

  // Presence & Modes
  static const String presenceNear = 'Near (BLE)';
  static const String presenceAway = 'Away (Live)';
  static const String presenceLost = 'Lost Mode';
  static const String presenceSos = 'SOS Active';
  static const String presenceOffline = 'Offline';
  static const String presenceNeverConnected = 'Never Connected';

  // Tag & Hardware
  static const String noFixYet = 'No GPS fix yet';
  static const String accuracyEst = 'est.';
  static const String tagAlreadyClaimed =
      'This tag already belongs to another account.';
  static const String pairingTimeout =
      'No tag found. Make sure the tag button was clicked and is flashing.';
  static const String bondFailed = 'Bluetooth bonding was rejected or failed.';
  static const String tagClaimedSuccess = 'Tag paired and claimed successfully!';
  static const String deviceName = 'Device Name';
  static const String deviceId = 'Device ID';
  static const String firmwareVersion = 'Firmware';

  // Commands
  static const String commandPending = 'Pending – waiting for tag to check in';
  static const String commandSent = 'Sent – waiting for tag acknowledgement';
  static const String commandCompleted = 'Completed – tag confirmed';
  static const String commandFailed = 'Failed';
  static const String commandExpired = 'Expired – tag did not respond in time';
  static const String commandCancelled = 'Cancelled';
  static const String buzzerOn = 'I AM HERE';
  static const String buzzerOff = 'STOP BUZZER';
  static const String pollDelayNotice =
      'Commands apply on the tag’s next radio check-in (away/lost/sos).';

  // Lost Mode & SOS
  static const String lostModeTitle = 'Lost Mode';
  static const String lostModeDesc =
      'Lost Mode wakes the GPS and LTE modem up at accelerated intervals based on battery level.';
  static const String sosBanner = '🚨 SOS ACTIVE – Tag is reporting location continuously';

  // Distance Zones
  static const String zoneRightHere = 'Right here';
  static const String zoneVeryNear = 'Very near';
  static const String zoneNear = 'Near';
  static const String zoneFar = 'Far';
  static const String zoneEdgeOfRange = 'Edge of range';
  static const String zoneDisclaimer =
      'Distance is approximate; walls, metal, and bodies change signal strength.';

  // Onboarding
  static const String onboardingSkip = 'Skip';
  static const String onboardingNext = 'Next';
  static const String onboardingGetStarted = 'Get Started';
  static const String onboardingTitle1 = 'Smart Belonging Protection';
  static const String onboardingDesc1 =
      'TrackPoint pairs BLE for pinpoint nearby search with cellular GPS for global coverage when out of range.';
  static const String onboardingTitle2 = 'Essential Permissions';
  static const String onboardingDesc2 =
      'Bluetooth is needed to connect to your tag. Location and Notifications allow distance estimation and left-behind anti-lost alerts.';
  static const String onboardingTitle3 = 'Tag Hardware Button Guide';
  static const String onboardingDesc3 =
      'The single button on your tag gives you full control with simple clicks:';
  static const String buttonGuide1ClickTitle = '1 Click';
  static const String buttonGuide1ClickDesc =
      'If unpaired: starts 60-second pairing window.\nIf paired: silences buzzer and shows battery level on LED.';
  static const String buttonGuide2ClicksTitle = '2 Clicks';
  static const String buttonGuide2ClicksDesc =
      'Toggles Lost Mode on/off directly from the tag.';
  static const String buttonGuideHoldTitle = 'Hold 2 Seconds';
  static const String buttonGuideHoldDesc =
      'Toggles emergency SOS mode: reports location every 1 minute for 10 minutes.';
  static const String buttonGuideGuardTitle = 'Accident Guard';
  static const String buttonGuideGuardDesc =
      '3+ clicks or a 0.8–2.0s hold are rejected as accidental presses with an error tick.';

  // Pairing Flow
  static const String pairTagTitle = 'Add New Tag';
  static const String pairStep1Title = 'Prepare Your Tag';
  static const String pairStep1Instruction =
      'Press the button on your TrackPoint tag once. The LED will begin flashing for 60 seconds.';
  static const String pairCountdownPrefix = 'Pairing window: ';
  static const String pairCountdownSeconds = 's remaining';
  static const String pairScanning = 'Searching for nearby TrackPoint tags...';
  static const String pairAvailableTags = 'Discovered Tags';
  static const String pairConnecting = 'Connecting and establishing secure bond...';
  static const String pairBonding = 'Bonding with device...';
  static const String pairReadingInfo = 'Reading device credentials...';
  static const String pairClaiming = 'Registering tag ownership...';
  static const String pairNameYourTag = 'Name Your Tag';
  static const String pairNamePlaceholder = 'e.g., Keys, Leather Wallet, Travel Bag';
  static const String pairFinish = 'Complete Setup';
  static const String pairPermissionError =
      'Bluetooth and Location permissions are required to scan and pair tags.';
  static const String pairScanTimeout =
      'No tag found in pairing mode. Please press the tag button once and tap Retry.';
  static const String pairBondRejected =
      'Bluetooth pairing was rejected or cancelled. Please try again.';
  static const String pairAlreadyOwned =
      'This tag already belongs to another account.';
  static const String pairNoInternet =
      'Network error. Please check your internet connection and try again.';

  // Home & Device List
  static const String myTags = 'My Tags';
  static const String noTagsYet = 'No tags added yet';
  static const String noTagsSubtitle =
      'Keep track of your wallet, keys, backpack, and belongings.';
  static const String addYourFirstTag = 'Add Your First Tag';
  static const String renameTag = 'Rename Tag';
  static const String removeTag = 'Remove Tag';
  static const String removeTagConfirmTitle = 'Remove Tag?';
  static const String removeTagConfirmMessage =
      'This will remove the tag from your account and unbond the Bluetooth connection. Cloud history will be preserved.';
  static const String tagRenamedSuccess = 'Tag renamed successfully';
  static const String tagRemovedSuccess = 'Tag removed from your account';

  // Dashboard
  static const String dashboardTitle = 'Dashboard';
  static const String statusCard = 'Device Status';
  static const String locationCard = 'Location';
  static const String lastCommunication = 'Last communication';
  static const String gpsFix = 'GPS Fix';
  static const String gpsFixYes = 'Fix acquired';
  static const String gpsFixNo = 'No GPS fix yet';
  static const String satellites = 'Satellites';
  static const String batteryVoltage = 'Battery';
  static const String cellularSignal = 'Cellular';
  static const String cellularUnknown = 'No cellular info';
  static const String latitude = 'Latitude';
  static const String longitude = 'Longitude';
  static const String estimatedAccuracy = 'Est. accuracy';
  static const String alertLowBattery = 'Low Battery';
  static const String alertNotReporting = 'Not Reporting';
  static const String alertNoCellular = 'No Cellular Info';
  static const String copyCoordinates = 'Copy Coordinates';
  static const String coordinatesCopied = 'Coordinates copied';
  static const String openInMaps = 'Open in Maps';
  static const String lastGpsUpdate = 'Last GPS update';
  static const String noLocationAvailable = 'No location available';
  static const String phoneDistance = 'Distance from phone';
  static const String phoneDistanceUnavailable = 'Phone location unavailable';
  static const String lastSeenNearLabel = 'Where you last had it nearby';
  static const String lastSeenNearAge = 'Last seen nearby';

  // Map
  static const String mapTitle = 'Map';
  static const String centerOnTag = 'Center on tag';
  static const String followTag = 'Follow tag';
  static const String showPath24h = 'Show 24 h path';
  static const String roadMap = 'Road';
  static const String satellite = 'Satellite';
  static const String staleFixBanner = 'Position is {age} old';
  static const String tapToPickPoint = 'Tap map to pick a point';
  static const String pickedPointLat = 'Latitude';
  static const String pickedPointLon = 'Longitude';
  static const String pickedPointInvalidLat = 'Latitude must be between -90 and 90.';
  static const String pickedPointInvalidLon = 'Longitude must be between -180 and 180.';
  static const String tagMarkerLabel = 'Tag';
  static const String phoneMarkerLabel = 'You';
  static const String noTagSelected = 'No tag selected';
  static const String pathLoadError = 'Could not load path history';

  // Battery chart / 24 h stats
  static const String batteryChart = 'Battery (24 h)';
  static const String lowBatteryThreshold = 'Low battery threshold';
  static const String stats24h = 'Last 24 hours';
  static const String statFixes = 'Fixes';
  static const String statDistance = 'Distance';
  static const String statMovingTime = 'Moving time';
  static const String statAvgSpeed = 'Avg speed';
  static const String statTopSpeed = 'Top speed';
  static const String statFirstFix = 'First fix';
  static const String statLastFix = 'Last fix';
  static const String noStats24h = 'No GPS fixes in the last 24 h';

  // Find my tag (M4)
  static const String findTitle = 'Find my tag';
  static const String findNoTag = 'Add a tag to use Find.';
  static const String findMeasuring = 'Measuring signal…';
  static const String findNotInRange = 'Not in Bluetooth range';
  static const String findNotInRangeHint =
      'The tag is out of Bluetooth range. You can still ring it through the internet, or open the map to see where it last reported.';
  static const String findShowOnMap = 'Show on map';
  static const String findTrendWarmer = 'Getting warmer';
  static const String findTrendColder = 'Getting colder';
  static const String findTrendSteady = 'Holding steady';
  static const String findBuzzerRinging = 'Buzzer is ringing';
  static const String findBuzzerFailed = 'Could not send the request. Please try again.';
  static const String findViaInternet = 'Sent through the internet';
  static const String findExpiresIn = 'Expires in';
  static const String findSimulation = 'Simulation controls';

  // Lost Mode & SOS (M5)
  static const String lostModeOn = 'Lost Mode is ON';
  static const String lostModeOff = 'Lost Mode is OFF';
  static const String lostModeWaiting = 'Waiting for tag...';
  static const String lostModeStopWaiting = 'Stop waiting';
  static const String lostModeConfirmTitle = 'Turn on Lost Mode?';
  static const String lostModeConfirmBody =
      'The tag will report its location every 1 to 5 minutes until you turn Lost Mode off. This uses a lot of battery.';
  static const String lostModeConfirmAction = 'Turn on';
  static const String lostModeWarning =
      'Heavy use drains the battery quickly. Turn Lost Mode off as soon as you have found your tag.';
  static const String lostModeTableTitle = 'Reporting interval by battery';
  static const String lostModeCurrent = 'Current';
  static const String lostModeBatteryUnknown = 'Battery level unknown';
  static const String lostModeRequestNow = 'Request location now';
  static const String lostModeBleNoConfirm =
      'The tag did not confirm over Bluetooth. Please try again.';
  static const String lostModeFailed =
      'Could not send the request. Please try again.';
  static const String lostModeButtonNote =
      'You can also turn Lost Mode on or off with a double click on the tag button.';
  static const String quickLostModeSubtitle =
      'Track your tag more often when it is lost';
  static const String sosBannerTitle = 'SOS ACTIVE';
  static const String sosLastLocation = 'Last location';
  static const String sosNoFix = 'No GPS fix yet';
  static const String sosBattery = 'Battery';
  static const String sosOpenMap = 'Open map';

  // History (M5)
  static const String historyTitle = 'History';
  static const String historyAll = 'All';
  static const String historyPickDate = 'Pick a date';
  static const String historyClearDate = 'Show all';
  static const String historyColDate = 'Date';
  static const String historyColTime = 'Time';
  static const String historyColLat = 'Latitude';
  static const String historyColLon = 'Longitude';
  static const String historyColAccuracy = 'Est. accuracy';
  static const String historyColBattery = 'Battery';
  static const String historyColMode = 'Mode / why';
  static const String historyEmpty = 'No history yet for this view.';
  static const String historyPage = 'Page';
  static const String historyPrev = 'Previous';
  static const String historyNext = 'Next';
  static const String historyRecords = 'records';
  static const String historyExportCsv = 'Export CSV';
  static const String historyExportHint =
      'Without a date, the 500 most recent records are exported.';
  static const String historyNothingToExport = 'Nothing to export.';
  static const String historyExportFailed = 'Could not export the file.';
  static const String historyDeleteDay = 'Delete this day';
  static const String historyDeleteTitle = 'Delete this day’s history?';
  static const String historyDeleteBody =
      'All records of the selected day will be permanently removed. This cannot be undone.';
  static const String historyDeleted = 'Deleted records:';
  static const String historyDeleteFailed = 'Could not delete the records.';
  static const String historyPathTitle = 'Path';
  static const String historyPathNote24h = 'Showing the last 24 hours';
  static const String historyPathNoPoints = 'No GPS points for this view.';
  static const String historyReplay = 'Route replay';
  static const String historyPlay = 'Play';
  static const String historyPause = 'Pause';
  static const String historySpeed = 'Speed';
  static const String historyLoadError = 'Could not load history.';
  static const String quickHistorySubtitle = 'Past locations, path and export';

  // Geofence (M5)
  static const String geofenceTitle = 'Geofence';
  static const String geofenceNotSet = 'Not set. Tap to create one.';
  static const String geofenceOff = 'Off';
  static const String geofenceInside = 'Inside';
  static const String geofenceOutside = 'Outside';
  static const String geofenceFromCentre = 'from centre';
  static const String geofenceWaitingFix = 'Waiting for a GPS position';
  static const String geofenceEnable = 'Notify me when the tag leaves this area';
  static const String geofenceRadius = 'Radius';
  static const String geofenceUseTag = 'Use tag position';
  static const String geofencePick = 'Pick on map';
  static const String geofencePicking = 'Tap the map to set the centre';
  static const String geofenceClear = 'Clear';
  static const String geofenceSaved = 'Geofence saved';
  static const String geofenceCleared = 'Geofence cleared';
  static const String geofenceSaveFailed = 'Could not save the geofence.';
  static const String geofenceNoTagPosition = 'The tag has no GPS position yet.';
  static const String geofenceNoCenter =
      'Choose a centre first: use the tag position or pick a point on the map.';
  static const String geofenceHint =
      'While the app is open you are notified as soon as the tag leaves or re-enters this area.';
  static const String alertGeofenceLeftTitle = 'Geofence left';
  static const String alertGeofenceLeftBody = 'moved outside its geofence';
  static const String alertGeofenceBackTitle = 'Back inside geofence';
  static const String alertGeofenceBackBody = 'is back inside its geofence';
  static const String alertOpen = 'Open';

  // Alerts center (M5 task 4)
  static const String alertsCenterTitle = 'Alerts';
  static const String alertsEmpty = 'No alerts yet';
  static const String alertsEmptyHint = 'You will be notified here when something needs attention.';
  static const String alertsClearAll = 'Clear all';
  static const String alertsSettings = 'Notification settings';
  static const String alertsCategoryHeader = 'Which alerts to show';
  static const String alertsCatOffline = 'Tag offline / back online';
  static const String alertsCatBattery = 'Low battery / Critical';
  static const String alertsCatGps = 'GPS fix lost';
  static const String alertsCatGeofence = 'Geofence events';
  static const String alertsCatMovement = 'Movement detected';
  static const String alertsCatLeftBehind = 'Left behind (anti-lost)';
  static const String alertsCatSos = 'SOS';
  static const String alertsCatLostMode = 'Lost Mode updates';
  static const String alertsJustNow = 'Just now';
  // Alert titles/messages (used when emitting and in the center)
  static const String alertTitleOffline = 'Tag offline';
  static const String alertTitleOnline = 'Tag back online';
  static const String alertTitleLowBattery = 'Low battery';
  static const String alertTitleGpsLost = 'GPS fix lost';
  static const String alertTitleMovement = 'Movement detected';
  static const String alertTitleLeftBehind = 'Left behind';
  static const String alertTitleSos = 'SOS active';
  static const String alertTitleLostUpdate = 'Lost Mode update';
  static const String alertTitleCritical = 'Battery critical';
  static const String alertNotifChannelId = 'trackpoint_alerts';
  static const String alertNotifChannelName = 'TrackPoint Alerts';

  // Device Settings & Info (M6)
  static const String deviceSettingsTitle = 'Device Settings';
  static const String deviceInfoTitle = 'Device Information';
  static const String uploadIntervalLabel = 'Location Upload Interval';
  static const String uploadIntervalHint = '5 – 3600 seconds';
  static const String pollIntervalLabel = 'Command Poll Interval';
  static const String pollIntervalHint = '5 – 300 seconds';
  static const String buzzerMaxLabel = 'Buzzer Max Duration';
  static const String buzzerMaxHint = '5 – 600 seconds';
  static const String offlineTimeoutLabel = 'Offline Timeout';
  static const String offlineTimeoutHint = '30 – 86400 seconds';
  static const String lowBatteryThresholdLabel = 'Low Battery Threshold (V)';
  static const String lowBatteryThresholdHint = '3.0 – 4.0 V';
  static const String settingsSaved = 'Settings updated successfully';
  static const String settingsSaveFailed = 'Failed to update settings';
  static const String settingsCheckInNotice =
      'Settings apply on the tag’s next radio check-in.';
  static const String registeredDate = 'Registered Date';
  static const String registeredNever = 'Not registered';
  static const String currentSettingsSummary = 'Current Configuration';
  static const String invalidUploadInterval =
      'Must be between 5 and 3600 seconds';
  static const String invalidPollInterval =
      'Must be between 5 and 300 seconds';
  static const String invalidBuzzerMax =
      'Must be between 5 and 600 seconds';
  static const String invalidOfflineTimeout =
      'Must be between 30 and 86400 seconds';
  static const String invalidLowBattery =
      'Must be between 3.0 and 4.0 V';
  static const String invalidName = 'Name cannot be empty';

  // App Settings & Developer Screen (M6)
  static const String appSettingsTitle = 'App Settings';
  static const String themeTitle = 'Theme';
  static const String themeSystem = 'System';
  static const String themeLight = 'Light';
  static const String themeDark = 'Dark';
  static const String unitsTitle = 'Distance & Speed Units';
  static const String unitsMetric = 'Metric (km, km/h)';
  static const String unitsImperial = 'Imperial (miles, mph)';
  static const String developerOptions = 'Developer Options';
  static const String simulationMode = 'Simulation Mode (Virtual BLE)';
  static const String simulationModeDesc =
      'Use fake tag BLE service without physical hardware';
  static const String emulatorToggle = 'Firebase Emulator';
  static const String emulatorDesc =
      'Connect to local Firebase emulator instance';
  static const String showRawReports = 'Raw Report Inspector';
  static const String showRawReportsDesc =
      'Inspect latest raw payload directly from Realtime Database';
  static const String tileUrlOverride = 'Custom Tile URL Template';
  static const String tileUrlReset = 'Reset to default';

  // Help & Troubleshooting (M6)
  static const String helpTitle = 'Help & Troubleshooting';
  static const String helpButtonGuideTitle = 'Hardware Button Guide';
  static const String helpTagOfflineTitle = 'Tag shows offline';
  static const String helpTagOfflineBody =
      'When nearby, the tag connects over Bluetooth and shuts down cellular/GPS to conserve battery. When you move out of range, the tag checks in via cellular on its schedule (default 5 min in Away mode). If there is no cellular coverage, an empty battery, or an inactive SIM, the tag may show offline until the next successful check-in.';
  static const String helpGpsNoFixTitle = 'GPS Fix: No';
  static const String helpGpsNoFixBody =
      'GPS satellites require a direct, unobstructed line of sight to the sky. Indoors, in underground basements, or heavy concrete buildings, GPS will rarely acquire a fix. Cold starts take 1 to 3 minutes. TrackPoint displays the last real satellite fix with its timestamp age, and never invents or guesses coordinates.';
  static const String helpBuzzerPendingTitle = 'Buzzer command stays pending';
  static const String helpBuzzerPendingBody =
      'When the tag is not connected over Bluetooth, commands are delivered through the cellular cloud. The tag only wakes its cellular radio on its scheduled upload interval (or during Lost/SOS mode). Commands expire after 2 minutes if the tag does not check in.';
  static const String helpMapNotLoadingTitle = 'Map not loading';
  static const String helpMapNotLoadingBody =
      'Ensure your phone has an active internet connection to download map tiles from OpenStreetMap or Esri. If tiles fail to render, check Developer Options in Settings to verify or reset the tile URL template.';
  static const String helpBackgroundAlertsTitle = 'Background alerts don’t arrive';
  static const String helpBackgroundAlertsBody =
      'Mobile operating systems aggressively sleep background apps to save battery. On Android, disable Battery Optimisation for TrackPoint and allow unrestricted background data. On iOS, enable Background App Refresh and ensure notifications are permitted in system settings. “Left behind” alerts work while the app is running (foreground or kept alive by the system); a fully closed app cannot detect a Bluetooth disconnect.';
  static const String helpPrivacyTitle = 'Privacy & Security';
  static const String helpPrivacyBody =
      'TrackPoint uses secure end-to-end device claiming. Only the authenticated owner can query tag history, configure geofences, and send buzzer commands. Coordinates are only saved when reported by your devices.';
}
