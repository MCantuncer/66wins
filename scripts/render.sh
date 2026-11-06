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
    # Wait for the first real frame. A cold launch on CI can take longer than a fixed
    # sleep; an undrawn app gives an all-black frame that compresses to a tiny PNG.
    sleep 3
    for attempt in 1 2 3 4 5 6; do
      xcrun simctl io "$DEVICE" screenshot "$OUT/$id-$mode.png" >/dev/null
      SIZE=$(stat -f%z "$OUT/$id-$mode.png" 2>/dev/null || stat -c%s "$OUT/$id-$mode.png")
      if [ "$SIZE" -gt 120000 ]; then break; fi
      echo "  $id-$mode looks blank ($SIZE bytes), retry $attempt"
      sleep 2
    done
    # Let springs and fades settle, then take the final frame.
    sleep 1
    xcrun simctl io "$DEVICE" screenshot "$OUT/$id-$mode.png" >/dev/null
    echo "rendered $OUT/$id-$mode.png"
  done
done
