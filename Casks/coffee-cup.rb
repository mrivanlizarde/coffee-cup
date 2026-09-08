# Homebrew cask for Coffee Cup.
# Lives in the tap repo mrivanlizarde/homebrew-tap as Casks/coffee-cup.rb.
# Update `version` and `sha256` for each release; `make notarize` prints the sha.
cask "coffee-cup" do
  version "1.0.0"
  sha256 "REPLACE_WITH_SHA256_FROM_make_notarize"

  url "https://github.com/mrivanlizarde/coffee-cup/releases/download/v#{version}/CoffeeCup-#{version}.dmg"
  name "Coffee Cup"
  desc "One-click menu bar toggle for caffeinate -dims"
  homepage "https://github.com/mrivanlizarde/coffee-cup"

  depends_on macos: ">= :sonoma"

  app "Coffee Cup.app"

  zap trash: [
    "~/Library/Preferences/com.ivanlizarde.CoffeeCup.plist",
  ]
end
