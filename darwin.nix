{
  user,
  home,
  ...
}:
{
  determinateNix.enable = true;

  determinateNix.customSettings = {
    trusted-users = [
      "root"
      "@admin"
    ];
    sandbox = "relaxed";
  };

  users.users.${user}.home = home;

  system.stateVersion = 7;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit user home; };
    users.${user} = import ./home.nix;
  };
}
