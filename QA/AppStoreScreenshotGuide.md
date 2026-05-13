# Squart App Store Screenshot Guide

This guide documents how to capture deterministic App Store screenshots using Squart's DEBUG screenshot scenes.

## 1) Preconditions
- Build configuration: `Debug`
- Screenshot scene system is enabled through launch arguments.
- Do not use screenshot launch flags for release/archive builds.

## 2) Set Launch Argument in Xcode
1. Open Xcode.
2. Select scheme `Squart`.
3. Go to `Product > Scheme > Edit Scheme...`.
4. Select `Run` tab.
5. Open `Arguments`.
6. Under `Arguments Passed On Launch`, add:
   - `-screenshotScene`
   - `<sceneName>`
7. Run the app.

Example:
- `-screenshotScene`
- `board3DCinematic`

## 3) Available Scene Names
- `board2DMidgame`
- `board3DCinematic`
- `dailyChallenge`
- `premiumThemeShowcase`
- `diamondBoard`
- `circleBoard`
- `triangleBoard`
- `aiThinking`
- `gameOver`
- `board12x12`

## 4) Recommended App Store Capture Order
1. 3D Board hero: `board3DCinematic`
2. Daily Challenge: `dailyChallenge`
3. 2D Board: `board2DMidgame`
4. Premium themes: `premiumThemeShowcase`
5. Tactical result/end state: `gameOver`

## 5) Recommended Devices
- iPhone 6.9" class screenshot set
- iPhone 6.5" class screenshot set
- iPad set (if submitting iPad screenshots)

Use matching simulator/device families for each required App Store Connect slot.

## 6) Practical Capture Steps
1. Set launch argument for target scene.
2. Run app and wait until scene is fully rendered.
3. Capture screenshot:
   - Simulator: `File > Save Screen Shot`
   - Device: hardware screenshot buttons
4. Repeat for each scene and device class.

## 7) Keep Screenshot Mode Internal
- Screenshot scene activation is for DEBUG workflow only.
- Remove/disable screenshot launch args before any release validation.
- Do not rely on screenshot flags in Archive/TestFlight configuration.

## 8) Clean Capture Tips
- Hide simulator chrome where possible:
  - macOS Simulator menu: `Window > Show Device Bezels` (toggle off if needed)
  - Use clean framing and consistent orientation.
- Keep status bar and safe-area presentation consistent across the set.
- Capture after animations settle to avoid transitional frames.

## 9) Overlay/Post-Processing Note
- Use LaunchFrame later for marketing text overlays/captions.
- Keep raw captures clean and text-free where possible.

## 10) Optional CLI Placeholders (if needed later)
ImageMagick resize example:
```bash
magick input.png -resize 1290x2796 output-6_9.png
```

ffmpeg frame extraction example (if using recorded clips):
```bash
ffmpeg -i input.mov -vf "select=eq(n\\,120)" -vframes 1 frame.png
```

Use these only as optional post-processing helpers; canonical source should remain deterministic in-app scenes.
