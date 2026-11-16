_This repo contains the Nix configuration for my MacOS and Linux machines. Follow the documentation below to get started._

# Getting Started

1. Set up the [1Password SSH agent](https://developer.1password.com/docs/ssh/get-started/)

2. [Install Nix](https://zero-to-nix.com/start/install/)

3. Sync

   ```
   $ ./sync.sh
   ```

4. Set zsh as default shell in a new terminal

   ```sh
   $ command -v zsh | sudo tee -a /etc/shells
   $ chsh -s "$(command -v zsh)"
   ```

5. Create the [backup](#backups) repository

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

# Organization

- `flake.nix`: declares each machine by hostname
- `hosts/<hostname>/`: machine-specific configuration
- `modules/home/`: Home Manager configuration shared by all machines, one file per topic

Handle macOS and Linux differences inline with `pkgs.stdenv.isDarwin`. Avoid custom options and frameworks like flake-parts until more machines need them.

# Development

Once you have the environment setup, you can use the `devShells` support via direnv to manage the development environment for this project.

**Setup**

```sh
$ direnv allow
$ pre-commit install
```

**Making Changes**

After any changes have been made, run `./sync.sh` to update the system.

# Updating

Nix releases major version updates every six months and security fixes throughout that period. We should maintain updated software by running the following steps on all machines at a regular cadence.

1. Update configuration

   a. Update the release branches of the inputs in `flake.nix`
   b. Update packages given the latest [NixOS release notes](https://nixos.org/manual/nixos/stable/release-notes) (removed and renamed packages)
   c. Update nix-darwin configuration and `system.stateVersion` given the latest [changes](https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG)
   d. Update home-manager configuration and `home.stateVersion` given the latest [release notes](https://nix-community.github.io/home-manager/release-notes/release-notes.html)

2. Run flake update

   ```sh
   $ nix flake update
   ```

3. Sync

   > Any issues will be logged in the terminal. Make any necessary updates and re-run sync until the switch is successful. Each sync prints a package diff before activating.

   ```sh
   ./sync.sh
   ```

4. Commit & Push

   ```
   $ git add -A && git commit -m "<msg>" && git push
   ```

# References

**Documentation**

- [Home Manager options](https://home-manager-options.extranix.com)
- [nix-darwin options](https://nix-darwin.github.io/nix-darwin/manual/)
- [system-manager](https://github.com/numtide/system-manager)
- [nh](https://github.com/nix-community/nh)
- [borgmatic](https://torsion.org/borgmatic/)
- [Determinate Nix](https://docs.determinate.systems/determinate-nix/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world)

**Examples Configurations**

- [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)
- [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config)
