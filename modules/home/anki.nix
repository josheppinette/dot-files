{ config, pkgs, ... }:

{
  programs.anki = {
    enable = true;
    addons = with pkgs.ankiAddons; [
      anki-connect
      passfail2
      review-heatmap
    ];
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
