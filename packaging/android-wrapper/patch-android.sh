#!/usr/bin/env bash
# Turns the freshly generated Capacitor project (android/) into the real Velvet & Roulette app:
#   - permissions: no INTERNET (fonts ship with the page); only VIBRATE, for haptics (keeping the screen on needs none)
#   - allowBackup off: the limits sheet never goes into a cloud backup
#   - launcher icon, dark splash / status bar / navigation bar in the app's own ground colour
#   - Velvet plugin (private screen + keep-screen-on window flags) registered in MainActivity
#   - version + signing from the environment (see native/vr.gradle)
# Run from packaging/android-wrapper after `npx cap add android` (or `npx cap sync android`). Idempotent.
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"
A="$HERE/android/app/src/main"
[ -d "$A" ] || { echo "android/ not found — run 'npx cap add android' first"; exit 1; }

python3 - "$A" << 'EOF'
import re, sys, os
A = sys.argv[1]

# ---- manifest: permissions and backup ----
p = os.path.join(A, 'AndroidManifest.xml'); s = open(p, encoding='utf-8').read()
s = re.sub(r'\s*<uses-permission android:name="android\.permission\.(INTERNET|VIBRATE|WAKE_LOCK)"\s*/>', '', s)
s = s.replace('</manifest>',
    '    <!-- No INTERNET: the whole game is inside the app and never talks to a server. -->\n'
    '    <uses-permission android:name="android.permission.VIBRATE" /> <!-- haptics on spins and bells; the only permission -->\n'
    '</manifest>')
s = s.replace('android:allowBackup="true"', 'android:allowBackup="false"')
open(p, 'w', encoding='utf-8').write(s)

# ---- colours ----
vals = os.path.join(A, 'res', 'values')
open(os.path.join(vals, 'colors.xml'), 'w', encoding='utf-8').write(
    '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n'
    '    <color name="vr_ground">#160A10</color>\n'
    '    <color name="colorPrimary">#E4587A</color>\n'
    '    <color name="colorPrimaryDark">#160A10</color>\n'
    '    <color name="colorAccent">#D9A360</color>\n'
    '</resources>\n')
lb = os.path.join(vals, 'ic_launcher_background.xml')
open(lb, 'w', encoding='utf-8').write(
    '<?xml version="1.0" encoding="utf-8"?>\n<resources>\n    <color name="ic_launcher_background">#160A10</color>\n</resources>\n')

# ---- theme: dark everywhere, no white flash, splash on the ground colour ----
p = os.path.join(vals, 'styles.xml'); s = open(p, encoding='utf-8').read()
dark = ('        <item name="android:statusBarColor">@color/vr_ground</item>\n'
        '        <item name="android:navigationBarColor">@color/vr_ground</item>\n'
        '        <item name="android:windowLightStatusBar">false</item>\n'
        '        <item name="android:windowLightNavigationBar">false</item>\n')
s = s.replace('<style name="AppTheme.NoActionBar" parent="Theme.AppCompat.DayNight.NoActionBar">\n',
              '<style name="AppTheme.NoActionBar" parent="Theme.AppCompat.DayNight.NoActionBar">\n' + dark +
              '        <item name="android:windowBackground">@color/vr_ground</item>\n')
s = s.replace('        <item name="android:background">@drawable/splash</item>\n',
              dark +
              '        <item name="android:background">@color/vr_ground</item>\n'
              '        <item name="windowSplashScreenBackground">@color/vr_ground</item>\n'
              '        <item name="windowSplashScreenAnimatedIcon">@mipmap/ic_launcher</item>\n')
open(p, 'w', encoding='utf-8').write(s)
print('manifest, colours and theme patched')
EOF

# ---- launcher icons (rendered once from packaging/android-wrapper/res, see icon-source.html) ----
for d in mdpi hdpi xhdpi xxhdpi xxxhdpi; do
  mkdir -p "$A/res/mipmap-$d"
  cp "$HERE/res/mipmap-$d/ic_launcher.png" "$HERE/res/mipmap-$d/ic_launcher_round.png" "$HERE/res/mipmap-$d/ic_launcher_foreground.png" "$A/res/mipmap-$d/"
done

# ---- native code ----
PKG="$A/java/com/scottsart/velvetroulette"
mkdir -p "$PKG"
cp "$HERE/native/VelvetPlugin.java" "$HERE/native/MainActivity.java" "$PKG/"

# ---- version + signing ----
cp "$HERE/native/vr.gradle" "$HERE/android/app/vr.gradle"
grep -q "apply from: 'vr.gradle'" "$HERE/android/app/build.gradle" || printf "\napply from: 'vr.gradle'\n" >> "$HERE/android/app/build.gradle"

echo "android/ patched: permissions, backup off, icons, theme, Velvet plugin, version/signing hook"
