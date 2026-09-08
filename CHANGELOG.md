# CHANGELOG

Newest first. One entry per working session. The *why* is the point.

## 2026-09-08 — published to GitHub

Repo created public at https://github.com/mrivanlizarde/coffee-cup and pushed.

Ivan raised a concern that an app this simple would fail Apple's review. It would
not, because it never meets a reviewer: the Mac App Store's "Minimum Functionality"
rule (guideline 4.2) applies only to App Store submissions, and Coffee Cup ships as
a notarized DMG outside the store. Notarization is an automated malware scan with no
human judgment about whether an app is substantial enough to exist.

Recorded here because the question will come back if the project is ever revisited:
if Coffee Cup ever *did* target the App Store, the blocker would not be simplicity.
Amphetamine does this same job and has been on the store for years. The blocker would
be the sandbox, which forbids spawning `/usr/bin/caffeinate` at all. It would require
rewriting to call `IOPMAssertionCreateWithName` directly. Not worth doing for an app
handed to friends.

## 2026-09-08 — v1.0.0, first build

Ivan asked for a menu bar toggle for `caffeinate -dims`, shareable with friends
and public on GitHub. Before coding, four blind spots were raised and settled:

- **Distribution.** Only an Apple Development certificate existed on the Mac.
  Ivan confirmed he is in the paid Developer Program, so the pipeline targets a
  Developer ID signed, notarized DMG rather than a "right-click to open" README
  workaround. The certificate and notary credentials still need creating by
  hand (see START_HERE).
- **Quitting.** A single-click toggle leaves no room for a menu, so right-click
  opens a two-item menu (Launch at Login, Quit). Nothing else, by decision.
- **Icon.** System SF Symbols rather than a custom drawing, because template
  rendering handles light and dark menu bars for free.
- **Name.** Coffee Cup.

Built with SwiftPM plus a Makefile instead of an Xcode project so the entire
build is one readable file. `caffeinate` is launched with `-w <app pid>` so a
crash or force-quit can never leave a ghost process keeping the Mac awake.
Verified live: toggle on, toggle off, right-click menu, force-kill orphan test,
and `pmset -g assertions` showing the assertion on behalf of the app.

Found while testing: a manual `caffeinate -dims` from Ivan's own Terminal had
been running since 10:00 that morning. That is the problem this app replaces.
