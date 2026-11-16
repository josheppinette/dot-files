_Nix configuration for my macOS and Linux machines._

# Installation

1. [Install Nix](https://zero-to-nix.com/start/install/)

2. Clone

   ```sh
   $ nix run nixpkgs#git -- clone https://github.com/josheppinette/dot-files.git ~/Software/dot-files
   $ nix run nixpkgs#git -- -C ~/Software/dot-files remote set-url origin git@github.com:josheppinette/dot-files.git
   ```

3. Set the hostname to one declared in `flake.nix`, or add the machine under `hosts/`

4. Sync

   ```sh
   $ ~/Software/dot-files/sync.sh
   ```

5. Set zsh as default shell in a new terminal

   ```sh
   $ command -v zsh | sudo tee -a /etc/shells
   $ chsh -s "$(command -v zsh)"
   ```

6. Set up the [1Password SSH agent](https://developer.1password.com/docs/ssh/get-started/) (skip its SSH config step)

7. Create the [backup](#backups) repository

   ```sh
   $ borgmatic repo-create --encryption none
   ```

# Backups

`$HOME` is backed up hourly to `~/.local/state/borg` with [borgmatic](https://torsion.org/borgmatic/). Add a `.nobackup` file to any directory that shouldn't be backed up.

```sh
$ borgmatic list                                        # archives
$ borgmatic list --archive latest --find 'package.json' # find a file
$ borgmatic extract --archive latest --path ~/Software/linux --destination /tmp/restore
$ borgmatic repo-info                                   # repository size
```

# Development

## Setup

Load the dev shell (formatters, pre-commit) with direnv:

```sh
$ direnv allow
$ pre-commit install
```

## Organization

- `flake.nix`: declares each machine by hostname
- `hosts/<hostname>/`: machine-specific configuration
- `modules/home/`: Home Manager configuration shared by all machines, one file per topic

Handle macOS and Linux differences inline with `pkgs.stdenv.isDarwin`. Avoid custom options and frameworks like flake-parts until more machines need them.

## Updating

### Weekly: update inputs

Pulls security fixes and package updates within the current release.

```sh
$ nix flake update
$ ./sync.sh
$ git commit -am "update flake" && git push
```

Then run `git pull && ./sync.sh` on the other machines.

### Every six months: upgrade the release

nixpkgs releases in May and November (`YY.05`, `YY.11`), and each release gets fixes for about seven months. Upgrade within a month of each release.

1. Update the release branches of the inputs in `flake.nix`
2. Fix removed and renamed packages given the [NixOS release notes](https://nixos.org/manual/nixos/stable/release-notes)
3. Update the configuration given the [nix-darwin changelog](https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG) and [home-manager release notes](https://nix-community.github.io/home-manager/release-notes/release-notes.html). Only bump `stateVersion` after reading what it changes.
4. Run the weekly steps, re-running `./sync.sh` until the switch succeeds

# References

**Documentation**

- [Home Manager options](https://home-manager-options.extranix.com)
- [nix-darwin options](https://nix-darwin.github.io/nix-darwin/manual/)
- [system-manager](https://github.com/numtide/system-manager)
- [nh](https://github.com/nix-community/nh)
- [borgmatic](https://torsion.org/borgmatic/)
- [Determinate Nix](https://docs.determinate.systems/determinate-nix/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world)

**Example Configurations**

- [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)
- [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config)
