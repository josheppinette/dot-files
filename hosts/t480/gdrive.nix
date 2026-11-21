{
  config,
  lib,
  pkgs,
  ...
}:

let
  remote = "gdrive:";
  local = "${config.home.homeDirectory}/GoogleDrive-josheppinette@gmail.com";
in
{
  home.packages = [ pkgs.rclone ];

  systemd.user.tmpfiles.rules = [ "d ${local} 0700 - - -" ];

  systemd.user.services.gdrive-bisync = {
    Unit = {
      Description = "Two-way sync of Google Drive with ${local}";
      ConditionPathExists = "${config.xdg.configHome}/rclone/rclone.conf";
    };
    Service = {
      Type = "oneshot";
      ExecStart = lib.escapeShellArgs [
        "${pkgs.rclone}/bin/rclone"
        "bisync"
        remote
        local
        # Google Docs aren't files, so exporting them would duplicate them.
        "--drive-skip-gdocs"
        "--create-empty-src-dirs"
        "--resilient"
        "--recover"
        "--max-lock=2m"
        "--conflict-resolve=newer"
        "--fast-list"
        "--verbose"
      ];
      Nice = 10;
      IOSchedulingClass = "idle";
    };
  };

  systemd.user.timers.gdrive-bisync = {
    Unit.Description = "Periodic Google Drive sync";
    Timer = {
      OnBootSec = "5m";
      OnUnitActiveSec = "15m";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
