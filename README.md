_Nix configuration for my macOS and Linux machines._

# Installation

**macOS**

1. [Install Nix](https://zero-to-nix.com/start/install/)

2. Clone, in a shell with git

   ```sh
   $ nix-shell -p git
   $ git clone https://github.com/josheppinette/dot-files.git ~/Projects/dot-files
   $ git -C ~/Projects/dot-files remote set-url origin git@github.com:josheppinette/dot-files.git
   $ exit
   ```

3. Set the local hostname (`scutil --get LocalHostName`) to one declared in `flake.nix`, or add the machine under `hosts/`

4. Move aside the installer's Nix settings, which nix-darwin manages

   ```sh
   $ sudo mv /etc/nix/nix.custom.conf /etc/nix/nix.custom.conf.before-nix-darwin
   ```

5. Sync

   ```sh
   $ ~/Projects/dot-files/sync.sh
   ```

6. Set zsh as default shell in a new terminal

   ```sh
   $ command -v zsh | sudo tee -a /etc/shells
   $ chsh -s "$(command -v zsh)"
   ```

7. Sign in to 1Password, and turn on its [SSH agent](https://developer.1password.com/docs/ssh/get-started/) (skip its SSH config step)

**NixOS**

1. Install [NixOS](https://nixos.org/download/) with the graphical installer: choose disk encryption, no desktop, and the username from `hosts/<hostname>/nixos.nix` (or add the machine under `hosts/` and `flake.nix`). The hostname is set by the first build.

2. Clone, in a shell with git

   ```sh
   $ nix-shell -p git
   $ git clone https://github.com/josheppinette/dot-files.git ~/Projects/dot-files
   $ git -C ~/Projects/dot-files remote set-url origin git@github.com:josheppinette/dot-files.git
   ```

3. Replace `hosts/<hostname>/hardware-configuration.nix` with the generated one, and stage it (flakes ignore untracked files)

   ```sh
   $ cp /etc/nixos/hardware-configuration.nix ~/Projects/dot-files/hosts/<hostname>/
   $ git -C ~/Projects/dot-files add -A
   $ exit
   ```

   The installer also puts some encryption settings in `/etc/nixos/configuration.nix` (`boot.initrd.luks.devices` for swap, `boot.initrd.secrets` for the keyfile). Copy any it has into `hosts/<hostname>/nixos.nix`, or the next boot may hang waiting for them.

4. Build, then reboot

   ```sh
   $ sudo nixos-rebuild boot --flake ~/Projects/dot-files#<hostname> --option experimental-features 'nix-command flakes'
   ```

5. Sign in to 1Password, and turn on its [SSH agent](https://developer.1password.com/docs/ssh/get-started/) (skip its SSH config step)

# Usage

## Backups

`$HOME` is backed up hourly with [borgmatic](https://torsion.org/borgmatic/) to a local repository in `~/.local/state/borg`, and to a remote repository if the machine sets one in `hosts/<hostname>/`. Add a `.nobackup` file to any directory that shouldn't be backed up.

On a machine with a remote, these commands run on both repositories. Add `--repository local` or `--repository remote` to use one.

```sh
$ borgmatic repo-info                                        # repository size
$ borgmatic list                                             # archives
$ borgmatic list --archive latest --find 'package.json'      # find a file
$ borgmatic extract --archive latest --destination ~/restore # restore files
```

**Creating the remote**

1. Create an SSH key, and add `~/.ssh/borg.pub` to the remote

   ```sh
   $ ssh-keygen -t ed25519 -N '' -f ~/.ssh/borg
   ```

2. Create the repository, pressing Enter at the passphrase prompts. Then save `<hostname>.key` in 1Password and delete the file: without it, the backup can't be restored.

   ```sh
   $ borgmatic repo-create --repository remote --encryption keyfile-blake2
   $ borgmatic key export --repository remote --path <hostname>.key
   ```

**Restoring from the remote**

1. Create an SSH key, and add `~/.ssh/borg.pub` to the remote in place of the old one

   ```sh
   $ ssh-keygen -t ed25519 -N '' -f ~/.ssh/borg
   ```

2. Import `<hostname>.key` from 1Password

   ```sh
   $ borgmatic key import --repository remote --path <hostname>.key
   ```

3. Restore right away, since hourly backups resume and start pruning old archives once the key is imported. Pick the last archive from before the reinstall, extract it into `~/restore`, and move what you need into place.

   ```sh
   $ borgmatic list --repository remote
   $ borgmatic extract --repository remote --archive <archive> --destination ~/restore
   ```

## Google Drive

On the t480, personal Google Drive syncs both ways with `~/GoogleDrive-josheppinette@gmail.com` every 15 minutes, using [rclone bisync](https://rclone.org/bisync/). Google Docs, Sheets and Slides are skipped. When a file changes on both sides, the newer copy wins and the other is kept as `<file>.conflict1`.

**Setting up**

rclone refreshes its OAuth token, so its config lives in `~/.config/rclone/rclone.conf` rather than in Nix. The sync doesn't run until that file exists.

1. Create a remote named `gdrive` of type `drive` with scope `drive`, using [your own client ID](https://rclone.org/drive/#making-your-own-client-id)

   ```sh
   $ rclone config
   ```

2. Run the first sync by hand, which sets the baseline that later syncs compare against

   ```sh
   $ rclone bisync gdrive: ~/GoogleDrive-josheppinette@gmail.com --resync --drive-skip-gdocs --create-empty-src-dirs --verbose
   ```

**Checking on it**

```sh
$ systemctl --user list-timers gdrive-bisync # next and last run
$ journalctl --user -u gdrive-bisync         # logs
$ systemctl --user start gdrive-bisync       # sync now
```

If a sync fails and asks for `--resync`, rerun step 2 of **Setting up** above. It keeps files from both sides.

## Local AI

Ollama runs local models on both machines. On macOS, `pkgs/ollama.nix` replaces the nixpkgs build, which lacks the much faster MLX engine.

| Host        | Model                          | Use                                            |
| ----------- | ------------------------------ | ---------------------------------------------- |
| MacBook-Pro | `qwen3.6:35b-a3b-coding-nvfp4` | Coding with pi                                 |
| t480        | `qwen3.5:4b`                   | Quick questions only, since it runs on the CPU |

```sh
$ ollama pull <model>
$ ollama launch pi --model <model>
```

# Development

**Dev Shell**

Load the dev shell (formatters, pre-commit) with direnv:

```sh
$ direnv allow
$ pre-commit install
```

**Organization**

- `flake.nix`: declares each machine by hostname
- `hosts/<hostname>/`: machine-specific configuration
- `modules/home/`: Home Manager configuration shared by all machines, one file per topic

Handle macOS and Linux differences inline with `pkgs.stdenv.isDarwin`. Avoid custom options and frameworks like flake-parts until more machines need them.

**Updating**

_Weekly: update inputs_

Pulls security fixes and package updates within the current release.

```sh
$ nix flake update
$ ./sync.sh
$ git commit -am "update flake" && git push
```

Then run `git pull && ./sync.sh` on the other machines.

_Every six months: upgrade the release_

nixpkgs releases in May and November (`YY.05`, `YY.11`), and each release gets fixes for about seven months. Upgrade within a month of each release.

1. Update the release branches of the inputs in `flake.nix`
2. Fix removed and renamed packages given the [NixOS release notes](https://nixos.org/manual/nixos/stable/release-notes)
3. Update the configuration given the [nix-darwin changelog](https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG) and [home-manager release notes](https://nix-community.github.io/home-manager/release-notes/release-notes.html). Only bump `stateVersion` after reading what it changes.
4. Run the weekly steps, re-running `./sync.sh` until the switch succeeds

# References

**Documentation**

- [Home Manager options](https://home-manager-options.extranix.com)
- [nix-darwin options](https://nix-darwin.github.io/nix-darwin/manual/)
- [NixOS options](https://search.nixos.org/options)
- [nixos-hardware](https://github.com/NixOS/nixos-hardware)
- [nh](https://github.com/nix-community/nh)
- [borgmatic](https://torsion.org/borgmatic/)
- [rclone bisync](https://rclone.org/bisync/)
- [Determinate Nix](https://docs.determinate.systems/determinate-nix/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world)

**Example Configurations**

- [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)
- [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config)
