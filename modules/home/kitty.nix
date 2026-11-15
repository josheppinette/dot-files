{
  programs.kitty = {
    enable = true;
    themeFile = "Catppuccin-Mocha";
    shellIntegration = {
      enableZshIntegration = true;
    };
    keybindings = {
      "cmd+t" = "discard_event";
    };
    settings = {
      font_size = "16.0";
      macos_option_as_alt = "yes";
      tab_bar_style = "hidden";
    };
  };
}
