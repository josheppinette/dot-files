#!/bin/sh

set -e

DIR=$(dirname "$(realpath "$0")")
NIX=$(command -v nix)

# `nh` runs its root commands with an empty HOME, so Nix creates a root-owned
# `.cache` in the working directory. Run everything from /tmp instead.
cd /tmp

nh() {
	"$NIX" run --inputs-from "$DIR" nixpkgs#nh -- "$@"
}

if [ "$(uname)" = "Darwin" ]; then
	nh darwin switch "$DIR"
else
	nh home switch "$DIR"
	sudo -H "$NIX" run --inputs-from "$DIR" system-manager -- switch --flake "$DIR"
fi

nh clean all --keep-since 14d --keep 3
