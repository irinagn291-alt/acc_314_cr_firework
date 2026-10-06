<!-- gf-brief source=53d90e1507b2d647362dd913a3d2a70ab67f3d14dda36ac311a4bbb74a4c2007 written=2026-10-06T20:37:05+03:00 -->
# CR Firework
## What it is
CR Firework is a painting hang for people who want to spot the one work that does not belong. You save Yale University Art Gallery paintings on this device, hang four unlabeled tiles (three by one maker, one stray), and tap the stray. A true tap files that painting as isolated; a miss greys that tile and the hang stays.

## Launch and onboarding
Cold launch shows a full-screen splash illustration with no words, then either onboarding or the hang.

On a first launch that has not finished onboarding, a three-page cover appears. A page indicator is present (VoiceOver: "Page 1 of 3", "Page 2 of 3", "Page 3 of 3"). The bottom button is always "Continue".

1. Headline "Save a school." Line "Keep Yale paintings on this device. Home is the hang, not a museum walk." Top-trailing "Skip" (VoiceOver: "Skip onboarding"). "Continue" goes to page 2. "Skip" ends onboarding and opens the hang.
2. Headline "Hang four." Line "Three share a maker. One does not. The tiles stay unlabeled." "Skip" and "Continue" work the same way.
3. Headline "Pluck the stray." Line "A true tap saves that painting. A miss greys that tile and stays." There is no "Skip". "Continue" ends onboarding and opens the hang.

After onboarding, the hang is home. Onboarding does not run again unless you choose "Re-run onboarding" on Settings.

Siri and Shortcuts can also open the app with "Open Quiz", "Open Explore", "Open Saved", "Open Settings", "Hang a school", "Pluck the stray", and "Open hang then pluck". Shortcut short titles are "Quiz", "Explore", "Saved", "Settings", "Hang", and "Pluck".

## Screens
There is no tab bar. Home is the hang. Explore, Saved, and Settings cover it. A fourth cover, "Pluck one stray", is not on the hang bar; Shortcuts "Open hang then pluck" opens it.

### Hang (home)
Header wordmark "CR Firework". Job "Pluck the stray". Next line "Tap the painting that does not belong."

Icon buttons (VoiceOver labels): "Explore" opens Explore; "Saved" opens Saved; "Settings" opens Settings.

When four paintings are hung, they sit in an unlabeled 2-by-2 grid (top pair taller). VoiceOver on the grid: "Four unlabeled paintings". Each tile is "Unlabeled painting" (hint: "Pluck if this maker stands apart.") or, after a miss, "Greyed school mate" (hint: "Already rifted."). Tiles show the picture only: no title and no maker. Tap the stray: a haptic, the hang clears, status becomes "Saved" / "The stray is saved. Hang the next school.", and that painting moves to Isolated. Tap a school mate: that tile greys and gets a strike, status becomes "Miss" / "That tile missed. The hang stays.", and the four stay up. A greyed tile does nothing.

Status words you can see:
- "Ready" with "Hang four, then tap the one that does not belong." before a hang, or "Ready" with "Tap the painting that does not belong." while a clean hang is up.
- "Miss" with "That tile missed. The hang stays."
- "Saved" with "The stray is saved. Hang the next school."
- "Need more" with "Save a school, then hang four." on the idle page.

"Hang four paintings" appears only when the crate can form a school (at least three paintings by one maker and at least one by another) and no hang is currently up. It writes a new unlabeled four. "Retract last pick" appears on this screen when a pick or miss exists and the hang is not currently up; it peels the last correct pick or the last miss.

Below the hang: an Isolated rail. Empty copy: "Isolated paintings" and "Correct picks sit here." After a correct pick, the rail shows "Isolated paintings", the work title, and the maker. Tapping it opens Saved (VoiceOver: "Saved [title], [maker]"; hint: "Open isolated paintings").

Counts: "Correct picks" and "Misses".

Idle (not enough paintings for a school): illustration, "Need more paintings.", "Save a school, then hang four.", bottom "Explore". If the hang could not be read: "The hang could not be read.", "The hang could not be read. A quiet start is up.", "Explore".

Hang error: "Hang failed.", then "Write failed. Hang or pluck again." or "Hang needs a vacant crate." or "Nothing to retract." or "Pluck needs a hung school.", bottom "Hang".

After a correct pick the hang plate can briefly show a success illustration (VoiceOver: "Stray saved"). An empty hang plate is "Hang is vacant".

### Explore
Title "Explore". Close control (VoiceOver: "Close") returns to the hang.

Line "Search the Yale collection and save a painting to your hang." Field placeholder "Search a work". Keyboard "Done" dismisses the keyboard. A spinner can appear while a search runs.

Each row shows a picture, title, maker, and "Save" (or "Saving" while that row is writing). VoiceOver: "Save [title]". A new save shows "Saved to your hang." Saving a work already in the crate shows "Already in the crate." and "Focused" on that row; it does not add a second copy. Rows are disabled while any save is in flight.

Empty search (or first open) lists the local Yale shelf so you can still save. If Yale cannot be reached but local rows remain: "Yale could not be reached. The local shelf is here." plus "Retry" (VoiceOver: "Retry search"). If Yale has no match but local rows remain: "Yale had no match. The local shelf is here."

No rows and a failed search: "Search failed.", the same Yale fault line, "Retry". No rows and no fault: "The shelf is quiet.", "Search the Yale collection and save a painting to your hang.", "Clear search".

### Saved
Title "Isolated paintings and misses". "Close" and bottom "Back to the hang" return to the hang.

Plate: "Isolated paintings and misses" and "Tap a saved work or Back to the hang."

Counts: "Correct picks" and "Misses".

Section "Isolated paintings". Empty: "None plucked yet. Pluck the stray on the hang." Populated rows show picture, title, maker; the first also shows a date like "2026.10.06". Tapping any isolated row returns to the hang.

Section "Missed". Empty: "No misses yet." Each miss shows the picture, title (or the work id if the title is missing), and "Missed. This one is by the same painter as the others." plus an x mark. Tapping a miss returns to the hang.

### Settings
Title "Yale credit and Retract". "Close" returns to the hang.

Plate: "Yale credit and Retract" and "Tap Contact or Retract last pick."

"Contact" opens the Horsserie contact page (VoiceOver hint: "Opens the Horsserie contact page.").

Credit: "Paintings come from the Yale University Art Gallery." "Tap a source to open the gallery or Yale LUX." Rows: "Yale University Art Gallery" / "artgallery.yale.edu" and "Yale LUX" / "lux.collections.yale.edu". Each opens that source.

Counts: "Paintings in the hang", "Isolated paintings", "Correct picks", "Misses".

"Re-run onboarding" returns to the three onboarding pages (hang, isolated paintings, and misses stay).

"Reset all data" (hint: "Removes every painting and mark on this device.") opens "Reset all data?" with "This removes paintings, picks, and misses on this device.", destructive "Reset all data", and "Cancel". Confirming clears paintings, picks, and misses and returns to the hang.

Bottom "Retract last pick" (hint: "Peels the last pluck or rift.") is enabled only when a correct pick or a miss exists.

### Pluck one stray
Title "Pluck one stray". "Close" returns to the hang. This cover is not on the hang bar.

Plate: "Pluck one stray", "Each hang hides one painting that does not belong. The number is how many strays you mean to pluck.", "1", "Stray in this hang".

Counts: "Strays plucked" and "Paintings waiting". The same hang status words as home, plus "Tap the painting that does not belong."

Bottom button: "Pluck the stray" if a hang is up (closes to the hang); "Hang four paintings" if a school can be formed (hangs four and closes to the hang); "Save a painting" otherwise (opens Explore).

## Features
- Pluck the stray: tap the unlabeled painting that does not belong.
- Hang four paintings: three share a maker, one does not; tiles stay unlabeled.
- Miss: greys that tile, records a miss, hang stays.
- Isolated paintings: a correct pick files that work here and takes it out of the next hang.
- Retract last pick: peels the last correct pick or the last miss.
- Explore: search the Yale collection and save a painting to your hang.
- Local Yale shelf when search is empty or Yale cannot be reached.
- Saved: isolated paintings and misses, with Correct picks and Misses counts.
- Yale credit and Retract, including Contact and the two Yale source rows.
- Re-run onboarding.
- Reset all data (confirmed).
- Pluck one stray: one stray per hang, with Strays plucked and Paintings waiting.
- Shortcuts: Open Quiz, Open Explore, Open Saved, Open Settings, Hang a school, Pluck the stray.

## Behaviours that can look like bugs
- "Need more paintings." / "Save a school, then hang four." until you have saved at least three works by one maker and one by another. Open "Explore", "Save" enough paintings, return, then "Hang four paintings".
- "Hang four paintings" is hidden while four tiles are already up, and while the crate cannot form a school. Finish or retract the current hang, or save more paintings.
- "Retract last pick" is hidden on the hang while a hang is up; use it on Settings, or after the hang is vacant. It is disabled when there are no picks and no misses.
- A miss greys a tile and stays on purpose. Status "Miss" / "That tile missed. The hang stays." Tap a different tile. The greyed tile will not accept another tap.
- After a correct pick the four disappear on purpose. Status "Saved" / "The stray is saved. Hang the next school." Use "Hang four paintings" for the next school.
- Isolated paintings do not come back in later hangs unless you "Retract last pick" on that correct pick.
- Retract on a miss ungreys that tile and leaves the four up. Retract on a correct pick returns that painting to the crate and does not put the old four back.
- "Already in the crate." and "Focused" mean that accession is already saved. Nothing new is added.
- "Save" rows do nothing while any row shows "Saving".
- "Yale could not be reached. The local shelf is here." and "Yale had no match. The local shelf is here." still show the local shelf. "Retry" or "Clear search" continues.
- "The shelf is quiet." / "Clear search" after a search that leaves no rows. Clear the field to see the local shelf again.
- "Hang failed." with "Hang needs a vacant crate." if you try to hang while four are already up. Pluck or retract first.
- "Pluck needs a hung school." if a pluck is asked for while no hang is up. Hang four first.
- "Nothing to retract." if retract is asked for with no marks.
- "The hang could not be read." / "The hang could not be read. A quiet start is up." after a failed read. "Explore" continues with a quiet start.
- "Reset all data?" must be confirmed with "Reset all data"; "Cancel" leaves data in place.
- "Re-run onboarding" shows the three pages again on purpose. "Skip" or "Continue" on the last page returns to the hang.
- Saved rows all close back to the hang; there is no painting detail page.
- Missing pictures render as a blank plate, not a caption.
- Appearance is light only. Rotation is portrait only.

## Starter content and resume
The local Yale shelf (shown in Explore when the search field is empty) is:

- "Port-Domois, Belle-Isle" — Claude Monet
- "The Artist's Garden in Giverny" — Claude Monet
- "Boulevard Heloise, Argenteuil" — Claude Monet
- "Camille on the Beach in Trouville" — Claude Monet
- "Four Jockeys" — Edgar Degas
- "Old Mill" — Winslow Homer
- "The Night Cafe" — Vincent van Gogh

On Simulator only, a first run can already mark onboarding complete, hang a live school, file isolated paintings (including "Four Jockeys"), and record at least one miss so Saved is not empty. That seed does not run on a physical device. A device first run after onboarding is the idle hang until you save a school.

Paintings, the current hang (including greyed miss tiles), isolated paintings, correct picks, misses, and the onboarding-complete flag persist across launches. An unfinished hang resumes as it was. A cover (Explore, Saved, Settings, Pluck one stray) does not resume; relaunch returns to the hang. A search query does not persist. After a correct pick the hang is vacant until you hang again.

## Permissions
None. The app never asks for camera, photos, microphone, location, or tracking.

## Absent
Absent: login or accounts, in-app purchase, ads, analytics, user-generated content, account deletion flow, App Tracking Transparency prompt.

## Data and support
Paintings, picks, and misses stay on this device. "Reset all data" says it "removes paintings, picks, and misses on this device." Search talks to the Yale collection and falls back to the local shelf. "Contact" on Settings opens the Horsserie contact page. The two Yale rows open the gallery and Yale LUX.

## Scanning and health
None. The app does not scan barcodes or QR codes. It does not show health, medical, or product-health information.

## Platform
No region lock. Copy is English only. Counts follow the device number format. Isolated dates show as year.month.day (for example "2026.10.06"). Light appearance only. Portrait only on iPhone and iPad, full screen. iPhone and iPad. Minimum iOS 17.0.

## Category
Education
