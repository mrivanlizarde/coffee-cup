# Homebrew cask for Coffee Cup.
# Lives in the tap repo mrivanlizarde/homebrew-tap as Casks/coffee-cup.rb.
# Update `version` and `sha256` for each release; `make notarize` prints the sha.
cask "coffee-cup" do
  version "1.0.0"
  sha256 "06e0430cdfc426f9908736404b76560680e75512f23cf8da0d3c4b1dd5393bbd"

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
