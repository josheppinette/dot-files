{
  imports = [
    ./ai.nix
    ./dev.nix
    ./git.nix
    ./kitty.nix
    ./neovim
    ./shell.nix
    ./ssh.nix
    ./tmux.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
