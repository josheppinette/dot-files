{ config, pkgs, ... }:

{
  programs.anki = {
    enable = true;
    addons = [ pkgs.ankiAddons.anki-connect ];
    profiles."User 1" = {
      default = true;
      sync = {
        username = "josheppinette@gmail.com";
        # The README explains how to create this file.
        keyFile = "${config.xdg.configHome}/anki/sync-key";
      };
    };
  };
}
