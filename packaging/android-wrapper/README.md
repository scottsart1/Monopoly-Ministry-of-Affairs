# Android wrapper

Wraps the root `index.html` in a Capacitor WebView shell so it can ship as an
installable `.apk`. The native `android/` project and `www/` copy of the game
are generated on demand, not committed — see the workflow below.

## Getting a new APK

Push a tag matching `apk-v*` (e.g. `apk-v1.0.1`), or run the **Release Android
APK** workflow manually from the Actions tab. It builds a debug-signed APK
from the current `index.html` and attaches it to a new GitHub Release.

## Building locally

```sh
cd packaging/android-wrapper
npm install
mkdir -p www && cp ../../index.html www/index.html
npx cap add android      # first time only; use `npx cap sync android` after
cd android
echo "sdk.dir=$ANDROID_HOME" > local.properties
./gradlew assembleDebug
# APK at android/app/build/outputs/apk/debug/app-debug.apk
```

Requires a JDK and the Android SDK (`platform-tools`, `platforms;android-34`,
`build-tools;34.0.0`).

This produces a **debug-signed** APK — fine for sideloading on your own
phone, but Android will flag it as coming from an unverified developer.
That's expected; there's no Play Store distribution here.
