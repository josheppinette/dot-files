{ inputs, ... }:

{
  # Resolve `nixpkgs#...` and `<nixpkgs>` to the nixpkgs this config is built
  # from, instead of downloading a different (unstable) one.
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
}
