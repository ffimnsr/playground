init-tools:
	rustup target add wasm32-unknown-unknown
	cargo install trunk wasm-bindgen-cli

init-tailwind-darwin-arm64:
	curl -sSL --create-dirs -o ~/.local/bin/tailwindcss https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.13/tailwindcss-macos-arm64

serve:
	trunk serve

build.release:
	trunk build --release

.PHONY: init-tools \
	init-tailwind-darwin-arm64 \
	serve \
	build.release