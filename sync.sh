#!/bin/sh

SCRIPT=$(realpath $0)
DIR=$(dirname $SCRIPT)

export HOST=$(hostname)

system_darwin() {
	if ! command -v darwin-rebuild; then
		sudo --preserve-env=HOST \
			nix run \
			--extra-experimental-features nix-command flakes \
			nix-darwin/nix-darwin-24.11 -- switch --flake "." --impure
	else
		sudo --preserve-env=HOST \
			darwin-rebuild switch --flake "." --impure
	fi
}

system_linux() {
	mkdir -p $HOME/.config/home-manager >/dev/null 2>&1
	ln -sf $DIR/flake.nix $HOME/.config/home-manager/flake.nix
	ln -sf $DIR/home.nix $HOME/.config/home-manager/home.nix

	if ! command -v home-manager >/dev/null 2>&1; then
		nix run home-manager/release-24.11 -- switch --impure
	else
		home-manager switch --impure
	fi

	if [ -f /etc/os-release ]; then
		. /etc/os-release

		if [ "$ID" = "nixos" ]; then
			continue
		fi

		sudo $(which nix) \
			run "github:numtide/system-manager/c9e35e9b7d698533a32c7e34dfdb906e1e0b7d0a" -- \
			switch --flake "." --nix-option pure-eval false
	fi
}

if [ "$(uname)" = "Darwin" ]; then
	system_darwin
else
	system_linux
fi
