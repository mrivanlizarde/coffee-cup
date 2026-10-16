# Coffee Cup

A one-click menu bar switch that keeps your Mac awake.

Grey cup: your Mac sleeps normally. White cup with steam: it stays awake.
Click to switch. That is the whole app.

Under the hood it runs the same `caffeinate -dims` command you would type in
Terminal, and stops it when you click again or quit.

## Install

Coffee Cup isn't notarized by Apple, so there's no download yet. You build it
yourself in about a minute. You need macOS 14 or later and Apple's command line
tools (run `xcode-select --install` once if you've never built anything).

```bash
git clone https://github.com/mrivanlizarde/coffee-cup.git
cd coffee-cup
make install
```

That builds it, signs it for your own Mac, copies it into **Applications**, and
opens it. A grey cup appears at the right side of your menu bar.

## Use

| Action | Result |
|---|---|
| Left-click the cup | Toggle awake on or off |
| Right-click (or Control-click) | Menu: **Launch at Login**, **Quit** |
| Hover | Tooltip tells you the current state |

Coffee Cup always starts **off**. It never remembers an "on" state across a
restart, so a forgotten switch cannot drain a laptop overnight.

## What it does not do

These are limits of macOS and the `caffeinate` command itself, not bugs.

- **Closing the lid still puts a laptop to sleep.** No app can prevent that
  without a kernel extension. Keep the lid open.
- **On battery, the Mac may still sleep when idle.** The `-s` flag only holds
  the system awake while on AC power. Display and disk are still kept awake.
- **No timer, no schedule, no battery threshold.** If you want those,
  [Amphetamine](https://apps.apple.com/app/amphetamine/id937984704) or
  [KeepingYouAwake](https://github.com/newmarcel/KeepingYouAwake) have them.
  Coffee Cup exists to have none of them.

## Requirements

macOS 14 Sonoma or later. Universal binary for Apple Silicon and Intel.

## Tip jar

Coffee Cup is free and stays free. If it kept your Mac awake through something
that mattered, you can buy me a coffee: [buymeacoffee.com/mrivanlizarde](https://buymeacoffee.com/mrivanlizarde).

## License

MIT. See [LICENSE](LICENSE).
