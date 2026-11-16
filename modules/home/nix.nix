{ inputs, ... }:

{
  imports = [ inputs.nix-index-database.homeModules.nix-index ];

  # Resolve `nixpkgs#...` and `<nixpkgs>` to the nixpkgs this config is built
  # from, instead of downloading a different (unstable) one.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Prebuilt weekly database for `nix-locate` and command-not-found, updated
  # with `nix flake update`.
  programs.nix-index.enable = true;

  # `, cmd` runs any program without installing it.
  programs.nix-index-database.comma.enable = true;
}
