# Squart App Preview Production Guide

## Goal
Create short, premium App Preview videos that represent real Squart gameplay and visual quality.

## 1) Recommended App Preview Structure
1. Hook / hero moment (strong 3D board opening)
2. 3D Board gameplay (preview + placement + camera move)
3. 2D Board gameplay (clarity and tactical readability)
4. Daily Challenge moment (banner + role/order context)
5. Theme switching moment (subtle visual transition)
6. Closing tactical moment (tight late-game or game-over board)

## 2) Recommended Duration
- Target: `15–30s`
- Keep pacing quick and intentional.
- Use minimal overlay text.
- Prefer fewer, cleaner cuts over many short fragments.

## 3) Recommended Capture Scenes (from screenshot/debug system)
Use launch argument:
- `-screenshotScene board3DCinematic`
- `-screenshotScene board2DMidgame`
- `-screenshotScene dailyChallenge`
- `-screenshotScene premiumThemeShowcase`
- `-screenshotScene aiThinking`
- `-screenshotScene gameOver`
- `-screenshotScene board12x12`

## 4) Recording Workflow
### Simulator recording
1. Set scene launch args in scheme.
2. Launch app in portrait simulator matching target size.
3. Start recording in Simulator.
4. Perform minimal scripted interactions.
5. Stop recording and save clip.

### Device recording
1. Use same deterministic launch scene flow.
2. Record with native screen recording.
3. Keep gestures clean and deliberate.

### Capture hygiene
- Hide simulator chrome where possible.
- Keep portrait orientation unless App Store slot requires otherwise.
- Use consistent status bar style across clips.
- Wait for animations to settle before key moments.

## 5) Suggested Sequence Example (20–25s)
1. `0:00–0:03` 3D cinematic open (`board3DCinematic`)
2. `0:03–0:07` Rotate board + one tactical placement
3. `0:07–0:11` Switch to 2D, show fast readable move exchange
4. `0:11–0:15` Daily Challenge scene (`dailyChallenge`) with banner visible
5. `0:15–0:19` Theme transition (`premiumThemeShowcase` + in-game themed board)
6. `0:19–0:23` Closing tactical state (`gameOver` or tight endgame board)

## 6) Suggested Overlay Text Ideas
Keep overlays very short:
- `Quiet Tactical Play`
- `Think In Directions`
- `2D + 3D`
- `Daily Board`
- `Control Space`
- `Block The Next Move`

## 7) Post-Processing Notes
- Trim aggressively; remove dead frames.
- Validate aspect ratio and output resolution for each required slot.
- Keep transitions simple (hard cut or short dissolve).
- Avoid flashy motion effects; keep tone calm/premium.
- Keep text overlays minimal and readable.

Optional ffmpeg helpers:
```bash
ffmpeg -i input.mov -ss 00:00:01.000 -to 00:00:21.000 -c:v libx264 -crf 18 -preset medium -c:a aac output.mp4
```
```bash
ffmpeg -i output.mp4 -vf "scale=886:1920:force_original_aspect_ratio=decrease,pad=886:1920:(ow-iw)/2:(oh-ih)/2" output-portrait.mp4
```

## 8) App Store Technical Reminders
- Follow App Store Connect App Preview duration/resolution specs per device class.
- Use representative gameplay only (no fake UI states).
- Do not include copyrighted music/audio without rights.
- Keep claims accurate and consistent with live app behavior.

## Production Checklist (Quick)
- [ ] Deterministic scenes selected
- [ ] Portrait framing validated
- [ ] 15–30s timeline locked
- [ ] Overlay text reviewed for brevity
- [ ] Gameplay representation verified
- [ ] Export specs validated for target device classes
