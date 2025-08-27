{
  pkgs,
  user,
  home,
  ...
}:

{
  targets.genericLinux.enable = pkgs.stdenv.isLinux;

  home.username = user;
  home.homeDirectory = home;
  home.stateVersion = "25.05";

  home.packages =
    [
      # formatters
      pkgs.nixfmt-rfc-style

      # utilities
      pkgs.curl
      pkgs.dust
      pkgs.httpie
      pkgs.procps
      pkgs.procs
      pkgs.rename
      pkgs.ripgrep
      pkgs.sd
      pkgs.tlrc
      pkgs.tree
      pkgs.tree-sitter

      # terminal
      pkgs.gitmux
      pkgs.tmux-sessionizer

      # languages
      pkgs.llvmPackages.libcxxClang
      pkgs.python312

      # lsp
      pkgs.clang-tools
      pkgs.haskell-language-server
      pkgs.lua-language-server
      pkgs.nixd
      pkgs.python312Packages.python-lsp-server
      pkgs.taplo
      pkgs.typescript-language-server
      pkgs.phpactor

      # build
      pkgs.gnumake
      pkgs.pkg-config

    ]
    ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [
      pkgs.reattach-to-user-namespace
    ]);

  home.file = {
    ".hushlogin".text = "";
    ".config/tms/config.toml".text = ''
      [[search_dirs]]
      path = "~/Software"
      depth = 1
    '';
    ".gitmux.conf".text = ''
      tmux:
        styles:
          clear: "#[fg=#{@thm_fg}]"
          state: "#[fg=#{@thm_red},bold]"
          branch: "#[fg=#{@thm_fg},bold]"
          remote: "#[fg=#{@thm_teal}]"
          divergence: "#[fg=#{@thm_fg}]"
          staged: "#[fg=#{@thm_green},bold]"
          conflict: "#[fg=#{@thm_red},bold]"
          modified: "#[fg=#{@thm_yellow},bold]"
          untracked: "#[fg=#{@thm_mauve},bold]"
          stashed: "#[fg=#{@thm_blue},bold]"
          clean: "#[fg=#{@thm_rosewater},bold]"
          insertions: "#[fg=#{@thm_green}]"
          deletions: "#[fg=#{@thm_red}]"
    '';
  };

  programs.home-manager.enable = true;
  programs.eza.enable = true;
  programs.fd.enable = true;
  programs.bat.enable = true;
  programs.jq.enable = true;
  programs.nix-index.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    extraLuaConfig = builtins.readFile ./nvim.lua;
    extraPackages = [
      pkgs.cargo
      pkgs.yarn
    ];
    withNodeJs = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

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
      PROMPT='%F{blue}%~%f $ '

      function git-open() { (
          set -e
          git remote >>/dev/null
          remote=''${1:-origin}
          url=$(git config remote.$remote.url | sed "s/git@\(.*\):\(.*\).git/https:\/\/\1\/\2/")
          echo "git: opening $remote $url"
          open $url
      ); }

      if [ -z "$TMUX" ] && [ "$TERM" = "xterm-kitty" ]; then
        tmux new-session -A -c $HOME -s home;
      fi
    '';
  };

  programs.git = {
    enable = true;
    userEmail = "josheppinette@gmail.com";
    userName = "Joshua Taylor Eppinette";
    aliases = {
      conflicts = "diff --name-only --diff-filter=U --relative";
    };
    extraConfig = {
      branch.sort = "-committerdate";
      commit.verbose = "true";
      diff.algorithm = "histogram";
      diff.colorMoved = "true";
      diff.mnemonicPrefix = "true";
      feature.experimental = "true";
      fetch.all = "true";
      fetch.prune = "true";
      fetch.pruneTags = "true";
      grep.patternType = "perl";
      help.autocorrect = "prompt";
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      pull.rebase = "true";
      push.autoSetupRemote = "true";
      push.followTags = "true";
      rebase.autosquash = "true";
      rebase.autostash = "true";
      rebase.updateRefs = "true";
      tag.sort = "version:refname";
    };
  };

  programs.tmux = {
    enable = true;
    keyMode = "vi";
    terminal = "screen-256color";
    shell = "${pkgs.zsh}/bin/zsh";
    plugins = with pkgs; [
      tmuxPlugins.yank
      tmuxPlugins.sensible
      tmuxPlugins.open
      tmuxPlugins.resurrect
      tmuxPlugins.continuum
      tmuxPlugins.catppuccin
    ];
    extraConfig = ''
      set -g status-right-length 200
      set -g status-left-length 200

      set -g @catppuccin_date_time_text " %Y-%m-%d %I:%M %p"

      set -g status-left "#{E:@catppuccin_status_session}"
      set -ag status-left "#{E:@catppuccin_status_application}"

      set -g @catppuccin_status_left_separator "█"
      set -g @catppuccin_status_right_separator "█"

      set -gF status-right "#{@catppuccin_status_gitmux}"
      set -ag status-right "#{E:@catppuccin_status_user}"
      set -ag status-right "#{E:@catppuccin_status_host}"
      set -ag status-right "#{E:@catppuccin_status_date_time}"

      set -gu default-command
      set -g window-status-current-format ""
      set -g window-status-format ""

      bind s display-popup -E "tms switch"
      bind o display-popup -E "tms"
      bind q run-shell "tms kill"
      bind n command-prompt -p "init repo:" "run-shell 'tms init-repo %1'"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };
}
