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

1. Note system version

   > We will use this system version to run a report at the end of the upgrade process.

   ```sh
   $ readlink /nix/var/nix/profiles/system
   ```

2. Update configuration

   a. Update the release branches in `flake.nix` (`nixpkgs`, `home-manager`, `nix-darwin`)
   b. Update packages given the latest [NixOS release notes](https://nixos.org/manual/nixos/stable/release-notes) (removed and renamed packages)
   c. Update nix-darwin configuration and `system.stateVersion` given the latest [changes](https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG)
   d. Update home-manager configuration and `home.stateVersion` given the latest [release notes](https://nix-community.github.io/home-manager/release-notes/release-notes.html)

3. Run flake update

   ```sh
   $ nix flake update
   ```

4. Sync

   > Any issues will be logged in the terminal. Make any necessary updates and re-run sync until the switch is successful.

   ```sh
   ./sync.sh
   ```

5. Report changes

   ```sh
   $ nix store diff-closures \
     /nix/var/nix/profiles/system-<version>-link \
     /nix/var/nix/profiles/system
   ```

6. Commit & Push

   ```
   $ git add -A && git commit -m "<msg>" && git push
   ```

# References

- [https://github.com/mrkuz/macos-config](https://github.com/mrkuz/macos-config)
- [https://github.com/dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)
- [https://nixcademy.com/posts/macos-linux-builder/](https://nixcademy.com/posts/macos-linux-builder/)
- [https://home-manager-options.extranix.com](https://home-manager-options.extranix.com)
- [https://docs.determinate.systems/determinate-nix/](https://docs.determinate.systems/determinate-nix/)
