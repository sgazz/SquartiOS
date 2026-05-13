# Squart Release Candidate Checklist

Date: __________  
Build: __________  
Owner: __________

## 1) Build Verification
- [ ] Debug build passes
- [ ] Release build passes (`iphoneos`)
- [ ] No release-blocking warnings
- [ ] Scheme/settings validated for current target

## 2) Test Verification
- [ ] Core/unit tests pass
- [ ] Regression tests pass for role/turn-order flows
- [ ] Daily Challenge determinism tests pass
- [ ] Persistence tests pass (setup/theme/settings)

## 3) StoreKit Readiness
- [ ] Product ID confirmed: `squart.supporter`
- [ ] Local StoreKit config usable for validation
- [ ] Purchase path safe when product unavailable
- [ ] Restore purchases path verified

## 4) App Icon Readiness
- [ ] Primary icon final assets present
- [ ] Alternate icon assets present (Obsidian/Ivory/Forest/BronzeNight)
- [ ] Alternate icon identifiers match Info.plist declarations
- [ ] Premium icon lock behavior verified

## 5) App Store Listing Assets
- [ ] App Store metadata draft reviewed
- [ ] Keywords/subtitle/name choices finalized
- [ ] Screenshot set captured and reviewed
- [ ] App Preview plan approved (if video included)

## 6) Upload Preparation
- [ ] Archive produced in Xcode Organizer
- [ ] Build uploaded to App Store Connect
- [ ] Build processing completes successfully

## 7) Physical Device Smoke Reminder
- [ ] Short smoke pass on real iPhone
- [ ] Touch/haptics sanity check
- [ ] AI turn flow sanity check
- [ ] Daily Challenge open/complete sanity check
- [ ] StoreKit purchase/restore sanity check

## Sign-off
- [ ] RC accepted for TestFlight distribution
- [ ] Blocking issues: ____________________________
- [ ] Follow-up tickets: __________________________
