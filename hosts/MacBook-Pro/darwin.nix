{
  determinateNix.enable = true;

  # The home-manager-applications build exceeds the 64KB macOS sandbox limit.
  determinateNix.customSettings.sandbox = false;

  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  users.users.joshep.home = "/Users/joshep";

  system.stateVersion = 7;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.joshep = {
      imports = [ ../../modules/home ];

      programs.git.settings.user.email = "josh.eppinette@realtruck.com";
    };
  };
}
