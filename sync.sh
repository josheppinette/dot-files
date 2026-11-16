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
	# nh would use `hostname`, which can include `.local`; nix-darwin names
	# machines by LocalHostName instead.
	nh darwin switch "$DIR" --hostname "$(scutil --get LocalHostName)"
elif [ -e /etc/NIXOS ]; then
	nh os switch "$DIR"
else
	echo "sync: unsupported OS, expected macOS or NixOS" >&2
	exit 1
fi

nh clean all --keep-since 14d --keep 3
