# START HERE

Read this first. Then read only the files the task touches.

## What this is

Coffee Cup is a macOS menu bar app with exactly one job: toggle
`caffeinate -dims` on and off with a click. One Swift file, no dependencies,
no sandbox, no App Store. It is shared with friends as a signed, notarized DMG
and published on GitHub under MIT.

The whole app is `Sources/CoffeeCup/CoffeeCupApp.swift`. The build is
`Makefile`. Everything else is packaging.

## How to run it

```bash
cd ~/Code/coffee-cup
make dev
```

That builds a universal binary, wraps it in `build/Coffee Cup.app`, signs it
ad-hoc (valid on this Mac only), and opens it. A grey cup appears in the menu
bar.

## How to verify it (reading the code is not verification)

1. **Look at the menu bar.** Grey cup and saucer, dimmed. Left-click it. It
   becomes a white cup with steam at full brightness.
2. **Confirm the process.** In Terminal:
   ```bash
   pgrep -fl "caffeinate -dims -w"
   ```
   You should see one line ending in the app's pid. Click again; it should
   print nothing.
3. **Confirm the assertion is real.** `pmset -g assertions | grep caffeinate`
   should show `PreventUserIdleSystemSleep` and `PreventUserIdleDisplaySleep`
   "on behalf of Process ID <app pid>" while on, and nothing while off.
4. **Right-click the cup.** A two-item menu: Launch at Login, Quit. Right-click
   must *not* toggle the state. After the menu closes, a left-click must still
   toggle. (Both were bugs waiting to happen; see "Load-bearing" below.)
5. **Orphan test.** Turn it on, then `kill -9` the app. Within a second,
   `pgrep -fl caffeinate` must show nothing from Coffee Cup.

Every one of these was run and passed on 2026-09-08 before the first commit.

## Release pipeline

```bash
cd ~/Code/coffee-cup
make release
```

Produces `dist/CoffeeCup-<version>.dmg`, signed with Developer ID, notarized,
stapled, and checked by Gatekeeper (`spctl`). Then create a GitHub release and
attach the DMG. Bump `VERSION` in the Makefile first.

### One-time setup before the first release

Both of these need Ivan's Apple ID and cannot be scripted.

1. **Developer ID Application certificate.** Xcode → Settings → Accounts →
   select the team (K55TBYNKUC) → Manage Certificates → **+** →
   Developer ID Application. Check with:
   ```bash
   security find-identity -v -p codesigning | grep "Developer ID Application"
   ```
2. **Notary credentials in the keychain.** Generate an app-specific password at
   appleid.apple.com, then:
   ```bash
   xcrun notarytool store-credentials coffee-cup-notary --apple-id ivan@dvlpmnt.studio --team-id K55TBYNKUC
   ```
   It prompts for the app-specific password and stores it in the login
   keychain under the profile name the Makefile expects.

## Rules of engagement

- **One action, two menu items.** Feature requests for timers, schedules,
  battery thresholds, and hotkeys are declined by design. The README points
  people to Amphetamine and KeepingYouAwake for those. Coffee Cup's value is
  that there is nothing to configure.
- **Update the docs in the same commit as the change.** CHANGELOG entry per
  session, newest first, with the *why*.
- **Never `git add -A` here without reading `git status` first.** `build/` and
  `dist/` are ignored, but a DMG dragged in from Finder would not be.

## Load-bearing decisions, with reasons

- **`caffeinate` is launched with `-w <app pid>`.** The command Ivan types is
  `caffeinate -dims`; the app adds `-w` pointing at itself. This ties the
  assertion to the app's lifetime, so a force-quit or crash cannot leave a
  ghost `caffeinate` keeping the Mac awake with no icon to show it. Removing
  `-w` reintroduces that failure. `applicationWillTerminate` also calls
  `terminate()` for the clean-quit path.
- **The menu is attached only for the duration of a right-click.** If
  `statusItem.menu` is set permanently, AppKit shows the menu on *every* click
  and the left-click toggle never fires. `showMenu()` attaches it, calls
  `performClick`, and `menuDidClose` detaches it. Do not "simplify" this into
  a permanent menu.
- **The termination handler checks identity (`caffeinate === finished`).**
  Fast double-clicks can stop an old process and start a new one before the
  old one's handler runs. Without the identity check the handler nils out the
  *new* process reference and the icon says off while caffeinate is running.
- **Icons are SF Symbols rendered as template images, "off" uses
  `appearsDisabled`.** Template images take the menu bar's foreground colour,
  so the same code is white on a dark menu bar and black on a light one.
  Hard-coding grey and white would be invisible against a light menu bar.
- **Starts off, always.** Remembering "on" across launches is how a laptop
  drains overnight after a reboot the user did not notice.
- **Minimum macOS 14.** `cup.and.heat.waves.fill` arrived in SF Symbols 5
  (macOS 14). Dropping the minimum below 14 makes the "on" icon vanish.
- **Development machine runs a macOS 27 beta.** Notarization of builds made
  on beta OSes occasionally fails on Apple's side; if `make notarize` fails
  with no useful log, that is the first suspect.
- **Build system is SwiftPM plus a Makefile, not an Xcode project.** The
  bundle is assembled by hand so the whole pipeline is readable in one file
  and reproducible by anyone with Xcode's command line tools. `SMAppService`
  (Launch at Login) requires a real `.app` bundle, so `swift run` will not
  exercise that feature; use `make dev`.
- **`hdiutil create` prints a deprecation warning on macOS 27.** It still
  works. Apple's replacement is `diskutil image create`; switch when the
  minimum *build* machine is macOS 26+, and test the DMG mounts on macOS 14.
