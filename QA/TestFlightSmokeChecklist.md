# Squart TestFlight Smoke Checklist

Date: __________  
Build: __________  
Tester: __________  
Device/OS: __________

Use each section with:
- `Pass:` ☐
- `Notes:` ______________________________________

---

## 1) Launch / Navigation
- [ ] Launch intro appears and transitions smoothly.
- [ ] Root screen renders correctly.
- [ ] Settings opens/closes correctly.
- [ ] Setup opens from Root and returns via Back.
- [ ] Change Setup from in-game returns correctly.

Pass: ☐  
Notes:

---

## 2) Game Setup Combinations
- [ ] PvP
- [ ] PvAI: Human Horizontal + First
- [ ] PvAI: Human Horizontal + Second
- [ ] PvAI: Human Vertical + First
- [ ] PvAI: Human Vertical + Second

Pass: ☐  
Notes:

---

## 3) Board Modes
- [ ] `2D Board` mode works.
- [ ] `3D Board` mode works.
- [ ] Switching modes mid-match keeps state consistent.

Pass: ☐  
Notes:

---

## 4) 2D Board Checks
- [ ] Full board visible at selected sizes.
- [ ] Placed tokens span two cells as one domino.
- [ ] Delayed hints appear after ~5s inactivity.
- [ ] Hints clear after valid move.

Pass: ☐  
Notes:

---

## 5) 3D Board Checks
- [ ] Board fills viewport appropriately.
- [ ] Lighting remains stable over time.
- [ ] No brightness drift.
- [ ] Tile tap hit-testing works.
- [ ] Human move preview works.
- [ ] AI preview works.
- [ ] Placement animation works.
- [ ] `Left 90` / `Right 90` rotation works.
- [ ] Pinch zoom works.
- [ ] Reset Camera works.

Pass: ☐  
Notes:

---

## 6) AI
- [ ] Easy difficulty behavior valid.
- [ ] Medium difficulty behavior valid.
- [ ] Hard difficulty behavior valid.
- [ ] AI opens when human is set to `Second`.
- [ ] Undo works during/after AI flow.

Pass: ☐  
Notes:

---

## 7) Daily Challenge
- [ ] Today’s Board opens.
- [ ] Role/order shown correctly.
- [ ] If human is `Second`, AI opening move triggers.
- [ ] Completion records only on human win.

Pass: ☐  
Notes:

---

## 8) Themes / StoreKit
- [ ] Cappuccino (free) selectable.
- [ ] Premium themes show locked state when not entitled.
- [ ] Locked theme or app icon opens Premium Themes & Icons purchase sheet.
- [ ] App Icons are only in Themes & Icons (not a separate Settings row).
- [ ] StoreKit unavailable case fails gracefully.
- [ ] Restore Purchases action is safe.
- [ ] Unlocked premium themes apply correctly (if entitlement/config available).

Pass: ☐  
Notes:

---

## 9) App Icons
- [ ] Default icon behavior valid.
- [ ] Premium icon lock state valid.
- [ ] Graceful handling if alternate icon switch is unavailable.

Pass: ☐  
Notes:

---

## 10) Accessibility / Device Coverage
- [ ] Reduce Motion behavior acceptable.
- [ ] Small iPhone screen pass.
- [ ] iPad pass.
- [ ] Portrait orientation behavior acceptable.
- [ ] Sheets/modals show text without clipping.

Pass: ☐  
Notes:

---

## 11) Release Build / Submission
- [ ] Archive attempt completed.
- [ ] Build validated in Organizer.
- [ ] TestFlight upload completed.
- [ ] App Store Connect processing notes recorded.

Pass: ☐  
Notes:

---

## Final Sign-off
- Overall Pass: ☐
- Blocking Issues: ______________________________________
- Follow-up Tickets: ____________________________________
