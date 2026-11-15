#!/bin/sh

set -e

DIR=$(dirname "$(realpath "$0")")
NIX=$(command -v nix)

if [ "$(uname)" = "Darwin" ]; then
	sudo -H "$NIX" run --inputs-from "$DIR" nix-darwin -- switch --flake "$DIR"
else
	"$NIX" run --inputs-from "$DIR" home-manager -- switch --flake "$DIR"
	sudo -H "$NIX" run --inputs-from "$DIR" system-manager -- switch --flake "$DIR"
fi

# `nh clean` runs `nix store gc` as root with an empty HOME, so Nix creates a
# root-owned `.cache` in the working directory. Run it from /tmp instead.
cd /tmp
"$NIX" run --inputs-from "$DIR" nixpkgs#nh -- clean all --keep-since 14d --keep 3
