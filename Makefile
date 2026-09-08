# Coffee Cup build pipeline.
#
#   make dev        build, ad-hoc sign, and open the app (local testing)
#   make app        build a universal, unsigned .app in build/
#   make release    app + Developer ID sign + DMG + notarize + staple → dist/
#
# Release needs two one-time setups on this Mac (see START_HERE.md):
#   1. A "Developer ID Application" certificate in the login keychain.
#   2. Notary credentials stored as a keychain profile:
#        xcrun notarytool store-credentials "$(NOTARY_PROFILE)"

APP_NAME       := Coffee Cup
EXEC           := CoffeeCup
VERSION        := 1.0.0
BUILD_NUMBER   := $(shell git rev-list --count HEAD 2>/dev/null || echo 1)
SIGN_IDENTITY  ?= Developer ID Application
NOTARY_PROFILE ?= coffee-cup-notary

BUILD_DIR := build
DIST_DIR  := dist
APP       := $(BUILD_DIR)/$(APP_NAME).app
CONTENTS  := $(APP)/Contents
BINARY    := .build/apple/Products/Release/$(EXEC)
DMG       := $(DIST_DIR)/CoffeeCup-$(VERSION).dmg
ICONSET   := $(BUILD_DIR)/AppIcon.iconset
ICNS      := $(BUILD_DIR)/AppIcon.icns

.PHONY: all dev app run binary icon sign dmg notarize release clean verify

all: app

binary:
	swift build -c release --arch arm64 --arch x86_64

$(ICNS):
	swift scripts/make-icon.swift "$(ICONSET)"
	iconutil -c icns "$(ICONSET)" -o "$(ICNS)"

icon: $(ICNS)

app: binary $(ICNS)
	rm -rf "$(APP)"
	mkdir -p "$(CONTENTS)/MacOS" "$(CONTENTS)/Resources"
	cp "$(BINARY)" "$(CONTENTS)/MacOS/$(EXEC)"
	cp "$(ICNS)" "$(CONTENTS)/Resources/AppIcon.icns"
	sed -e 's/__VERSION__/$(VERSION)/' -e 's/__BUILD__/$(BUILD_NUMBER)/' \
	    Resources/Info.plist > "$(CONTENTS)/Info.plist"
	printf 'APPL????' > "$(CONTENTS)/PkgInfo"
	@echo "Built $(APP)"

# Local testing: ad-hoc signature is enough to run on this Mac.
dev: app
	codesign --force --deep --sign - "$(APP)"
	open "$(APP)"

run: dev

sign: app
	codesign --force --options runtime --timestamp \
	    --entitlements Resources/CoffeeCup.entitlements \
	    --sign "$(SIGN_IDENTITY)" "$(APP)"
	codesign --verify --deep --strict --verbose=2 "$(APP)"

dmg: sign
	mkdir -p "$(DIST_DIR)" "$(BUILD_DIR)/dmg"
	rm -rf "$(BUILD_DIR)/dmg"/* "$(DMG)"
	cp -R "$(APP)" "$(BUILD_DIR)/dmg/"
	ln -s /Applications "$(BUILD_DIR)/dmg/Applications"
	hdiutil create -volname "$(APP_NAME)" -srcfolder "$(BUILD_DIR)/dmg" \
	    -ov -format UDZO "$(DMG)"
	codesign --force --timestamp --sign "$(SIGN_IDENTITY)" "$(DMG)"
	@echo "Built $(DMG)"

notarize: dmg
	xcrun notarytool submit "$(DMG)" --keychain-profile "$(NOTARY_PROFILE)" --wait
	xcrun stapler staple "$(DMG)"
	@echo
	@echo "sha256 for the Homebrew cask:"
	@shasum -a 256 "$(DMG)"

release: notarize verify

# Gatekeeper's own opinion of the finished DMG. This is the check that matters.
verify:
	spctl --assess --type open --context context:primary-signature -v "$(DMG)"
	xcrun stapler validate "$(DMG)"

clean:
	rm -rf "$(BUILD_DIR)" "$(DIST_DIR)" .build
