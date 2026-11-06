#!/bin/bash
# Renders every design screen to PNG using the iOS Simulator (real SF fonts, materials, dark mode).
# Usage: scripts/render.sh [output-dir]   (run from the repo root on a Mac with Xcode 26+)
set -euo pipefail
OUT="${1:-renders}"
if [ -z "${DEVICE:-}" ]; then
  DEVICE=$(xcrun simctl list devices available | grep -oE 'iPhone [0-9]+ Pro \(' | head -1 | sed 's/ ($//')
  [ -z "$DEVICE" ] && DEVICE=$(xcrun simctl list devices available | grep -oE 'iPhone [^()]+ \(' | head -1 | sed 's/ ($//')
fi
echo "Using simulator: $DEVICE"
BUNDLE=com.mcantuncer.wins66
mkdir -p "$OUT"

xcrun simctl boot "$DEVICE" 2>/dev/null || true
xcrun simctl bootstatus "$DEVICE" -b >/dev/null
# Clean status bar for screenshots
xcrun simctl status_bar "$DEVICE" override --time "9:41" --batteryState charged --batteryLevel 100 --cellularBars 4 --wifiBars 3

xcodebuild -project 66wins.xcodeproj -scheme 66wins -configuration Debug \
  -destination "platform=iOS Simulator,name=$DEVICE" -derivedDataPath build -quiet build
APP=$(find build/Build/Products -name "66wins.app" -path "*iphonesimulator*" | head -1)
xcrun simctl install "$DEVICE" "$APP"

IDS=$(grep -vE '^\s*//' Wins/DesignCatalog.swift | grep -oE 'Entry\(id: "[^"]+"' | sed -E 's/.*"([^"]+)"/\1/')
for id in $IDS; do
  for mode in dark light; do
    xcrun simctl terminate "$DEVICE" "$BUNDLE" 2>/dev/null || true
    if [ "$mode" = light ]; then xcrun simctl launch "$DEVICE" "$BUNDLE" -screen "$id" -light >/dev/null
    else xcrun simctl launch "$DEVICE" "$BUNDLE" -screen "$id" >/dev/null; fi
    sleep 2.5
    xcrun simctl io "$DEVICE" screenshot "$OUT/$id-$mode.png" >/dev/null
    echo "rendered $OUT/$id-$mode.png"
  done
done
