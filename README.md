_This repo contains the Nix configuration for my MacOS and Linux machines. Follow the documentation below to get started._

# Getting Started

1. Add ssh keys

2. [Install Nix](https://zero-to-nix.com/start/install/)

3. Sync

   ```
   $ ./sync.sh
   ```

4. Set zsh as default shell

# Development

Once you have the environment setup, you can use the `devShells` support via direnv to manage the development environment for this project.

**Setup**

```sh
$ direnv allow
$ pre-commit install
```

**Making Changes**

After any changes have been made, run `./sync.sh` to update the system.

**Software Updates**

Nix releases major version updates every six months and security fixes throughout that period. We should maintain updated software by running the following steps on all machines at a regular cadence.

1. Note system version

    > We will use this system version to run a report at the end of the upgrade process.

    ```sh
    $ readlink /nix/var/nix/profiles/system
    ```

1. Update configuration

    a. Update flake inputs
    b. Update nix-darwin configuration and state version given latest [changes](https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG)
    c. Update home-manager configuration and state version given latest [changes](https://nix-community.github.io/home-manager/release-notes.xhtml)


2. Run flake update

    ```sh
    $ nix flake update
    ```

3. Sync

    > Any issues will be logged in the terminal. Make any necessary updates and re-run sync until the switch is successful.

    ```sh
    ./sync.sh
    ```

4. Report changes

    ```sh
    $ nix store diff-closures \
      /nix/var/nix/profiles/system-<version>-link \
      /nix/var/nix/profiles/system
    ```

5. Commit & Push

    ```
    $ git commit -am "<msg>" && git push
    ```

# References

- [https://github.com/mrkuz/macos-config](https://github.com/mrkuz/macos-config)
- [https://github.com/dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)
- [https://nixcademy.com/posts/macos-linux-builder/](https://nixcademy.com/posts/macos-linux-builder/)
