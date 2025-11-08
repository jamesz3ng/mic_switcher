.PHONY: build install clean run app

APP_NAME = MicSwitcher
BUNDLE_NAME = $(APP_NAME).app
BUILD_DIR = .build/release
APP_DIR = $(BUILD_DIR)/$(BUNDLE_NAME)

build:
	@echo "Building MicSwitcher..."
	swift build -c release
	@echo "✓ Build complete: $(BUILD_DIR)/mic-switcher"

app: build
	@echo "Creating app bundle..."
	mkdir -p "$(APP_DIR)/Contents/MacOS"
	mkdir -p "$(APP_DIR)/Contents/Resources"
	cp "$(BUILD_DIR)/mic-switcher" "$(APP_DIR)/Contents/MacOS/MicSwitcher"
	cp "Sources/MicSwitcher/Info.plist" "$(APP_DIR)/Contents/Info.plist"
	@echo "✓ App bundle created: $(APP_DIR)"

install: app
	@echo "Installing to /Applications/$(BUNDLE_NAME)..."
	rm -rf "/Applications/$(BUNDLE_NAME)"
	cp -R "$(APP_DIR)" "/Applications/"
	@echo "✓ Installed to /Applications/$(BUNDLE_NAME)"
	@echo ""
	@echo "To run: open /Applications/$(BUNDLE_NAME)"
	@echo "Or: open -a MicSwitcher"

clean:
	@echo "Cleaning build artifacts..."
	rm -rf .build
	@echo "✓ Clean complete"

run: app
	@echo "Running MicSwitcher..."
	open "$(APP_DIR)"

uninstall:
	@echo "Uninstalling MicSwitcher..."
	rm -rf "/Applications/$(BUNDLE_NAME)"
	launchctl unload ~/Library/LaunchAgents/com.user.micswitcher.plist 2>/dev/null || true
	rm -f ~/Library/LaunchAgents/com.user.micswitcher.plist
	@echo "✓ Uninstalled"
