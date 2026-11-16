{ lib, pkgs, ... }:

# The app itself is installed per host (NixOS and nix-darwin modules), since it
# needs system permissions for browser integration and the CLI.
{
  programs.ssh.settings."*".IdentityAgent =
    if pkgs.stdenv.isDarwin then
      ''"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"''
    else
      "~/.1password/agent.sock";

  # Start 1Password minimized to the tray so its SSH agent is available. On
  # macOS, its own "Start at login" setting works.
  xdg.autostart = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    entries = [
      "${
        pkgs.makeDesktopItem {
          name = "1password";
          desktopName = "1Password";
          exec = "1password --silent";
        }
      }/share/applications/1password.desktop"
    ];
  };
}
