# Horsserie

A curator hangs four unlabeled Yale paintings and plucks the one whose maker stands apart. Isolated files stay on this device. Naming a maker from a plaque is out.

For people who already saved paintings and want to spot the work that does not belong with the others. Not a museum browser and not an artist-or-title chip quiz.

## Architecture

Intrus is a closed algebraic fold with cases Loose, Hung, and Isolated. The hang is a fold over Works.

Hang groups Loose works by maker, samples a school of three that share one maker plus one Loose work whose maker differs, writes four unlabeled Canvases, and folds those four Works to Hung. A crate that cannot form that school writes Idle. Pluck writes a PluckMark when the tapped Canvas is the stray and folds that Work to Isolated. A miss writes a RiftMark, greys that tile, and keeps the hang. Pluck on Loose is refused. Retract peels the last mark.

This pattern fits the product because Isolated-ness is a role on the Work, not a parallel flag, and Quiz is a fold over the crate rather than a second list of records. One HangStore pattern-matches the fold. Views call hangSchool, pluckCanvas, riftCanvas, and retractLastMark.

## Hang then pluck

Quiz holds four unlabeled paintings. Hang draws three Loose works that share a maker and one that does not. Tapping the odd maker writes a PluckMark and files that painting Isolated. Tapping a school mate writes a RiftMark and leaves the four up. Explore, Saved, and Settings arrive as sheets over the locked hang.

Pick this app when the job is to tap the painting that does not belong, not to name a maker.

## Design

Warm hospitable Soft card daylight. SF Pro. Tokens only through HangTone, HangType, HangPad, HangRadius, and HangLift. Art style: 3D glass render glassmorphism.

Base prompt reused for every asset:

```
3D glass render, glassmorphism, studio-lit four-canvas accrochage, one stray tile pulling from a school of three, frosted hang refraction and soft bloom, isolated subjects, quiet uncluttered ground, no text, no letters, no logo, no photoreal stock, no specified colours, four unlabeled paintings not a name-chip row, not a circular excerpt, and not a museum grid
```

Exact prompts live in SPEC.md section 13.2. Imagesets are named `hrs_AppIcon`, `hrs_Splash`, `hrs_Onboarding1`, `hrs_Onboarding2`, `hrs_Onboarding3`, `hrs_EmptyHome`, `hrs_EmptyList`, `hrs_CardBackdrop`, `hrs_ControlFace`, `hrs_TwistHero`, `hrs_SuccessMark`, `hrs_HeaderDecor`, `hrs_SchoolRail`, `hrs_IntrusTile`, and `hrs_CrateShelf`.

## How this differs

Home shows four full unlabeled paintings. The job is to tap the one whose maker breaks a school of three. Artist and title never sit on Quiz. Isolated is written only when the stray maker is tapped. Explore, Saved, and Settings stay sheets, so this is not a three-tab crate browser.

## Build

```
cd apps/Horsserie
xcodegen generate
xcodebuild build-for-testing -scheme Horsserie -destination 'generic/platform=iOS Simulator'
```

No packages. Foundation, SwiftUI, and URLSession only. Paintings come from the Yale University Art Gallery via LUX.
