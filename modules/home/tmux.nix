{ pkgs, ... }:

{
  home.packages = [
    pkgs.gitmux
    pkgs.tmux-sessionizer
    (if pkgs.stdenv.isDarwin then pkgs.reattach-to-user-namespace else pkgs.xclip)
  ];

  home.file.".config/tms/config.toml".text = ''
    [[search_dirs]]
    path = "~/Projects"
    depth = 1
  '';

  home.file.".gitmux.conf".text = ''
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
      set -g extended-keys on
      set -g extended-keys-format csi-u

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

      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
    '';
  };
}
