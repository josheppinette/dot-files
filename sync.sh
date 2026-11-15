#!/bin/sh

SCRIPT=$(realpath $0)
DIR=$(dirname $SCRIPT)

export HOST=$(hostname)

NIX=$(command -v nix)

system_darwin() {
	if ! command -v darwin-rebuild; then
		sudo --preserve-env=HOST,HOME \
			nix run \
			nix-darwin/nix-darwin-25.11 -- switch --flake "$DIR" --impure
	else
		sudo --preserve-env=HOST,HOME \
			darwin-rebuild switch --flake "$DIR" --impure
	fi
}

system_linux() {
	if ! command -v home-manager >/dev/null 2>&1; then
		nix run home-manager/release-25.11 -- switch --flake "$DIR" --impure
	else
		home-manager switch --flake "$DIR" --impure
	fi

	. /etc/os-release

	if [ "$ID" != "nixos" ]; then
		sudo "$NIX" \
			run "github:numtide/system-manager/c9e35e9b7d698533a32c7e34dfdb906e1e0b7d0a" -- \
			switch --flake "$DIR" --nix-option pure-eval false
	fi
}

if [ "$(uname)" = "Darwin" ]; then
	system_darwin
else
	system_linux
fi

"$NIX" run --inputs-from "$DIR" nixpkgs#nh -- \
	clean all --keep-since 14d --keep 3
