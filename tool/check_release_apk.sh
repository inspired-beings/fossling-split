#!/usr/bin/env bash
# Sustainable-design and privacy gates over the BUILT release APK: size budget,
# merged-manifest permissions, effective minSdk and the auto-backup opt-out. Reads the
# final artifact on purpose — plugins merge permissions and manifest attributes and can
# raise minSdk, so the source manifest and Gradle config are not proof.
#
# Every threshold below ratchets one way only (smaller APK, lower minSdk, fewer
# permissions). Loosening one is a product-owner decision, never a build fix.
set -euo pipefail

readonly APK="${1:-build/app/outputs/flutter-apk/app-release.apk}"

# Set from this app's measured baseline (universal release APK) + ~15% headroom at the
# first release, then only lower it. The template ships no number on purpose — an
# inherited budget is a silent pass, not a baseline.
readonly MAX_MIB=49
# Old-device reach: a higher floor drops users off the app.
readonly MAX_MIN_SDK=26
# No networking, no background work, no boot hooks. Remove a network entry ONLY when
# networking is a real user-facing feature of this app (Fossling privacy posture) —
# plugins often merge these in for features the app never uses; strip them with
# tools:node="remove" in android/app/src/main/AndroidManifest.xml instead.
readonly FORBIDDEN_PERMISSIONS=(
  android.permission.INTERNET
  android.permission.ACCESS_NETWORK_STATE
  android.permission.WAKE_LOCK
  android.permission.RECEIVE_BOOT_COMPLETED
)
# Matched as prefixes: FOREGROUND_SERVICE plus every FOREGROUND_SERVICE_* subtype.
readonly FORBIDDEN_PERMISSION_PREFIXES=(
  android.permission.FOREGROUND_SERVICE
)

failed=0

fail() {
  echo "::error::$1"
  failed=1
}

if [[ ! "$MAX_MIB" =~ ^[0-9]+$ ]]; then
  fail "MAX_MIB is not baselined for this app — set it in tool/check_release_apk.sh from the first release build + ~15% headroom"
  exit 1
fi

if [[ ! -f "$APK" ]]; then
  fail "no APK at $APK — build it before running this check"
  exit 1
fi

aapt2="$(find "${ANDROID_HOME:?ANDROID_HOME is not set}/build-tools" -name aapt2 -type f | sort -Vr | head -1)"
if [[ ! -x "$aapt2" ]]; then
  fail "aapt2 not found under $ANDROID_HOME/build-tools"
  exit 1
fi

# Size budget
bytes="$(stat -c %s "$APK")"
mib=$((bytes / 1024 / 1024))
echo "Release APK size: ${mib} MiB (${bytes} bytes), budget ${MAX_MIB} MiB"
if ((bytes > MAX_MIB * 1024 * 1024)); then
  fail "release APK is ${mib} MiB, over the ${MAX_MIB} MiB budget"
fi

badging="$("$aapt2" dump badging "$APK")"

# Merged-manifest permissions
permissions="$(printf '%s\n' "$badging" | sed -n "s/^uses-permission: name='\([^']*\)'.*/\1/p")"
echo "Merged permissions:"
printf '%s\n' "$permissions" | sed 's/^/  /'
while read -r permission; do
  [[ -n "$permission" ]] || continue
  for forbidden in "${FORBIDDEN_PERMISSIONS[@]}"; do
    if [[ "$permission" == "$forbidden" ]]; then
      fail "forbidden permission in the merged manifest: $permission"
    fi
  done
  for prefix in "${FORBIDDEN_PERMISSION_PREFIXES[@]}"; do
    if [[ "$permission" == "$prefix"* ]]; then
      fail "forbidden permission in the merged manifest: $permission"
    fi
  done
done <<<"$permissions"

# Effective minSdk
min_sdk="$(printf '%s\n' "$badging" | sed -n "s/^minSdkVersion:'\([0-9]*\)'/\1/p")"
echo "Effective minSdk: ${min_sdk:-unknown} (anchor ${MAX_MIN_SDK})"
if [[ -z "$min_sdk" ]]; then
  fail "could not read minSdkVersion from the APK"
elif ((min_sdk > MAX_MIN_SDK)); then
  fail "effective minSdk is $min_sdk, above the $MAX_MIN_SDK anchor"
fi

# Auto-backup opt-out. The ledger holds third-party payment hints (IBANs) that must
# never leave the device — Android auto-backup would copy them to the user's Google
# Drive. A library can flip allowBackup back on through manifest merging, so assert it
# on the artifact.
manifest="$("$aapt2" dump xmltree --file AndroidManifest.xml "$APK")"

# aapt2 renders booleans as `false` (newer) or `(type 0x12)0x0` (older).
allow_backup="$(printf '%s\n' "$manifest" |
  sed -n 's/.*android:allowBackup([^)]*)=//p' | head -1)"
echo "android:allowBackup: ${allow_backup:-unset}"
if [[ "$allow_backup" != "false" && "$allow_backup" != *0x0 ]]; then
  fail "android:allowBackup must be false in the merged manifest (got '${allow_backup:-unset}')"
fi

if ! printf '%s\n' "$manifest" | grep -q 'android:dataExtractionRules('; then
  fail "android:dataExtractionRules is missing from the merged manifest"
fi

exit "$failed"
