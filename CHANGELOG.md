# CHANGELOG

Newest first. One entry per working session. The *why* is the point.

## 2026-11-03 (later) — First real release: v1.0.0, signed, notarized, downloadable

**Why.** Jacob Patrick asked for the no-sleep trick for footage transfers, and Ivan wanted
him to install Coffee Cup like any normal app. That needs Apple's notarization, which this
project had skipped on 2026-10-15 because nobody had asked for a download.

**What happened.** Xcode refused to create the Developer ID certificate ("only the Account
Holder", to the Account Holder). Ivan made it on the web from a CSR Sonny generated; the key
and certificate were imported into the login keychain and the key file deleted. The
app-specific password path to notarytool failed twice with 401 on a correct password; an App
Store Connect API key validated first time, so START_HERE now prescribes the key. The first
DMG passed notarization but the app inside it had no stapled ticket, so `make release` gained
a `notarize-app` stage (zip, notarize, staple the .app) before the DMG is built; the DMG was
re-cut and re-notarized and the release asset replaced within minutes of the first upload.

**Verified.** Apple: Accepted, twice (app zip and DMG). Stapler validates both the DMG and the
app inside the mounted image. `spctl` on the mounted app: "accepted, source=Notarized Developer
ID". The GitHub asset downloaded back and matched the sha256 of the file Apple accepted:
`06e0430c…93bbd`. README now leads with the download; the cask carries the sha.

**Not done.** The Homebrew tap repo (`mrivanlizarde/homebrew-tap`) does not exist, so
`brew install` is still not a thing; the cask file is ready for it.

## 2026-11-03 — Release prerequisites checked; team id corrected

**Why.** Jacob Patrick asked Ivan for "that code thing you use so the computer doesn't sleep
while it's transferring footage." Ivan wants to send him Coffee Cup as a normal download, no
Xcode on Jacob's side. That is exactly the notarized DMG `make release` was built to produce.

**What.** Rebuilt `make app` on Xcode 27.2 / macOS 27.2: compiles, universal (arm64 + x86_64),
ad-hoc signature valid. Confirmed what is missing: a Developer ID Application certificate
(only an Apple Development one is in the keychain) and the `coffee-cup-notary` keychain
profile. Confirmed the account can issue one: Xcode lists team `LD587PB2H8` "Ivan Lizarde"
as a paid Individual membership. `START_HERE.md` had the team as `K55TBYNKUC` (the user id
printed in the certificate name) and the Apple ID as the work address; both corrected so the
notarytool line works first time.

**Not done.** The two one-time steps still need Ivan's Apple ID and his hands. No release yet.

## 2026-10-15: honest install, and a tip jar

The README promised a notarized DMG, a GitHub release and a Homebrew tap. None of them
existed, so anyone who found the repo hit a dead link on step one. Ivan chose honesty
over notarizing: the install section now says to build from source, through a new
`make install` that ad-hoc signs and copies the app into /Applications. It has to live
there because Launch at Login records the app's path, which is the bug the M5 move
exposed. The release pipeline stays in the Makefile for the day it is notarized.

Added a tip jar (buymeacoffee.com/mrivanlizarde) to the README and `.github/FUNDING.yml`.
Coffee Cup stays free under MIT. Free alternatives already cover this ground
(Amphetamine, KeepingYouAwake), so a price was never realistic; a tip is.

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
