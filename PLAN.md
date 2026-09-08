# PLAN

## Shipped (v1.0.0, 2026-09-08)

- [x] Status item with two states: grey cup (off), white cup with steam (on)
- [x] Left-click toggles `caffeinate -dims`, tethered to the app's pid
- [x] Right-click menu: Launch at Login, Quit
- [x] Universal binary, macOS 14+
- [x] App icon generated from the same SF Symbol
- [x] Makefile pipeline: build, sign, DMG, notarize, staple, Gatekeeper check
- [x] Docs: START_HERE, README, PLAN, CHANGELOG, LICENSE (MIT)
- [x] Homebrew cask template in `Casks/`

## Before the first public release

- [ ] Create the Developer ID Application certificate (Ivan, in Xcode)
- [ ] Store notary credentials as the `coffee-cup-notary` keychain profile (Ivan)
- [ ] `make release` and confirm `spctl` accepts the DMG
- [x] Create the public GitHub repo `mrivanlizarde/coffee-cup` and push (2026-09-08)
- [ ] Create a GitHub release for v1.0.0 with the DMG attached
- [ ] Create `mrivanlizarde/homebrew-tap`, copy `Casks/coffee-cup.rb` in with
      the real sha256 (printed at the end of `make notarize`)
- [ ] Have one friend on an Intel Mac and one on macOS 14 install it cold

## Deliberately not planned

Timers, schedules, battery-aware behaviour, keyboard shortcuts, preferences
window, Sparkle auto-updates. Each one is a reason the app would stop being
"one click, nothing to configure". Revisit only if Ivan changes the goal.

## Open questions

- Should the release be automated with a GitHub Actions workflow? It would
  need the Developer ID certificate and notary password stored as repository
  secrets. For a one-person project that ships rarely, `make release` on the
  Mac is simpler and keeps the signing key off GitHub. Decision deferred until
  the second release.
