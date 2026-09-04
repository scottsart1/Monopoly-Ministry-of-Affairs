# Android app

Wraps the root `index.html` in a Capacitor WebView shell so it ships as an
installable `.apk`. The native `android/` project and the `www/` copy of the
game are generated on demand, not committed; `patch-android.sh` then turns the
generic Capacitor template into the real app:

- **Permissions:** only `VIBRATE` (haptics). No `INTERNET` — the fonts ship
  with the page (`../../fonts`), so the app cannot reach the network at all.
- **No cloud backup** (`allowBackup=false`): the Limits Sheet never goes into
  a Google backup.
- **Private screen:** a tiny native plugin (`native/VelvetPlugin.java`) sets
  `FLAG_SECURE` so the app is blank in the app switcher and screenshots are
  blocked. It's on by default and can be switched off in the in-app menu.
- **Screen stays on** during rounds, scenes and sessions (same plugin, a window
  flag — no permission needed).
- **Back button** closes the top layer through its own harmless button, never
  ends a round or a scene, and at the wheel just backgrounds the app
  (`@capacitor/app`).
- **Launcher icon**, dark splash, status and navigation bars in the app's own
  ground colour (`res/`; regenerate with `node res/render-icons.js` after
  editing `res/icon-source.html`).
- **Version and signing** come from the environment (`native/vr.gradle`).

## Getting a new APK

Push a tag matching `apk-v*` (e.g. `apk-v1.1`), or run the **Release Android
APK** workflow from the Actions tab. It publishes a GitHub Release with the
APK attached.

### Stable signing (recommended — do this once)

Without it, each CI run signs with a fallback debug key. Android refuses to
install an APK over one signed with a different key, so you'd have to
uninstall first — and that wipes everything saved in the app. Add these four
repository secrets (**Settings → Secrets and variables → Actions**) and every
build will be signed with the same release key:

| Secret | Value |
| --- | --- |
| `ANDROID_KEYSTORE_B64` | the keystore file, base64-encoded (`base64 -w0 vr-release.jks`) |
| `ANDROID_KEYSTORE_PASSWORD` | the keystore password |
| `ANDROID_KEY_ALIAS` | `velvetroulette` |
| `ANDROID_KEY_PASSWORD` | the key password (same as the keystore password) |

Never commit the keystore — this repository is public.

## Building locally

```sh
cd packaging/android-wrapper
npm install
mkdir -p www && cp ../../index.html www/index.html && cp -r ../../fonts www/fonts
npx cap add android            # first time; afterwards: npx cap sync android
bash ./patch-android.sh
cd android
echo "sdk.dir=$ANDROID_HOME" > local.properties
# optional, for an upgrade-compatible build:
#   export VR_KEYSTORE=/path/vr-release.jks VR_KEYSTORE_PASSWORD=… VR_KEY_ALIAS=velvetroulette VR_KEY_PASSWORD=…
#   export VR_VERSION_CODE=42 VR_VERSION_NAME=1.42
./gradlew assembleDebug        # or assembleRelease when a keystore is set
# APK at app/build/outputs/apk/{debug,release}/app-{debug,release}.apk
```

Requires a JDK and the Android SDK (`platform-tools`, `platforms;android-34`,
`build-tools;34.0.0`).
