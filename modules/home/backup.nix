{ config, ... }:

let
  home = config.home.homeDirectory;
in
{
  programs.borgmatic = {
    enable = true;
    backups.home = {
      location = {
        sourceDirectories = [ home ];
        repositories = [
          {
            path = "${config.xdg.stateHome}/borg";
            label = "local";
          }
        ];
        extraConfig = {
          one_file_system = true;
          # Skips directories with a CACHEDIR.TAG (Cargo `target`, pytest, mypy, ruff, ...).
          exclude_caches = true;
          exclude_if_present = [ ".nobackup" ];
          # Skip files macOS doesn't let background jobs read (Downloads,
          # Desktop, ...) instead of failing the whole backup.
          borg_exit_codes = [
            {
              code = 105;
              treat_as = "warning";
            }
          ];
          exclude_patterns = [
            # The repository itself.
            "${config.xdg.stateHome}/borg"

            # macOS app state: mostly caches, synced data and files macOS
            # doesn't let background jobs read.
            "${home}/Library"

            # Caches.
            "${home}/.cache"
            "${home}/.var/app/*/cache"

            # Trash.
            "${home}/.Trash"
            "${home}/.local/share/Trash"

            # Package caches and installed toolchains (re-downloadable).
            "${home}/.rustup"
            "${home}/.cargo/registry"
            "${home}/.cargo/git"
            "${home}/go/pkg/mod"
            "${home}/.ghcup"
            "${home}/.cabal/packages"
            "${home}/.cabal/store"
            "${home}/.stack"
            "${home}/.opam"
            "${home}/.m2/repository"
            "${home}/.gradle/caches"
            "${home}/.gradle/wrapper"
            "${home}/.ivy2/cache"
            "${home}/.sbt/boot"
            "${home}/.npm"
            "${home}/.bun/install/cache"
            "${home}/.local/share/pnpm/store"
            "${home}/.nvm/versions"
            "${home}/.pyenv/versions"

            # VM images, containers and models (re-downloadable).
            "${home}/.vagrant.d/boxes"
            "${home}/.local/share/containers"
            "${home}/.ollama/models"
            "*.iso"

            # Project build output. Only names that are never source belong
            # here; ambiguous ones (build, target, dist, bin, _build, out) are
            # kept, so drop a .nobackup in a heavy build directory instead.
            # Not a copy of .gitignore: ignored files like .env, *.db and
            # datasets are often the only copy.
            "*/node_modules"
            "*/.venv"
            "*/.direnv"
            "*/__pycache__"
            "*/.ipynb_checkpoints"
            "*/.parcel-cache"
            "*/dist-newstyle"
            "*/.stack-work"
            "*/_opam"
            "*/.gradle"
            "*/.bsp"
            "*/.scala-build"
            "*/.metals"
            "*/.bloop"
            "*/.vagrant"
            "*/.xmake"
            "*/.zig-cache"
            "*/zig-out"
          ];
        };
      };
      retention = {
        keepHourly = 24;
        keepDaily = 7;
        keepWeekly = 4;
        keepMonthly = 6;
      };
      consistency.checks = [
        {
          name = "repository";
          frequency = "1 month";
        }
        {
          name = "archives";
          frequency = "1 month";
        }
      ];
    };
  };

  services.borgmatic = {
    enable = true;
    frequency = "hourly";
  };
}
