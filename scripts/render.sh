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
    for launch in 1 2 3; do
      xcrun simctl terminate "$DEVICE" "$BUNDLE" 2>/dev/null || true
      if [ "$mode" = light ]; then xcrun simctl launch "$DEVICE" "$BUNDLE" -screen "$id" -light >/dev/null
      else xcrun simctl launch "$DEVICE" "$BUNDLE" -screen "$id" >/dev/null; fi
      # An undrawn app gives an all-black frame that compresses to a tiny PNG.
      sleep 4
      SIZE=0
      for attempt in 1 2 3 4; do
        xcrun simctl io "$DEVICE" screenshot "$OUT/$id-$mode.png" >/dev/null
        SIZE=$(stat -f%z "$OUT/$id-$mode.png" 2>/dev/null || stat -c%s "$OUT/$id-$mode.png")
        [ "$SIZE" -gt 120000 ] && break
        sleep 2
      done
      if [ "$SIZE" -gt 120000 ]; then
        # Let springs and fades settle, then take the final frame (keep it only if not blank).
        sleep 1
        xcrun simctl io "$DEVICE" screenshot "$OUT/tmp.png" >/dev/null
        TSIZE=$(stat -f%z "$OUT/tmp.png" 2>/dev/null || stat -c%s "$OUT/tmp.png")
        if [ "$TSIZE" -gt 120000 ]; then mv "$OUT/tmp.png" "$OUT/$id-$mode.png"; else rm -f "$OUT/tmp.png"; fi
        break
      fi
      echo "  $id-$mode blank after launch $launch, relaunching"
    done
    echo "rendered $OUT/$id-$mode.png"
  done
done
