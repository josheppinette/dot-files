{ pkgs, ... }:

# Vaults are synced by Obsidian Sync (personal) or OneDrive (work), not managed here.
{
  home.packages = [ pkgs.obsidian ];
}
