{
  user,
  home,
  inputs,
  ...
}:
{
  determinateNix.enable = true;

  determinateNix.customSettings = {
    trusted-users = [
      "root"
      "@admin"
    ];
    sandbox = true;
  };

  users.users.${user}.home = home;

  system.stateVersion = 6;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit user home; };
    users.${user} = import ./home.nix;
    sharedModules = [ inputs.mac-app-util.homeManagerModules.default ];
  };
}
