.PHONY: build install clean run

build:
	@echo "Building MicSwitcher..."
	swift build -c release
	@echo "✓ Build complete: .build/release/mic-switcher"

install: build
	@echo "Installing to ~/bin/mic-switcher..."
	mkdir -p ~/bin
	cp .build/release/mic-switcher ~/bin/
	chmod +x ~/bin/mic-switcher
	@echo "✓ Installed to ~/bin/mic-switcher"

clean:
	@echo "Cleaning build artifacts..."
	rm -rf .build
	@echo "✓ Clean complete"

run: build
	@echo "Running MicSwitcher..."
	.build/release/mic-switcher
