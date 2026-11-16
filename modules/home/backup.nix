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
            "${home}/.thumbnails"
            "${home}/.tldrc"
            "${home}/.var/app/*/cache"

            # Package caches and installed toolchains.
            "${home}/.bun/install/cache"
            "${home}/.cargo/git"
            "${home}/.cargo/registry"
            "${home}/.gradle/caches"
            "${home}/.gradle/wrapper"
            "${home}/.ivy2/cache"
            "${home}/.m2/repository"
            "${home}/.npm"
            "${home}/.nvm/versions"
            "${home}/.opam"
            "${home}/.pyenv/versions"
            "${home}/.rustup"
            "${home}/.sbt/boot"
            "${home}/go/pkg/mod"

            # Downloaded models.
            "${home}/.ollama/models"

            # Trash.
            "${home}/.Trash"
            "${home}/.local/share/Trash"

            # Rebuildable project directories.
            "*/.direnv"
            "*/.venv"
            "*/__pycache__"
            "*/node_modules"
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
