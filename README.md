_Nix configuration for my macOS and Linux machines._

# Machines

| Host          | OS               | Use             |
| ------------- | ---------------- | --------------- |
| `MacBook-Pro` | macOS            | Work laptop     |
| `t480`        | NixOS            | Personal laptop |
| `homelab`     | NixOS (headless) | Personal server |

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

**NixOS**

1. Install [NixOS](https://nixos.org/download/) with the graphical installer: choose disk encryption (except on servers, which must boot unattended), no desktop, and the username from `hosts/<hostname>/nixos.nix` (or add the machine under `hosts/` and `flake.nix`). The hostname is set by the first build.

2. Clone, in a shell with git (on servers, skip `set-url`: without 1Password, they pull over HTTPS)

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

   With disk encryption, the installer also puts some settings in `/etc/nixos/configuration.nix` (`boot.initrd.luks.devices` for swap, `boot.initrd.secrets` for the keyfile). Copy any it has into `hosts/<hostname>/nixos.nix`, or the next boot may hang waiting for them.

4. Build, then reboot

   ```sh
   $ sudo nixos-rebuild boot --flake ~/Projects/dot-files#<hostname> --option experimental-features 'nix-command flakes'
   ```

After installing, follow **Setting up** in each Usage section for the machine.

# Usage

## Passwords

_Machines: MacBook-Pro, t480_

[1Password](https://1password.com) holds passwords and SSH keys. Its [SSH agent](https://developer.1password.com/docs/ssh/get-started/) serves the keys to `git` and `ssh`.

**Setting up**

1. Sign in to 1Password, and turn on its SSH agent (skip its SSH config step)

## VPN

_Machines: t480, homelab_

[Tailscale](https://tailscale.com) connects the machines into a global private network (a tailnet), so they reach each other by name.

```sh
$ tailscale status         # machines on the tailnet, and which are online
$ tailscale ping <machine> # whether it's reachable, and if directly or through a relay
$ tailscale ip             # this machine's tailnet addresses
```

**Setting up**

1. Join the tailnet, and approve the machine in the [admin console](https://login.tailscale.com/admin/machines)

   ```sh
   $ sudo tailscale up
   ```

2. On servers, disable key expiry for the machine in the admin console, or it drops off the tailnet every 180 days

## Backups

_Machines: all_

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

## LLMs

_Machines: all_

[Ollama](https://ollama.com) runs models on `homelab` and `MacBook-Pro`. `t480` uses `homelab`'s over the VPN, so the commands are the same everywhere.

| Model                    | Use                                                     |
| ------------------------ | ------------------------------------------------------- |
| `qwen3.6:35b-a3b-coding` | Coding with pi, and anything that needs care            |
| `qwen3.5:9b`             | Quick questions, when the coding model is slow to start |

On macOS, prefer MLX models, like the `-nvfp4` tags, which run much faster.

```sh
$ ollama pull <model>              # download
$ ollama run <model>               # chat
$ ollama launch pi --model <model> # code with pi
$ ollama ps                        # loaded models, and how much is on the GPU
```

To chat in the browser, open [Open WebUI](https://openwebui.com) from the [dashboard](https://lab.josheppinette.com/). It uses `homelab`'s models.

## Storage

_Machines: homelab_

`/tank` is a [ZFS](https://openzfs.github.io/openzfs-docs/) pool of the four 6TB WD Reds as RAIDZ2: about 10.4TB usable, and any two disks can fail. It's scrubbed monthly, and smartd watches the disks.

[sanoid](https://github.com/jimsalterjrs/sanoid) snapshots it every hour, keeping 24 hourly, 30 daily and 6 monthly snapshots. Copy deleted or overwritten files back from `/tank/.zfs/snapshot/<snapshot>/`.

```sh
$ zpool status tank         # disk health and scrub results
$ zfs list -t snapshot tank # snapshots
$ sudo journalctl -u smartd # SMART warnings
```

To replace a failed disk, `sudo zpool replace tank <old-disk-id> /dev/disk/by-id/<new-disk-id>`, then watch the rebuild in `zpool status`.

**Setting up**

The configuration imports the pool at boot, but can't create it. On new disks, create it with:

```sh
$ sudo zpool create -o ashift=12 -O compression=lz4 -O atime=off -O xattr=sa -O acltype=posixacl -O mountpoint=/tank \
    tank raidz2 /dev/disk/by-id/ata-WDC_WD60EFRX-68MYMN1_WD-{WX31DB44K20N,WX21DC42E8UA,WX11DC449EFU,WX11DC4FK82S}
$ sudo chown josh: /tank
```

A reinstall leaves the pool on the disks, so skip this.

## Dashboard

_Machines: homelab_

[lab.josheppinette.com](https://lab.josheppinette.com) is a [Homepage](https://gethomepage.dev) linking to the apps on `homelab`. Its DNS records point at `homelab`'s tailnet address, so it only works on the VPN.

[Caddy](https://caddyserver.com) serves each app on its own subdomain of `lab`, with a wildcard certificate from Let's Encrypt. To add one, add its link to `services.homepage-dashboard` and its subdomain to `services.caddy`.

```sh
$ journalctl -u caddy # certificate and proxy errors
```

**Setting up**

1. In Cloudflare, add `A` records for `lab` and `*.lab` pointing at `tailscale ip -4`, with proxying off

2. Create a Cloudflare API token from the Edit zone DNS template, limited to `josheppinette.com`, and save it on `homelab`

   ```sh
   $ sudo install -d -m 755 /etc/caddy
   $ (umask 077; echo 'CLOUDFLARE_API_TOKEN=<token>' | sudo tee /etc/caddy/cloudflare.env >/dev/null)
   $ sudo systemctl restart caddy
   ```

## File Sync

_Machines: t480_

Personal Google Drive syncs both ways with `~/GoogleDrive-josheppinette@gmail.com` every 15 minutes, using [rclone bisync](https://rclone.org/bisync/). Google Docs, Sheets and Slides are skipped. When a file changes on both sides, the newer copy wins and the other is kept as `<file>.conflict1`.

```sh
$ systemctl --user list-timers gdrive-bisync # next and last run
$ journalctl --user -u gdrive-bisync         # logs
$ systemctl --user start gdrive-bisync       # sync now
```

If a sync fails and asks for `--resync`, rerun step 2 of **Setting up** below. It keeps files from both sides.

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

## Flashcards

_Machines: t480_

Flashcards are in [Anki](https://apps.ankiweb.net), synced with AnkiWeb. Its preferences are managed in `modules/home/anki.nix`, so changes made in its Preferences window are reset on the next sync.

**Setting up**

1. Open Tools > Preferences > Syncing, log in, then close Preferences. In the warning that follows, choose Show Details and copy the key from `syncKey changed from None to <key>`.

2. Save the key, then restart Anki

   ```sh
   $ mkdir -p ~/.config/anki && echo '<key>' > ~/.config/anki/sync-key && chmod 600 ~/.config/anki/sync-key
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
- `modules/home/`: Home Manager configuration, one file per topic. Every machine imports `base.nix`, machines with a desktop also import `desktop.nix`, and anything else is imported by topic.

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
- [Determinate Nix](https://docs.determinate.systems/determinate-nix/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world)

**Example Configurations**

- [Misterio77/nix-starter-configs](https://github.com/Misterio77/nix-starter-configs)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [dustinlyons/nixos-config](https://github.com/dustinlyons/nixos-config)
- [mitchellh/nixos-config](https://github.com/mitchellh/nixos-config)
