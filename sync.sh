#!/bin/sh

set -e

DIR=$(dirname "$(realpath "$0")")
NIX=$(command -v nix)

if [ "$(uname)" = "Darwin" ]; then
	sudo "$NIX" run --inputs-from "$DIR" nix-darwin -- switch --flake "$DIR"
else
	"$NIX" run --inputs-from "$DIR" home-manager -- switch --flake "$DIR"
	sudo "$NIX" run --inputs-from "$DIR" system-manager -- switch --flake "$DIR"
fi

"$NIX" run --inputs-from "$DIR" nixpkgs#nh -- clean all --keep-since 14d --keep 3
