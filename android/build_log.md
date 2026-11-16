Initialized native services in: /home/chris/.gradle/native
Initialized jansi services in: /home/chris/.gradle/native
Found daemon DaemonInfo{pid=43354, address=[dc762b47-f2e6-438b-b121-d3c331f90d31 port:32771, addresses:[/127.0.0.1]], state=Idle, lastBusy=1794278924760, context=DefaultDaemonContext[uid=90f404c4-e9e1-4616-aa44-ed1a8b212666,javaHome=/home/chris/.vscode/extensions/redhat.java-1.58.0-linux-x64/jre/25.0.4.1-linux-x86_64,javaVersion=25,javaVendor=Eclipse Adoptium,daemonRegistryDir=/home/chris/.gradle/daemon,pid=43354,idleTimeout=10800000,priority=NORMAL,applyInstrumentationAgent=true,nativeServicesMode=ENABLED,daemonOpts=-XX:MaxMetaspaceSize=4G,-XX:ReservedCodeCacheSize=512m,-XX:+HeapDumpOnOutOfMemoryError,-Xmx8G,-Dfile.encoding=UTF-8,-Duser.country=US,-Duser.language=en,-Duser.variant]} however its context does not match the desired criteria.
JVM is incompatible.
Wanted: DaemonRequestContext{jvmCriteria=/usr/lib/jvm/java-17-openjdk-amd64 (no Daemon JVM specified, using current Java home), daemonOpts=[-XX:MaxMetaspaceSize=4G, -XX:ReservedCodeCacheSize=512m, -XX:+HeapDumpOnOutOfMemoryError, -Xmx8G, -Dfile.encoding=UTF-8, -Duser.country=US, -Duser.language=en, -Duser.variant], applyInstrumentationAgent=true, nativeServicesMode=ENABLED, priority=NORMAL}
Actual: DefaultDaemonContext[uid=90f404c4-e9e1-4616-aa44-ed1a8b212666,javaHome=/home/chris/.vscode/extensions/redhat.java-1.58.0-linux-x64/jre/25.0.4.1-linux-x86_64,javaVersion=25,javaVendor=Eclipse Adoptium,daemonRegistryDir=/home/chris/.gradle/daemon,pid=43354,idleTimeout=10800000,priority=NORMAL,applyInstrumentationAgent=true,nativeServicesMode=ENABLED,daemonOpts=-XX:MaxMetaspaceSize=4G,-XX:ReservedCodeCacheSize=512m,-XX:+HeapDumpOnOutOfMemoryError,-Xmx8G,-Dfile.encoding=UTF-8,-Duser.country=US,-Duser.language=en,-Duser.variant]

  Looking for a different daemon...
The client will now receive all logging from the daemon (pid: 38159). The daemon log file: /home/chris/.gradle/daemon/9.3.1/daemon-38159.out.log
Starting 8th build in daemon [uptime: 43 mins 28.373 secs, performance: 97%, GC rate: 0.00/s, heap usage: 0% of 8 GiB, non-heap usage: 6% of 4 GiB]
Using 12 worker leases.
Operational build model parameters: {requiresToolingModels=false, parallelProjectExecution=false, configureOnDemand=false, configurationCache=false, configurationCacheParallelStore=false, configurationCacheParallelLoad=true, isolatedProjects=false, parallelProjectConfiguration=false, intermediateModelCache=false, parallelToolingApiActions=false, invalidateCoupledProjects=false, modelAsProjectDependency=false, resilientModelBuilding=false}
Now considering [/home/chris/Documents/Trackpoint_app/trackpoint_new/trackpoint_app/android, /home/chris/flutter/packages/flutter_tools/gradle] as hierarchies to watch
Watching the file system is configured to be enabled if available
File system watching is active
Starting Build
Now considering [/home/chris/flutter/packages/flutter_tools/gradle, /home/chris/Documents/Trackpoint_app/trackpoint_new/trackpoint_app/android] as hierarchies to watch

> Configure project :gradle
Evaluating project ':gradle' using build file '/home/chris/flutter/packages/flutter_tools/gradle/build.gradle.kts'.
Resolved plugin [id: 'org.gradle.java-gradle-plugin']
Resolved plugin [id: 'org.gradle.groovy']
Resolved plugin [id: 'org.gradle.kotlin.kotlin-dsl', version: '6.4.2']
Resolved plugin [id: 'org.jetbrains.kotlin.jvm', version: '2.2.20']
Build bc82816c-f85c-4c9a-9082-2ad70e277520 is started
Using Kotlin Gradle Plugin gradle813 variant
kotlin scripting plugin: created the scripting discovery configuration: kotlinScriptDef
kotlin scripting plugin: created the scripting discovery configuration: testKotlinScriptDef
file or directory '/home/chris/flutter/packages/flutter_tools/gradle/src/main/java', not found
Resolved plugin [id: 'dev.flutter.flutter-plugin-loader', version: '1.0.0']
Resolved plugin [id: 'com.android.application', version: '9.1.0', apply: false]
Resolved plugin [id: 'org.jetbrains.kotlin.android', version: '2.4.0', apply: false]
Resolved plugin [id: 'com.google.gms.google-services', version: '4.4.2', apply: false]
Resolve mutations for :gradle:checkKotlinGradlePluginConfigurationErrors (Thread[Execution worker,5,main]) started.
:gradle:checkKotlinGradlePluginConfigurationErrors (Thread[Execution worker,5,main]) started.

> Task :gradle:checkKotlinGradlePluginConfigurationErrors SKIPPED
Skipping task ':gradle:checkKotlinGradlePluginConfigurationErrors' as task onlyIf 'errorDiagnostics are present' is false.
Resolve mutations for :gradle:compileKotlin (Thread[Execution worker,5,main]) started.
:gradle:compileKotlin (Thread[Execution worker,5,main]) started.

> Task :gradle:compileKotlin UP-TO-DATE
Caching disabled for task ':gradle:compileKotlin' because:
  Build cache is disabled
Skipping task ':gradle:compileKotlin' as it is up-to-date.
Resolve mutations for :gradle:compileJava (Thread[Execution worker,5,main]) started.
:gradle:compileJava (Thread[Execution worker,5,main]) started.

> Task :gradle:compileJava NO-SOURCE
Skipping task ':gradle:compileJava' as it has no source files and no previous output files.
Resolve mutations for :gradle:compileGroovy (Thread[Execution worker,5,main]) started.
:gradle:compileGroovy (Thread[Execution worker,5,main]) started.

> Task :gradle:compileGroovy NO-SOURCE
Skipping task ':gradle:compileGroovy' as it has no source files and no previous output files.
Resolve mutations for :gradle:pluginDescriptors (Thread[Execution worker,5,main]) started.
:gradle:pluginDescriptors (Thread[Execution worker,5,main]) started.

> Task :gradle:pluginDescriptors UP-TO-DATE
Caching disabled for task ':gradle:pluginDescriptors' because:
  Build cache is disabled
  Not worth caching
Skipping task ':gradle:pluginDescriptors' as it is up-to-date.
Resolve mutations for :gradle:processResources (Thread[Execution worker Thread 7,5,main]) started.
:gradle:processResources (Thread[Execution worker Thread 7,5,main]) started.

> Task :gradle:processResources UP-TO-DATE
Caching disabled for task ':gradle:processResources' because:
  Build cache is disabled
  Not worth caching
Skipping task ':gradle:processResources' as it is up-to-date.
Resolve mutations for :gradle:classes (Thread[Execution worker Thread 7,5,main]) started.
:gradle:classes (Thread[Execution worker Thread 6,5,main]) started.

> Task :gradle:classes UP-TO-DATE
Skipping task ':gradle:classes' as it has no actions.
Resolve mutations for :gradle:jar (Thread[Execution worker Thread 6,5,main]) started.
:gradle:jar (Thread[Execution worker Thread 6,5,main]) started.

> Task :gradle:jar UP-TO-DATE
Caching disabled for task ':gradle:jar' because:
  Build cache is disabled
  Not worth caching
Skipping task ':gradle:jar' as it is up-to-date.
Settings evaluated using settings file '/home/chris/Documents/Trackpoint_app/trackpoint_new/trackpoint_app/android/settings.gradle.kts'.
Projects loaded. Root project using build file '/home/chris/Documents/Trackpoint_app/trackpoint_new/trackpoint_app/android/build.gradle.kts'.
Included projects: [root project 'android', project ':app', project ':firebase_auth', project ':firebase_core', project ':firebase_database', project ':firebase_messaging', project ':flutter_blue_plus_android', project ':flutter_local_notifications', project ':geolocator_android', project ':jni', project ':permission_handler_android', project ':shared_preferences_android', project ':url_launcher_android']

> Configure project :app
Evaluating project ':app' using build file '/home/chris/Documents/Trackpoint_app/trackpoint_new/trackpoint_app/android/app/build.gradle.kts'.
Resolved plugin [id: 'com.android.application']
Resolved plugin [id: 'kotlin-android']
Resolved plugin [id: 'dev.flutter.flutter-gradle-plugin']
Resolved plugin [id: 'com.google.gms.google-services']
WARNING: The option setting 'android.builtInKotlin=false' is deprecated.
The current default is 'true'.
It will be removed in version 10.0 of the Android Gradle plugin.
WARNING: The option setting 'android.newDsl=false' is deprecated.
The current default is 'true'.
It will be removed in version 10.0 of the Android Gradle plugin.
Using default execution profile
Build 9f841253-3a68-44df-9698-3cf7169be796 is started
Using Kotlin Gradle Plugin gradle813 variant
Using Kotlin Gradle Plugin gradle813 variant
Using Kotlin Gradle Plugin gradle813 variant
Using Kotlin Gradle Plugin gradle813 variant
Using Kotlin Gradle Plugin gradle813 variant
Using Kotlin Gradle Plugin gradle813 variant
Using Kotlin Gradle Plugin gradle813 variant
Using Kotlin Gradle Plugin gradle813 variant
Using Kotlin Gradle Plugin gradle813 variant
Using Kotlin Gradle Plugin gradle813 variant
Using Kotlin Gradle Plugin gradle813 variant
Using Kotlin Gradle Plugin gradle813 variant
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':app' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m


> Configure project :
Evaluating root project 'android' using build file '/home/chris/Documents/Trackpoint_app/trackpoint_new/trackpoint_app/android/build.gradle.kts'.

> Configure project :firebase_auth
Evaluating project ':firebase_auth' using build file '/home/chris/.pub-cache/hosted/pub.dev/firebase_auth-5.7.0/android/build.gradle'.
Using default execution profile
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':firebase_auth' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m


> Configure project :firebase_core
Evaluating project ':firebase_core' using build file '/home/chris/.pub-cache/hosted/pub.dev/firebase_core-3.15.2/android/build.gradle'.
Using default execution profile
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':firebase_core' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m


> Configure project :firebase_database
Evaluating project ':firebase_database' using build file '/home/chris/.pub-cache/hosted/pub.dev/firebase_database-11.3.10/android/build.gradle'.
Using default execution profile
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':firebase_database' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m


> Configure project :firebase_messaging
Evaluating project ':firebase_messaging' using build file '/home/chris/.pub-cache/hosted/pub.dev/firebase_messaging-15.2.10/android/build.gradle'.
Using default execution profile
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':firebase_messaging' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m


> Configure project :flutter_blue_plus_android
Evaluating project ':flutter_blue_plus_android' using build file '/home/chris/.pub-cache/hosted/pub.dev/flutter_blue_plus_android-7.0.4/android/build.gradle'.
Using default execution profile
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':flutter_blue_plus_android' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m


> Configure project :flutter_local_notifications
Evaluating project ':flutter_local_notifications' using build file '/home/chris/.pub-cache/hosted/pub.dev/flutter_local_notifications-17.2.4/android/build.gradle'.
Using default execution profile
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':flutter_local_notifications' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m


> Configure project :geolocator_android
Evaluating project ':geolocator_android' using build file '/home/chris/.pub-cache/hosted/pub.dev/geolocator_android-4.6.2/android/build.gradle'.
Using default execution profile
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':geolocator_android' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m


> Configure project :jni
Evaluating project ':jni' using build file '/home/chris/.pub-cache/hosted/pub.dev/jni-1.1.2/android/build.gradle'.
Using default execution profile
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
C/C++: android.ndkVersion from module build.gradle is [28.2.13676358]
C/C++: android.ndkPath from module build.gradle is not set
C/C++: ndk.dir in local.properties is not set
C/C++: Not considering ANDROID_NDK_HOME because support was removed after deprecation period.
C/C++: sdkFolder is /home/chris/Android/Sdk
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':jni' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m


> Configure project :permission_handler_android
Evaluating project ':permission_handler_android' using build file '/home/chris/.pub-cache/hosted/pub.dev/permission_handler_android-12.1.0/android/build.gradle'.
Using default execution profile
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':permission_handler_android' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m


> Configure project :shared_preferences_android
Evaluating project ':shared_preferences_android' using build file '/home/chris/.pub-cache/hosted/pub.dev/shared_preferences_android-2.5.4/android/build.gradle.kts'.
Resolved plugin [id: 'com.android.library']
Using default execution profile
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':shared_preferences_android' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m


> Configure project :url_launcher_android
Evaluating project ':url_launcher_android' using build file '/home/chris/.pub-cache/hosted/pub.dev/url_launcher_android-6.3.33/android/build.gradle.kts'.
Resolved plugin [id: 'com.android.library']
Using default execution profile
w: [33m[1m⚠️ Deprecated 'org.jetbrains.kotlin.android' plugin usage[0m[0m
The 'org.jetbrains.kotlin.android' plugin in project ':url_launcher_android' is no longer required for Kotlin support since AGP 9.0.
[32m[1mSolution:[0m[0m
[32m[3mRemove both `android.builtInKotlin=true` and `android.newDsl=false` from `gradle.properties`, then migrate to built-in Kotlin.[0m[0m
[36mSee [0m[34mhttps://kotl.in/gradle/agp-built-in-kotlin[0m[36m for more details.[0m

All projects evaluated.
WARNING: Your Android app project: app located at: /home/chris/Documents/Trackpoint_app/trackpoint_new/trackpoint_app/android/app/build.gradle.kts
applies the Kotlin Gradle Plugin, which will cause build failures in future versions of Flutter.
Please migrate your app to Built-in Kotlin using this guide: https://docs.flutter.dev/release/breaking-changes/migrate-to-built-in-kotlin/for-app-developers

Task name matched 'assembleDebug'
Selected primary task 'assembleDebug' from project :
Adding -Xuse-inline-scopes-numbers Kotlin compiler flag for task :app:compileDebugKotlin
Adding -Xuse-inline-scopes-numbers Kotlin compiler flag for task :app:compileDebugAndroidTestKotlin
Adding -Xuse-inline-scopes-numbers Kotlin compiler flag for task :app:compileProfileKotlin
Tasks to be executed: [task ':app:DebugMinSdkCheck', task ':app:validateCompileSdkVersion', task ':app:preBuild', task ':app:preDebugBuild', task ':app:mergeDebugNativeDebugMetadata', task ':app:checkKotlinGradlePluginConfigurationErrors', task ':app:cleanMergeDebugAssets', task ':app:compileFlutterBuildDebug', task ':app:generateDebugAssets', task ':firebase_auth:generateDebugAssets', task ':firebase_auth:preBuild', task ':firebase_auth:preDebugBuild', task ':firebase_auth:mergeDebugAssets', task ':firebase_core:generateDebugAssets', task ':firebase_core:preBuild', task ':firebase_core:preDebugBuild', task ':firebase_core:mergeDebugAssets', task ':firebase_database:generateDebugAssets', task ':firebase_database:preBuild', task ':firebase_database:preDebugBuild', task ':firebase_database:mergeDebugAssets', task ':firebase_messaging:generateDebugAssets', task ':firebase_messaging:preBuild', task ':firebase_messaging:preDebugBuild', task ':firebase_messaging:mergeDebugAssets', task ':flutter_blue_plus_android:generateDebugAssets', task ':flutter_blue_plus_android:preBuild', task ':flutter_blue_plus_android:preDebugBuild', task ':flutter_blue_plus_android:mergeDebugAssets', task ':flutter_local_notifications:generateDebugAssets', task ':flutter_local_notifications:preBuild', task ':flutter_local_notifications:preDebugBuild', task ':flutter_local_notifications:mergeDebugAssets', task ':geolocator_android:generateDebugAssets', task ':geolocator_android:preBuild', task ':geolocator_android:preDebugBuild', task ':geolocator_android:mergeDebugAssets', task ':jni:generateDebugAssets', task ':jni:preBuild', task ':jni:preDebugBuild', task ':jni:mergeDebugAssets', task ':permission_handler_android:generateDebugAssets', task ':permission_handler_android:preBuild', task ':permission_handler_android:preDebugBuild', task ':permission_handler_android:mergeDebugAssets', task ':shared_preferences_android:generateDebugAssets', task ':shared_preferences_android:preBuild', task ':shared_preferences_android:preDebugBuild', task ':shared_preferences_android:mergeDebugAssets', task ':url_launcher_android:generateDebugAssets', task ':url_launcher_android:preBuild', task ':url_launcher_android:preDebugBuild', task ':url_launcher_android:mergeDebugAssets', task ':app:mergeDebugAssets', task ':app:copyFlutterAssetsDebug', task ':app:generateDebugResources', task ':app:processDebugGoogleServices', task ':app:packageDebugResources', task ':firebase_auth:processDebugNavigationResources', task ':firebase_core:processDebugNavigationResources', task ':firebase_database:processDebugNavigationResources', task ':firebase_messaging:processDebugNavigationResources', task ':flutter_blue_plus_android:processDebugNavigationResources', task ':flutter_local_notifications:processDebugNavigationResources', task ':geolocator_android:processDebugNavigationResources', task ':jni:processDebugNavigationResources', task ':permission_handler_android:processDebugNavigationResources', task ':shared_preferences_android:processDebugNavigationResources', task ':url_launcher_android:processDebugNavigationResources', task ':app:processDebugNavigationResources', task ':app:parseDebugLocalResources', task ':app:generateDebugRFile', task ':firebase_auth:checkKotlinGradlePluginConfigurationErrors', task ':firebase_auth:generateDebugBuildConfig', task ':firebase_auth:generateDebugResources', task ':firebase_auth:packageDebugResources', task ':firebase_auth:parseDebugLocalResources', task ':firebase_auth:generateDebugRFile', task ':firebase_core:checkKotlinGradlePluginConfigurationErrors', task ':firebase_core:generateDebugBuildConfig', task ':firebase_core:generateDebugResources', task ':firebase_core:packageDebugResources', task ':firebase_core:parseDebugLocalResources', task ':firebase_core:generateDebugRFile', task ':firebase_core:compileDebugKotlin', task ':firebase_core:javaPreCompileDebug', task ':firebase_core:compileDebugJavaWithJavac', task ':firebase_core:bundleLibCompileToJarDebug', task ':firebase_auth:compileDebugKotlin', task ':firebase_auth:javaPreCompileDebug', task ':firebase_auth:compileDebugJavaWithJavac', task ':firebase_auth:bundleLibCompileToJarDebug', task ':firebase_database:checkKotlinGradlePluginConfigurationErrors', task ':firebase_database:generateDebugBuildConfig', task ':firebase_database:generateDebugResources', task ':firebase_database:packageDebugResources', task ':firebase_database:parseDebugLocalResources', task ':firebase_database:generateDebugRFile', task ':firebase_database:compileDebugKotlin', task ':firebase_database:javaPreCompileDebug', task ':firebase_database:compileDebugJavaWithJavac', task ':firebase_database:bundleLibCompileToJarDebug', task ':firebase_messaging:checkKotlinGradlePluginConfigurationErrors', task ':firebase_messaging:generateDebugBuildConfig', task ':firebase_messaging:generateDebugResources', task ':firebase_messaging:packageDebugResources', task ':firebase_messaging:parseDebugLocalResources', task ':firebase_messaging:generateDebugRFile', task ':firebase_messaging:compileDebugKotlin', task ':firebase_messaging:javaPreCompileDebug', task ':firebase_messaging:compileDebugJavaWithJavac', task ':firebase_messaging:bundleLibCompileToJarDebug', task ':flutter_blue_plus_android:checkKotlinGradlePluginConfigurationErrors', task ':flutter_blue_plus_android:generateDebugResources', task ':flutter_blue_plus_android:packageDebugResources', task ':flutter_blue_plus_android:parseDebugLocalResources', task ':flutter_blue_plus_android:generateDebugRFile', task ':flutter_blue_plus_android:compileDebugKotlin', task ':flutter_blue_plus_android:javaPreCompileDebug', task ':flutter_blue_plus_android:compileDebugJavaWithJavac', task ':flutter_blue_plus_android:bundleLibCompileToJarDebug', task ':flutter_local_notifications:checkKotlinGradlePluginConfigurationErrors', task ':flutter_local_notifications:generateDebugResources', task ':flutter_local_notifications:packageDebugResources', task ':flutter_local_notifications:parseDebugLocalResources', task ':flutter_local_notifications:generateDebugRFile', task ':flutter_local_notifications:compileDebugKotlin', task ':flutter_local_notifications:javaPreCompileDebug', task ':flutter_local_notifications:compileDebugJavaWithJavac', task ':flutter_local_notifications:bundleLibCompileToJarDebug', task ':geolocator_android:checkKotlinGradlePluginConfigurationErrors', task ':geolocator_android:generateDebugResources', task ':geolocator_android:packageDebugResources', task ':geolocator_android:parseDebugLocalResources', task ':geolocator_android:generateDebugRFile', task ':geolocator_android:compileDebugKotlin', task ':geolocator_android:javaPreCompileDebug', task ':geolocator_android:compileDebugJavaWithJavac', task ':geolocator_android:bundleLibCompileToJarDebug', task ':jni:checkKotlinGradlePluginConfigurationErrors', task ':jni:generateDebugResources', task ':jni:packageDebugResources', task ':jni:parseDebugLocalResources', task ':jni:generateDebugRFile', task ':jni:compileDebugKotlin', task ':jni:javaPreCompileDebug', task ':jni:compileDebugJavaWithJavac', task ':jni:bundleLibCompileToJarDebug', task ':permission_handler_android:checkKotlinGradlePluginConfigurationErrors', task ':permission_handler_android:generateDebugResources', task ':permission_handler_android:packageDebugResources', task ':permission_handler_android:parseDebugLocalResources', task ':permission_handler_android:generateDebugRFile', task ':permission_handler_android:compileDebugKotlin', task ':permission_handler_android:javaPreCompileDebug', task ':permission_handler_android:compileDebugJavaWithJavac', task ':permission_handler_android:bundleLibCompileToJarDebug', task ':shared_preferences_android:checkKotlinGradlePluginConfigurationErrors', task ':shared_preferences_android:generateDebugResources', task ':shared_preferences_android:packageDebugResources', task ':shared_preferences_android:parseDebugLocalResources', task ':shared_preferences_android:generateDebugRFile', task ':shared_preferences_android:compileDebugKotlin', task ':shared_preferences_android:javaPreCompileDebug', task ':shared_preferences_android:compileDebugJavaWithJavac', task ':shared_preferences_android:bundleLibCompileToJarDebug', task ':url_launcher_android:checkKotlinGradlePluginConfigurationErrors', task ':url_launcher_android:generateDebugBuildConfig', task ':url_launcher_android:generateDebugResources', task ':url_launcher_android:packageDebugResources', task ':url_launcher_android:parseDebugLocalResources', task ':url_launcher_android:generateDebugRFile', task ':url_launcher_android:compileDebugKotlin', task ':url_launcher_android:javaPreCompileDebug', task ':url_launcher_android:compileDebugJavaWithJavac', task ':url_launcher_android:bundleLibCompileToJarDebug', task ':app:compileDebugKotlin', task ':app:javaPreCompileDebug', task ':app:compileDebugJavaWithJavac', task ':app:compressDebugAssets', task ':firebase_auth:bundleLibRuntimeToJarDebug', task ':firebase_database:bundleLibRuntimeToJarDebug', task ':firebase_messaging:bundleLibRuntimeToJarDebug', task ':firebase_core:bundleLibRuntimeToJarDebug', task ':flutter_blue_plus_android:bundleLibRuntimeToJarDebug', task ':flutter_local_notifications:bundleLibRuntimeToJarDebug', task ':geolocator_android:bundleLibRuntimeToJarDebug', task ':shared_preferences_android:bundleLibRuntimeToJarDebug', task ':jni:bundleLibRuntimeToJarDebug', task ':permission_handler_android:bundleLibRuntimeToJarDebug', task ':url_launcher_android:bundleLibRuntimeToJarDebug', task ':app:desugarDebugFileDependencies', task ':firebase_auth:writeDebugAarMetadata', task ':firebase_core:writeDebugAarMetadata', task ':firebase_database:writeDebugAarMetadata', task ':firebase_messaging:writeDebugAarMetadata', task ':flutter_blue_plus_android:writeDebugAarMetadata', task ':flutter_local_notifications:writeDebugAarMetadata', task ':geolocator_android:writeDebugAarMetadata', task ':jni:writeDebugAarMetadata', task ':permission_handler_android:writeDebugAarMetadata', task ':shared_preferences_android:writeDebugAarMetadata', task ':url_launcher_android:writeDebugAarMetadata', task ':app:checkDebugAarMetadata', task ':app:mapDebugSourceSetPaths', task ':app:compileDebugNavigationResources', task ':app:mergeDebugResources', task ':app:createDebugCompatibleScreenManifests', task ':app:extractDeepLinksDebug', task ':firebase_auth:extractDeepLinksDebug', task ':firebase_auth:processDebugManifest', task ':firebase_core:extractDeepLinksDebug', task ':firebase_core:processDebugManifest', task ':firebase_database:extractDeepLinksDebug', task ':firebase_database:processDebugManifest', task ':firebase_messaging:extractDeepLinksDebug', task ':firebase_messaging:processDebugManifest', task ':flutter_blue_plus_android:extractDeepLinksDebug', task ':flutter_blue_plus_android:processDebugManifest', task ':flutter_local_notifications:extractDeepLinksDebug', task ':flutter_local_notifications:processDebugManifest', task ':geolocator_android:extractDeepLinksDebug', task ':geolocator_android:processDebugManifest', task ':jni:extractDeepLinksDebug', task ':jni:processDebugManifest', task ':permission_handler_android:extractDeepLinksDebug', task ':permission_handler_android:processDebugManifest', task ':shared_preferences_android:extractDeepLinksDebug', task ':shared_preferences_android:processDebugManifest', task ':url_launcher_android:extractDeepLinksDebug', task ':url_launcher_android:processDebugManifest', task ':app:processDebugMainManifest', task ':app:outputDebugAppLinkSettings', task ':app:processDebugManifest', task ':app:processDebugManifestForPackage', task ':firebase_auth:mapDebugSourceSetPaths', task ':firebase_auth:compileDebugLibraryResources', task ':firebase_core:mapDebugSourceSetPaths', task ':firebase_core:compileDebugLibraryResources', task ':firebase_database:mapDebugSourceSetPaths', task ':firebase_database:compileDebugLibraryResources', task ':firebase_messaging:mapDebugSourceSetPaths', task ':firebase_messaging:compileDebugLibraryResources', task ':flutter_blue_plus_android:mapDebugSourceSetPaths', task ':flutter_blue_plus_android:compileDebugLibraryResources', task ':flutter_local_notifications:mapDebugSourceSetPaths', task ':flutter_local_notifications:compileDebugLibraryResources', task ':geolocator_android:mapDebugSourceSetPaths', task ':geolocator_android:compileDebugLibraryResources', task ':jni:mapDebugSourceSetPaths', task ':jni:compileDebugLibraryResources', task ':permission_handler_android:mapDebugSourceSetPaths', task ':permission_handler_android:compileDebugLibraryResources', task ':shared_preferences_android:mapDebugSourceSetPaths', task ':shared_preferences_android:compileDebugLibraryResources', task ':url_launcher_android:mapDebugSourceSetPaths', task ':url_launcher_android:compileDebugLibraryResources', task ':app:processDebugResources', task ':app:dexBuilderDebug', task ':app:mergeDebugGlobalSynthetics', task ':app:processDebugJavaRes', task ':firebase_auth:processDebugJavaRes', task ':firebase_core:processDebugJavaRes', task ':firebase_database:processDebugJavaRes', task ':firebase_messaging:processDebugJavaRes', task ':flutter_blue_plus_android:processDebugJavaRes', task ':flutter_local_notifications:processDebugJavaRes', task ':geolocator_android:processDebugJavaRes', task ':jni:processDebugJavaRes', task ':permission_handler_android:processDebugJavaRes', task ':shared_preferences_android:processDebugJavaRes', task ':url_launcher_android:processDebugJavaRes', task ':app:mergeDebugJavaResource', task ':app:checkDebugDuplicateClasses', task ':app:mergeExtDexDebug', task ':firebase_auth:bundleLibRuntimeToDirDebug', task ':firebase_database:bundleLibRuntimeToDirDebug', task ':firebase_messaging:bundleLibRuntimeToDirDebug', task ':firebase_core:bundleLibRuntimeToDirDebug', task ':flutter_blue_plus_android:bundleLibRuntimeToDirDebug', task ':flutter_local_notifications:bundleLibRuntimeToDirDebug', task ':geolocator_android:bundleLibRuntimeToDirDebug', task ':shared_preferences_android:bundleLibRuntimeToDirDebug', task ':jni:bundleLibRuntimeToDirDebug', task ':permission_handler_android:bundleLibRuntimeToDirDebug', task ':url_launcher_android:bundleLibRuntimeToDirDebug', task ':app:mergeLibDexDebug', task ':app:mergeProjectDexDebug', task ':app:configureCMakeDebug[arm64-v8a]', task ':app:buildCMakeDebug[arm64-v8a]', task ':app:configureCMakeDebug[armeabi-v7a]', task ':app:buildCMakeDebug[armeabi-v7a]', task ':app:configureCMakeDebug[x86_64]', task ':app:buildCMakeDebug[x86_64]', task ':app:copyJniLibsflutterBuildDebug', task ':app:mergeDebugJniLibFolders', task ':firebase_auth:mergeDebugJniLibFolders', task ':firebase_auth:mergeDebugNativeLibs', task ':firebase_auth:copyDebugJniLibsProjectOnly', task ':firebase_core:mergeDebugJniLibFolders', task ':firebase_core:mergeDebugNativeLibs', task ':firebase_core:copyDebugJniLibsProjectOnly', task ':firebase_database:mergeDebugJniLibFolders', task ':firebase_database:mergeDebugNativeLibs', task ':firebase_database:copyDebugJniLibsProjectOnly', task ':firebase_messaging:mergeDebugJniLibFolders', task ':firebase_messaging:mergeDebugNativeLibs', task ':firebase_messaging:copyDebugJniLibsProjectOnly', task ':flutter_blue_plus_android:mergeDebugJniLibFolders', task ':flutter_blue_plus_android:mergeDebugNativeLibs', task ':flutter_blue_plus_android:copyDebugJniLibsProjectOnly', task ':flutter_local_notifications:mergeDebugJniLibFolders', task ':flutter_local_notifications:mergeDebugNativeLibs', task ':flutter_local_notifications:copyDebugJniLibsProjectOnly', task ':geolocator_android:mergeDebugJniLibFolders', task ':geolocator_android:mergeDebugNativeLibs', task ':geolocator_android:copyDebugJniLibsProjectOnly', task ':jni:preProfileBuild', task ':jni:configureCMakeDebug[arm64-v8a]', task ':jni:buildCMakeDebug[arm64-v8a]', task ':jni:configureCMakeDebug[armeabi-v7a]', task ':jni:buildCMakeDebug[armeabi-v7a]', task ':jni:configureCMakeDebug[x86]', task ':jni:buildCMakeDebug[x86]', task ':jni:configureCMakeDebug[x86_64]', task ':jni:buildCMakeDebug[x86_64]', task ':jni:mergeDebugJniLibFolders', task ':jni:mergeDebugNativeLibs', task ':jni:copyDebugJniLibsProjectOnly', task ':permission_handler_android:mergeDebugJniLibFolders', task ':permission_handler_android:mergeDebugNativeLibs', task ':permission_handler_android:copyDebugJniLibsProjectOnly', task ':shared_preferences_android:mergeDebugJniLibFolders', task ':shared_preferences_android:mergeDebugNativeLibs', task ':shared_preferences_android:copyDebugJniLibsProjectOnly', task ':url_launcher_android:mergeDebugJniLibFolders', task ':url_launcher_android:mergeDebugNativeLibs', task ':url_launcher_android:copyDebugJniLibsProjectOnly', task ':app:mergeDebugNativeLibs', task ':app:stripDebugDebugSymbols', task ':app:validateSigningDebug', task ':app:writeDebugAppMetadata', task ':app:writeDebugSigningConfigVersions', task ':app:packageDebug', task ':app:createDebugApkListingFileRedirect', task ':app:assembleDebug', task ':firebase_auth:checkDebugAarMetadata', task ':firebase_auth:stripDebugDebugSymbols', task ':firebase_auth:copyDebugJniLibsProjectAndLocalJars', task ':firebase_auth:extractDebugAnnotations', task ':firebase_auth:extractDeepLinksForAarDebug', task ':firebase_auth:mergeDebugGeneratedProguardFiles', task ':firebase_auth:mergeDebugConsumerProguardFiles', task ':firebase_auth:prepareDebugArtProfile', task ':firebase_auth:prepareLintJarForPublish', task ':firebase_auth:mergeDebugJavaResource', task ':firebase_auth:syncDebugLibJars', task ':firebase_auth:bundleDebugAar', task ':firebase_auth:assembleDebug', task ':firebase_core:checkDebugAarMetadata', task ':firebase_core:stripDebugDebugSymbols', task ':firebase_core:copyDebugJniLibsProjectAndLocalJars', task ':firebase_core:extractDebugAnnotations', task ':firebase_core:extractDeepLinksForAarDebug', task ':firebase_core:mergeDebugGeneratedProguardFiles', task ':firebase_core:mergeDebugConsumerProguardFiles', task ':firebase_core:prepareDebugArtProfile', task ':firebase_core:prepareLintJarForPublish', task ':firebase_core:mergeDebugJavaResource', task ':firebase_core:syncDebugLibJars', task ':firebase_core:bundleDebugAar', task ':firebase_core:assembleDebug', task ':firebase_database:checkDebugAarMetadata', task ':firebase_database:stripDebugDebugSymbols', task ':firebase_database:copyDebugJniLibsProjectAndLocalJars', task ':firebase_database:extractDebugAnnotations', task ':firebase_database:extractDeepLinksForAarDebug', task ':firebase_database:mergeDebugGeneratedProguardFiles', task ':firebase_database:mergeDebugConsumerProguardFiles', task ':firebase_database:prepareDebugArtProfile', task ':firebase_database:prepareLintJarForPublish', task ':firebase_database:mergeDebugJavaResource', task ':firebase_database:syncDebugLibJars', task ':firebase_database:bundleDebugAar', task ':firebase_database:assembleDebug', task ':firebase_messaging:checkDebugAarMetadata', task ':firebase_messaging:stripDebugDebugSymbols', task ':firebase_messaging:copyDebugJniLibsProjectAndLocalJars', task ':firebase_messaging:extractDebugAnnotations', task ':firebase_messaging:extractDeepLinksForAarDebug', task ':firebase_messaging:mergeDebugGeneratedProguardFiles', task ':firebase_messaging:mergeDebugConsumerProguardFiles', task ':firebase_messaging:prepareDebugArtProfile', task ':firebase_messaging:prepareLintJarForPublish', task ':firebase_messaging:mergeDebugJavaResource', task ':firebase_messaging:syncDebugLibJars', task ':firebase_messaging:bundleDebugAar', task ':firebase_messaging:assembleDebug', task ':flutter_blue_plus_android:checkDebugAarMetadata', task ':flutter_blue_plus_android:stripDebugDebugSymbols', task ':flutter_blue_plus_android:copyDebugJniLibsProjectAndLocalJars', task ':flutter_blue_plus_android:extractDebugAnnotations', task ':flutter_blue_plus_android:extractDeepLinksForAarDebug', task ':flutter_blue_plus_android:mergeDebugGeneratedProguardFiles', task ':flutter_blue_plus_android:mergeDebugConsumerProguardFiles', task ':flutter_blue_plus_android:prepareDebugArtProfile', task ':flutter_blue_plus_android:prepareLintJarForPublish', task ':flutter_blue_plus_android:mergeDebugJavaResource', task ':flutter_blue_plus_android:syncDebugLibJars', task ':flutter_blue_plus_android:bundleDebugAar', task ':flutter_blue_plus_android:assembleDebug', task ':flutter_local_notifications:checkDebugAarMetadata', task ':flutter_local_notifications:stripDebugDebugSymbols', task ':flutter_local_notifications:copyDebugJniLibsProjectAndLocalJars', task ':flutter_local_notifications:extractDebugAnnotations', task ':flutter_local_notifications:extractDeepLinksForAarDebug', task ':flutter_local_notifications:mergeDebugGeneratedProguardFiles', task ':flutter_local_notifications:mergeDebugConsumerProguardFiles', task ':flutter_local_notifications:prepareDebugArtProfile', task ':flutter_local_notifications:prepareLintJarForPublish', task ':flutter_local_notifications:mergeDebugJavaResource', task ':flutter_local_notifications:syncDebugLibJars', task ':flutter_local_notifications:bundleDebugAar', task ':flutter_local_notifications:assembleDebug', task ':geolocator_android:checkDebugAarMetadata', task ':geolocator_android:stripDebugDebugSymbols', task ':geolocator_android:copyDebugJniLibsProjectAndLocalJars', task ':geolocator_android:extractDebugAnnotations', task ':geolocator_android:extractDeepLinksForAarDebug', task ':geolocator_android:mergeDebugGeneratedProguardFiles', task ':geolocator_android:mergeDebugConsumerProguardFiles', task ':geolocator_android:prepareDebugArtProfile', task ':geolocator_android:prepareLintJarForPublish', task ':geolocator_android:mergeDebugJavaResource', task ':geolocator_android:syncDebugLibJars', task ':geolocator_android:bundleDebugAar', task ':geolocator_android:assembleDebug', task ':jni:checkDebugAarMetadata', task ':jni:stripDebugDebugSymbols', task ':jni:copyDebugJniLibsProjectAndLocalJars', task ':jni:extractDebugAnnotations', task ':jni:extractDeepLinksForAarDebug', task ':jni:mergeDebugGeneratedProguardFiles', task ':jni:mergeDebugConsumerProguardFiles', task ':jni:prepareDebugArtProfile', task ':jni:prepareLintJarForPublish', task ':jni:mergeDebugJavaResource', task ':jni:syncDebugLibJars', task ':jni:bundleDebugAar', task ':jni:assembleDebug', task ':permission_handler_android:checkDebugAarMetadata', task ':permission_handler_android:stripDebugDebugSymbols', task ':permission_handler_android:copyDebugJniLibsProjectAndLocalJars', task ':permission_handler_android:extractDebugAnnotations', task ':permission_handler_android:extractDeepLinksForAarDebug', task ':permission_handler_android:mergeDebugGeneratedProguardFiles', task ':permission_handler_android:mergeDebugConsumerProguardFiles', task ':permission_handler_android:prepareDebugArtProfile', task ':permission_handler_android:prepareLintJarForPublish', task ':permission_handler_android:mergeDebugJavaResource', task ':permission_handler_android:syncDebugLibJars', task ':permission_handler_android:bundleDebugAar', task ':permission_handler_android:assembleDebug', task ':shared_preferences_android:checkDebugAarMetadata', task ':shared_preferences_android:stripDebugDebugSymbols', task ':shared_preferences_android:copyDebugJniLibsProjectAndLocalJars', task ':shared_preferences_android:extractDebugAnnotations', task ':shared_preferences_android:extractDeepLinksForAarDebug', task ':shared_preferences_android:mergeDebugGeneratedProguardFiles', task ':shared_preferences_android:mergeDebugConsumerProguardFiles', task ':shared_preferences_android:prepareDebugArtProfile', task ':shared_preferences_android:prepareLintJarForPublish', task ':shared_preferences_android:mergeDebugJavaResource', task ':shared_preferences_android:syncDebugLibJars', task ':shared_preferences_android:bundleDebugAar', task ':shared_preferences_android:assembleDebug', task ':url_launcher_android:checkDebugAarMetadata', task ':url_launcher_android:stripDebugDebugSymbols', task ':url_launcher_android:copyDebugJniLibsProjectAndLocalJars', task ':url_launcher_android:extractDebugAnnotations', task ':url_launcher_android:extractDeepLinksForAarDebug', task ':url_launcher_android:mergeDebugGeneratedProguardFiles', task ':url_launcher_android:mergeDebugConsumerProguardFiles', task ':url_launcher_android:prepareDebugArtProfile', task ':url_launcher_android:prepareLintJarForPublish', task ':url_launcher_android:mergeDebugJavaResource', task ':url_launcher_android:syncDebugLibJars', task ':url_launcher_android:bundleDebugAar', task ':url_launcher_android:assembleDebug']
Tasks that were excluded: []
work action Parameters of IdentityTransform (Thread[Execution worker Thread 11,5,main]) started.
work action Parameters of DexingNoClasspathTransform (Thread[Execution worker Thread 11,5,main]) started.
work action Parameters of DexingOutputSplitTransform (Thread[Execution worker Thread 11,5,main]) started.
work action Parameters of ClassesDirToClassesTransform (Thread[Execution worker Thread 3,5,main]) started.
work action Parameters of DexingOutputSplitTransform (Thread[Execution worker Thread 3,5,main]) started.
Resolve mutations for :app:DebugMinSdkCheck (Thread[Execution worker Thread 3,5,main]) started.
:app:DebugMinSdkCheck (Thread[included builds,5,main]) started.

> Task :app:DebugMinSdkCheck
Caching disabled for task ':app:DebugMinSdkCheck' because:
  Build cache is disabled
Task ':app:DebugMinSdkCheck' is not up-to-date because:
  Task has not declared any outputs despite executing actions.
Resolve mutations for :app:validateCompileSdkVersion (Thread[included builds,5,main]) started.
:app:validateCompileSdkVersion (Thread[Execution worker Thread 7,5,main]) started.

> Task :app:validateCompileSdkVersion
Caching disabled for task ':app:validateCompileSdkVersion' because:
  Build cache is disabled
Task ':app:validateCompileSdkVersion' is not up-to-date because:
  Task has not declared any outputs despite executing actions.
Resolve mutations for :app:preBuild (Thread[Execution worker Thread 7,5,main]) started.
:app:preBuild (Thread[Execution worker,5,main]) started.

> Task :app:preBuild
Skipping task ':app:preBuild' as it has no actions.
Resolve mutations for :app:preDebugBuild (Thread[Execution worker,5,main]) started.
:app:preDebugBuild (Thread[Execution worker,5,main]) started.

> Task :app:preDebugBuild
Skipping task ':app:preDebugBuild' as it has no actions.
Resolve mutations for :app:mergeDebugNativeDebugMetadata (Thread[Execution worker,5,main]) started.
:app:mergeDebugNativeDebugMetadata (Thread[Execution worker,5,main]) started.

> Task :app:mergeDebugNativeDebugMetadata NO-SOURCE
Skipping task ':app:mergeDebugNativeDebugMetadata' as it has no source files and no previous output files.
Resolve mutations for :app:checkKotlinGradlePluginConfigurationErrors (Thread[Execution worker,5,main]) started.
:app:checkKotlinGradlePluginConfigurationErrors (Thread[Execution worker,5,main]) started.

> Task :app:checkKotlinGradlePluginConfigurationErrors SKIPPED
Skipping task ':app:checkKotlinGradlePluginConfigurationErrors' as task onlyIf 'errorDiagnostics are present' is false.
Resolve mutations for :app:cleanMergeDebugAssets (Thread[Execution worker,5,main]) started.
:app:cleanMergeDebugAssets (Thread[Execution worker,5,main]) started.

> Task :app:cleanMergeDebugAssets UP-TO-DATE
Caching disabled for task ':app:cleanMergeDebugAssets' because:
  Build cache is disabled
Task ':app:cleanMergeDebugAssets' is not up-to-date because:
  Task has not declared any outputs despite executing actions.
Resolve mutations for :app:compileFlutterBuildDebug (Thread[Execution worker,5,main]) started.
:app:compileFlutterBuildDebug (Thread[Execution worker,5,main]) started.

> Task :app:compileFlutterBuildDebug
Caching disabled for task ':app:compileFlutterBuildDebug' because:
  Build cache is disabled
  Caching has not been enabled for the task
Task ':app:compileFlutterBuildDebug' is not up-to-date because:
  Task has failed previously.
Starting process 'command '/home/chris/flutter/bin/flutter''. Working directory: /home/chris/Documents/Trackpoint_app/trackpoint_new/trackpoint_app Command: /home/chris/flutter/bin/flutter --quiet assemble --no-version-check --depfile /home/chris/Documents/Trackpoint_app/trackpoint_new/trackpoint_app/build/app/intermediates/flutter/debug/flutter_build.d --output /home/chris/Documents/Trackpoint_app/trackpoint_new/trackpoint_app/build/app/intermediates/flutter/debug -dTargetFile=lib/main.dart -dTargetPlatform=android -dBuildMode=debug -dTrackWidgetCreation=true -dFlavor= -dAndroidArchs=android-arm android-arm64 android-x64 -dMinSdkVersion=24 debug_android_application
Successfully started process 'command '/home/chris/flutter/bin/flutter''
Error: Couldn't resolve the package 'path_provider' in 'package:path_provider/path_provider.dart'.
Error: Couldn't resolve the package 'share_plus' in 'package:share_plus/share_plus.dart'.
lib/features/history/csv_exporter.dart:2:8: Error: Not found: 'package:path_provider/path_provider.dart'
import 'package:path_provider/path_provider.dart';
       ^
lib/features/history/csv_exporter.dart:3:8: Error: Not found: 'package:share_plus/share_plus.dart'
import 'package:share_plus/share_plus.dart';
       ^
lib/features/geofence/geofence_screen.dart:32:28: Error: The getter 'geofenceProvider' isn't defined for the type '_GeofenceScreenState'.
 - '_GeofenceScreenState' is from 'package:trackpoint/features/geofence/geofence_screen.dart' ('lib/features/geofence/geofence_screen.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'geofenceProvider'.
      final geo = ref.read(geofenceProvider).valueOrNull;
                           ^^^^^^^^^^^^^^^^
lib/features/geofence/geofence_screen.dart:62:35: Error: The getter 'geofenceRepositoryProvider' isn't defined for the type '_GeofenceScreenState'.
 - '_GeofenceScreenState' is from 'package:trackpoint/features/geofence/geofence_screen.dart' ('lib/features/geofence/geofence_screen.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'geofenceRepositoryProvider'.
    final result = await ref.read(geofenceRepositoryProvider).saveGeofence(
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^
lib/features/geofence/geofence_screen.dart:77:24: Error: The getter 'geofenceProvider' isn't defined for the type '_GeofenceScreenState'.
 - '_GeofenceScreenState' is from 'package:trackpoint/features/geofence/geofence_screen.dart' ('lib/features/geofence/geofence_screen.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'geofenceProvider'.
        ref.invalidate(geofenceProvider);
                       ^^^^^^^^^^^^^^^^
lib/features/geofence/geofence_screen.dart:89:35: Error: The getter 'selectedTagLastReportProvider' isn't defined for the type '_GeofenceScreenState'.
 - '_GeofenceScreenState' is from 'package:trackpoint/features/geofence/geofence_screen.dart' ('lib/features/geofence/geofence_screen.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'selectedTagLastReportProvider'.
    final tagPosAsync = ref.watch(selectedTagLastReportProvider);
                                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
lib/features/history/history_screen.dart:82:54: Error: No named parameter with the name 'reports'.
                    data: (points) => HistoryPathMap(reports: points),
                                                     ^^^^^^^
lib/features/history/history_path_map.dart:11:9: Context: Found this candidate, but the arguments don't match.
  const HistoryPathMap({
        ^^^^^^^^^^^^^^
lib/features/history/history_screen.dart:18:32: Error: The getter 'selectedDeviceIdProvider' isn't defined for the type 'HistoryScreen'.
 - 'HistoryScreen' is from 'package:trackpoint/features/history/history_screen.dart' ('lib/features/history/history_screen.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'selectedDeviceIdProvider'.
    final deviceId = ref.watch(selectedDeviceIdProvider);
                               ^^^^^^^^^^^^^^^^^^^^^^^^
lib/features/history/history_screen.dart:165:16: Error: The argument type 'DateTime' can't be assigned to the parameter type 'int?'.
 - 'DateTime' is from 'dart:core'.
      DateTime.fromMillisecondsSinceEpoch(report.srv),
               ^
lib/features/history/csv_exporter.dart:15:23: Error: The method 'getTemporaryDirectory' isn't defined for the type 'ShareCsvExporter'.
 - 'ShareCsvExporter' is from 'package:trackpoint/features/history/csv_exporter.dart' ('lib/features/history/csv_exporter.dart').
Try correcting the name to the name of an existing method, or defining a method named 'getTemporaryDirectory'.
    final dir = await getTemporaryDirectory();
                      ^^^^^^^^^^^^^^^^^^^^^
lib/features/history/csv_exporter.dart:18:11: Error: The getter 'Share' isn't defined for the type 'ShareCsvExporter'.
 - 'ShareCsvExporter' is from 'package:trackpoint/features/history/csv_exporter.dart' ('lib/features/history/csv_exporter.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'Share'.
    await Share.shareXFiles(
          ^^^^^
lib/features/history/csv_exporter.dart:19:8: Error: The method 'XFile' isn't defined for the type 'ShareCsvExporter'.
 - 'ShareCsvExporter' is from 'package:trackpoint/features/history/csv_exporter.dart' ('lib/features/history/csv_exporter.dart').
Try correcting the name to the name of an existing method, or defining a method named 'XFile'.
      [XFile(file.path, mimeType: 'text/csv')],
       ^^^^^
Unhandled exception:
FileSystemException(uri=org-dartlang-untranslatable-uri:package%3Apath_provider%2Fpath_provider.dart; message=StandardFileSystem only supports file:* and data:* URIs)
#0      StandardFileSystem.entityForUri (package:front_end/src/api_prototype/standard_file_system.dart:42)
#1      asFileUri (package:vm/kernel_front_end.dart:1059)
#2      writeDepfile (package:vm/kernel_front_end.dart:1220)
<asynchronous suspension>
#3      FrontendCompiler.compile (package:frontend_server/frontend_server.dart:932)
<asynchronous suspension>
#4      starter (package:frontend_server/starter.dart:108)
<asynchronous suspension>
#5      main (file:///b/s/w/ir/x/w/sdk/pkg/frontend_server/bin/frontend_server_starter.dart:13)
<asynchronous suspension>

Target kernel_snapshot_program failed: Exception


> Task :app:compileFlutterBuildDebug FAILED
Build bc82816c-f85c-4c9a-9082-2ad70e277520 is closed
Build 9f841253-3a68-44df-9698-3cf7169be796 is closed

[Incubating] Problems report is available at: file:///home/chris/Documents/Trackpoint_app/trackpoint_new/trackpoint_app/build/reports/problems/problems-report.html

FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:compileFlutterBuildDebug'.
> Process 'command '/home/chris/flutter/bin/flutter'' finished with non-zero exit value 1

* Try:
> Run with --debug option to get more log output.
> Run with --scan to get full insights from a Build Scan (powered by Develocity).
> Get more help at https://help.gradle.org.

* Exception is:
org.gradle.api.tasks.TaskExecutionException: Execution failed for task ':app:compileFlutterBuildDebug'.
	at org.gradle.api.internal.tasks.execution.ExecuteActionsTaskExecuter.lambda$executeIfValid$1(ExecuteActionsTaskExecuter.java:135)
	at org.gradle.internal.Try$Failure.ifSuccessfulOrElse(Try.java:288)
	at org.gradle.api.internal.tasks.execution.ExecuteActionsTaskExecuter.executeIfValid(ExecuteActionsTaskExecuter.java:133)
	at org.gradle.api.internal.tasks.execution.ExecuteActionsTaskExecuter.execute(ExecuteActionsTaskExecuter.java:121)
	at org.gradle.api.internal.tasks.execution.ProblemsTaskPathTrackingTaskExecuter.execute(ProblemsTaskPathTrackingTaskExecuter.java:41)
	at org.gradle.api.internal.tasks.execution.FinalizePropertiesTaskExecuter.execute(FinalizePropertiesTaskExecuter.java:46)
	at org.gradle.api.internal.tasks.execution.ResolveTaskExecutionModeExecuter.execute(ResolveTaskExecutionModeExecuter.java:51)
	at org.gradle.api.internal.tasks.execution.SkipTaskWithNoActionsExecuter.execute(SkipTaskWithNoActionsExecuter.java:57)
	at org.gradle.api.internal.tasks.execution.SkipOnlyIfTaskExecuter.execute(SkipOnlyIfTaskExecuter.java:74)
	at org.gradle.api.internal.tasks.execution.CatchExceptionTaskExecuter.execute(CatchExceptionTaskExecuter.java:36)
	at org.gradle.api.internal.tasks.execution.EventFiringTaskExecuter$1.executeTask(EventFiringTaskExecuter.java:77)
	at org.gradle.api.internal.tasks.execution.EventFiringTaskExecuter$1.call(EventFiringTaskExecuter.java:55)
	at org.gradle.api.internal.tasks.execution.EventFiringTaskExecuter$1.call(EventFiringTaskExecuter.java:52)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$CallableBuildOperationWorker.execute(DefaultBuildOperationRunner.java:209)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$CallableBuildOperationWorker.execute(DefaultBuildOperationRunner.java:204)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$2.execute(DefaultBuildOperationRunner.java:66)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$2.execute(DefaultBuildOperationRunner.java:59)
	at org.gradle.internal.operations.DefaultBuildOperationRunner.execute(DefaultBuildOperationRunner.java:166)
	at org.gradle.internal.operations.DefaultBuildOperationRunner.execute(DefaultBuildOperationRunner.java:59)
	at org.gradle.internal.operations.DefaultBuildOperationRunner.call(DefaultBuildOperationRunner.java:53)
	at org.gradle.api.internal.tasks.execution.EventFiringTaskExecuter.execute(EventFiringTaskExecuter.java:52)
	at org.gradle.execution.plan.DefaultNodeExecutor.executeLocalTaskNode(DefaultNodeExecutor.java:55)
	at org.gradle.execution.plan.DefaultNodeExecutor.execute(DefaultNodeExecutor.java:34)
	at org.gradle.execution.taskgraph.DefaultTaskExecutionGraph$InvokeNodeExecutorsAction.execute(DefaultTaskExecutionGraph.java:355)
	at org.gradle.execution.taskgraph.DefaultTaskExecutionGraph$InvokeNodeExecutorsAction.execute(DefaultTaskExecutionGraph.java:343)
	at org.gradle.execution.taskgraph.DefaultTaskExecutionGraph$BuildOperationAwareExecutionAction.lambda$execute$0(DefaultTaskExecutionGraph.java:339)
	at org.gradle.internal.operations.CurrentBuildOperationRef.with(CurrentBuildOperationRef.java:84)
	at org.gradle.execution.taskgraph.DefaultTaskExecutionGraph$BuildOperationAwareExecutionAction.execute(DefaultTaskExecutionGraph.java:339)
	at org.gradle.execution.taskgraph.DefaultTaskExecutionGraph$BuildOperationAwareExecutionAction.execute(DefaultTaskExecutionGraph.java:328)
	at org.gradle.execution.plan.DefaultPlanExecutor$ExecutorWorker.execute(DefaultPlanExecutor.java:459)
	at org.gradle.execution.plan.DefaultPlanExecutor$ExecutorWorker.run(DefaultPlanExecutor.java:376)
	at org.gradle.internal.concurrent.ExecutorPolicy$CatchAndRecordFailures.onExecute(ExecutorPolicy.java:64)
	at org.gradle.internal.concurrent.AbstractManagedExecutor$1.run(AbstractManagedExecutor.java:47)
Caused by: org.gradle.process.ProcessExecutionException: Process 'command '/home/chris/flutter/bin/flutter'' finished with non-zero exit value 1
	at org.gradle.process.internal.DefaultExecHandle$ExecResultImpl.assertNormalExitValue(DefaultExecHandle.java:454)
	at org.gradle.process.internal.DefaultExecAction.execute(DefaultExecAction.java:49)
	at org.gradle.process.internal.DefaultExecActionFactory.exec(DefaultExecActionFactory.java:216)
	at org.gradle.process.internal.DefaultExecOperations.exec(DefaultExecOperations.java:37)
	at com.flutter.gradle.tasks.BaseFlutterTaskHelper.buildBundle(BaseFlutterTaskHelper.kt:159)
	at com.flutter.gradle.tasks.BaseFlutterTask.buildBundle(BaseFlutterTask.kt:143)
	at com.flutter.gradle.tasks.FlutterTaskHelper.build$gradle(FlutterTaskHelper.kt:90)
	at com.flutter.gradle.tasks.FlutterTask.build(FlutterTask.kt:51)
	at org.gradle.internal.reflect.JavaMethod.invoke(JavaMethod.java:125)
	at org.gradle.api.internal.project.taskfactory.StandardTaskAction.doExecute(StandardTaskAction.java:58)
	at org.gradle.api.internal.project.taskfactory.StandardTaskAction.execute(StandardTaskAction.java:51)
	at org.gradle.api.internal.project.taskfactory.StandardTaskAction.execute(StandardTaskAction.java:29)
	at org.gradle.api.internal.tasks.execution.TaskExecution$3.run(TaskExecution.java:259)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$1.execute(DefaultBuildOperationRunner.java:29)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$1.execute(DefaultBuildOperationRunner.java:26)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$2.execute(DefaultBuildOperationRunner.java:66)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$2.execute(DefaultBuildOperationRunner.java:59)
	at org.gradle.internal.operations.DefaultBuildOperationRunner.execute(DefaultBuildOperationRunner.java:166)
	at org.gradle.internal.operations.DefaultBuildOperationRunner.execute(DefaultBuildOperationRunner.java:59)
	at org.gradle.internal.operations.DefaultBuildOperationRunner.run(DefaultBuildOperationRunner.java:47)
	at org.gradle.api.internal.tasks.execution.TaskExecution.executeAction(TaskExecution.java:244)
	at org.gradle.api.internal.tasks.execution.TaskExecution.executeActions(TaskExecution.java:227)
	at org.gradle.api.internal.tasks.execution.TaskExecution.executeWithPreviousOutputFiles(TaskExecution.java:210)
	at org.gradle.api.internal.tasks.execution.TaskExecution.execute(TaskExecution.java:176)
	at org.gradle.internal.execution.steps.ExecuteStep.executeInternal(ExecuteStep.java:110)
	at org.gradle.internal.execution.steps.ExecuteStep.access$000(ExecuteStep.java:47)
	at org.gradle.internal.execution.steps.ExecuteStep$1.call(ExecuteStep.java:64)
	at org.gradle.internal.execution.steps.ExecuteStep$1.call(ExecuteStep.java:61)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$CallableBuildOperationWorker.execute(DefaultBuildOperationRunner.java:209)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$CallableBuildOperationWorker.execute(DefaultBuildOperationRunner.java:204)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$2.execute(DefaultBuildOperationRunner.java:66)
	at org.gradle.internal.operations.DefaultBuildOperationRunner$2.execute(DefaultBuildOperationRunner.java:59)
	at org.gradle.internal.operations.DefaultBuildOperationRunner.execute(DefaultBuildOperationRunner.java:166)
	at org.gradle.internal.operations.DefaultBuildOperationRunner.execute(DefaultBuildOperationRunner.java:59)
	at org.gradle.internal.operations.DefaultBuildOperationRunner.call(DefaultBuildOperationRunner.java:53)
	at org.gradle.internal.execution.steps.ExecuteStep.execute(ExecuteStep.java:61)
	at org.gradle.internal.execution.steps.ExecuteStep.execute(ExecuteStep.java:47)
	at org.gradle.internal.execution.steps.CancelExecutionStep.execute(CancelExecutionStep.java:42)
	at org.gradle.internal.execution.steps.TimeoutStep.executeWithoutTimeout(TimeoutStep.java:75)
	at org.gradle.internal.execution.steps.TimeoutStep.execute(TimeoutStep.java:55)
	at org.gradle.internal.execution.steps.PreCreateOutputParentsStep.execute(PreCreateOutputParentsStep.java:51)
	at org.gradle.internal.execution.steps.PreCreateOutputParentsStep.execute(PreCreateOutputParentsStep.java:29)
	at org.gradle.internal.execution.steps.RemovePreviousOutputsStep.executeMutable(RemovePreviousOutputsStep.java:70)
	at org.gradle.internal.execution.steps.RemovePreviousOutputsStep.executeMutable(RemovePreviousOutputsStep.java:40)
	at org.gradle.internal.execution.steps.MutableStep.execute(MutableStep.java:25)
	at org.gradle.internal.execution.steps.BroadcastChangingOutputsStep.execute(BroadcastChangingOutputsStep.java:62)
	at org.gradle.internal.execution.steps.BroadcastChangingOutputsStep.execute(BroadcastChangingOutputsStep.java:27)
	at org.gradle.internal.execution.steps.CaptureOutputsAfterExecutionStep.execute(CaptureOutputsAfterExecutionStep.java:69)
	at org.gradle.internal.execution.steps.CaptureOutputsAfterExecutionStep.execute(CaptureOutputsAfterExecutionStep.java:46)
	at org.gradle.internal.execution.steps.ResolveInputChangesStep.executeMutable(ResolveInputChangesStep.java:39)
	at org.gradle.internal.execution.steps.ResolveInputChangesStep.executeMutable(ResolveInputChangesStep.java:28)
	at org.gradle.internal.execution.steps.MutableStep.execute(MutableStep.java:25)
	at org.gradle.internal.execution.steps.BuildCacheStep.executeWithoutCache(BuildCacheStep.java:192)
	at org.gradle.internal.execution.steps.BuildCacheStep.lambda$execute$1(BuildCacheStep.java:76)
	at org.gradle.internal.Either$Right.fold(Either.java:176)
	at org.gradle.internal.execution.caching.CachingState.fold(CachingState.java:62)
	at org.gradle.internal.execution.steps.BuildCacheStep.execute(BuildCacheStep.java:74)
	at org.gradle.internal.execution.steps.BuildCacheStep.execute(BuildCacheStep.java:49)
	at org.gradle.internal.execution.steps.StoreExecutionStateStep.execute(StoreExecutionStateStep.java:46)
	at org.gradle.internal.execution.steps.StoreExecutionStateStep.execute(StoreExecutionStateStep.java:35)
	at org.gradle.internal.execution.steps.SkipUpToDateStep.executeBecause(SkipUpToDateStep.java:75)
	at org.gradle.internal.execution.steps.SkipUpToDateStep.lambda$execute$2(SkipUpToDateStep.java:53)
	at org.gradle.internal.execution.steps.SkipUpToDateStep.execute(SkipUpToDateStep.java:53)
	at org.gradle.internal.execution.steps.SkipUpToDateStep.execute(SkipUpToDateStep.java:35)
	at org.gradle.internal.execution.steps.legacy.MarkSnapshottingInputsFinishedStep.execute(MarkSnapshottingInputsFinishedStep.java:37)
	at org.gradle.internal.execution.steps.legacy.MarkSnapshottingInputsFinishedStep.execute(MarkSnapshottingInputsFinishedStep.java:27)
	at org.gradle.internal.execution.steps.ResolveIncrementalCachingStateStep.executeDelegate(ResolveIncrementalCachingStateStep.java:49)
	at org.gradle.internal.execution.steps.ResolveIncrementalCachingStateStep.executeDelegate(ResolveIncrementalCachingStateStep.java:27)
	at org.gradle.internal.execution.steps.AbstractResolveCachingStateStep.execute(AbstractResolveCachingStateStep.java:71)
	at org.gradle.internal.execution.steps.AbstractResolveCachingStateStep.execute(AbstractResolveCachingStateStep.java:39)
	at org.gradle.internal.execution.steps.ResolveChangesStep.executeMutable(ResolveChangesStep.java:63)
	at org.gradle.internal.execution.steps.ResolveChangesStep.executeMutable(ResolveChangesStep.java:34)
	at org.gradle.internal.execution.steps.MutableStep.execute(MutableStep.java:25)
	at org.gradle.internal.execution.steps.ValidateStep.execute(ValidateStep.java:64)
	at org.gradle.internal.execution.steps.ValidateStep.execute(ValidateStep.java:42)
	at org.gradle.internal.execution.steps.AbstractCaptureStateBeforeExecutionStep.execute(AbstractCaptureStateBeforeExecutionStep.java:77)
	at org.gradle.internal.execution.steps.AbstractCaptureStateBeforeExecutionStep.execute(AbstractCaptureStateBeforeExecutionStep.java:46)
	at org.gradle.internal.execution.steps.AbstractSkipEmptyWorkStep.executeWithNonEmptySources(AbstractSkipEmptyWorkStep.java:133)
	at org.gradle.internal.execution.steps.AbstractSkipEmptyWorkStep.execute(AbstractSkipEmptyWorkStep.java:59)
	at org.gradle.internal.execution.steps.AbstractSkipEmptyWorkStep.execute(AbstractSkipEmptyWorkStep.java:36)
	at org.gradle.internal.execution.steps.legacy.MarkSnapshottingInputsStartedStep.execute(MarkSnapshottingInputsStartedStep.java:38)
	at org.gradle.internal.execution.steps.LoadPreviousExecutionStateStep.execute(LoadPreviousExecutionStateStep.java:36)
	at org.gradle.internal.execution.steps.LoadPreviousExecutionStateStep.execute(LoadPreviousExecutionStateStep.java:23)
	at org.gradle.internal.execution.steps.HandleStaleOutputsStep.executeMutable(HandleStaleOutputsStep.java:77)
	at org.gradle.internal.execution.steps.HandleStaleOutputsStep.executeMutable(HandleStaleOutputsStep.java:43)
	at org.gradle.internal.execution.steps.MutableStep.execute(MutableStep.java:25)
	at org.gradle.internal.execution.steps.AssignMutableWorkspaceStep.lambda$execute$0(AssignMutableWorkspaceStep.java:35)
	at org.gradle.api.internal.tasks.execution.TaskExecution$4.withWorkspace(TaskExecution.java:305)
	at org.gradle.internal.execution.steps.AssignMutableWorkspaceStep.execute(AssignMutableWorkspaceStep.java:31)
	at org.gradle.internal.execution.steps.AssignMutableWorkspaceStep.execute(AssignMutableWorkspaceStep.java:22)
	at org.gradle.internal.execution.steps.ChoosePipelineStep.execute(ChoosePipelineStep.java:40)
	at org.gradle.internal.execution.steps.ChoosePipelineStep.execute(ChoosePipelineStep.java:23)
	at org.gradle.internal.execution.steps.ExecuteWorkBuildOperationFiringStep.lambda$execute$2(ExecuteWorkBuildOperationFiringStep.java:67)
	at org.gradle.internal.execution.steps.ExecuteWorkBuildOperationFiringStep.execute(ExecuteWorkBuildOperationFiringStep.java:67)
	at org.gradle.internal.execution.steps.ExecuteWorkBuildOperationFiringStep.execute(ExecuteWorkBuildOperationFiringStep.java:39)
	at org.gradle.internal.execution.steps.IdentityCacheStep.execute(IdentityCacheStep.java:46)
	at org.gradle.internal.execution.steps.IdentityCacheStep.execute(IdentityCacheStep.java:34)
	at org.gradle.internal.execution.steps.IdentifyStep.execute(IdentifyStep.java:44)
	at org.gradle.internal.execution.steps.IdentifyStep.execute(IdentifyStep.java:31)
	at org.gradle.internal.execution.impl.DefaultExecutionEngine$1.execute(DefaultExecutionEngine.java:68)
	at org.gradle.api.internal.tasks.execution.ExecuteActionsTaskExecuter.executeIfValid(ExecuteActionsTaskExecuter.java:132)
	... 30 more


Deprecated Gradle features were used in this build, making it incompatible with Gradle 10.

You can use '--warning-mode all' to show the individual deprecation warnings and determine if they come from your own scripts or plugins.

For more on this, please refer to https://docs.gradle.org/9.3.1/userguide/command_line_interface.html#sec:command_line_warnings in the Gradle documentation.

BUILD FAILED in 12s
8 actionable tasks: 3 executed, 5 up-to-date
