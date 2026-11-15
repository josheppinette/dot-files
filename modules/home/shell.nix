{ pkgs, ... }:

{
  home.packages = [
    pkgs.curl
    pkgs.dust
    pkgs.entr
    pkgs.glow
    pkgs.httpie
    pkgs.imagemagick
    pkgs.poppler-utils
    pkgs.procps
    pkgs.procs
    pkgs.rename
    pkgs.ripgrep
    pkgs.rsync
    pkgs.sd
    pkgs.tlrc
    pkgs.tree
    pkgs.tree-sitter
  ];

  home.file.".hushlogin".text = "";

  programs.bat.enable = true;
  programs.eza.enable = true;
  programs.fd.enable = true;
  programs.jq.enable = true;
  programs.nix-index.enable = true;
  programs.visidata.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f";
    defaultOptions = [
      "--preview"
      "'bat --color=always --style=numbers --line-range=:250 {}'"
    ];
  };

  programs.zsh = {
    enable = true;
    shellAliases = {
      vimf = ''nvim -o "$(fzf)"'';
      fda = "fd --hidden --exclude .git --exclude .direnv --exclude __pycache__ --type f";
    };
    defaultKeymap = "emacs";
    initContent = ''
      PROMPT='%F{blue}%(5~|%-1~/…/%3~|%~)%f $ '

      function git-open() { (
          set -e
          git remote >>/dev/null
          remote=''${1:-origin}
          url=$(git config remote.$remote.url | sed "s/git@\(.*\):\(.*\).git/https:\/\/\1\/\2/")
          echo "git: opening $remote $url"
          ${if pkgs.stdenv.isDarwin then "open" else "xdg-open"} $url
      ); }

      if [ -z "$TMUX" ] && [ "$TERM" = "xterm-kitty" ]; then
        tmux new-session -A -c $HOME -s home;
      fi
    '';
  };
}
