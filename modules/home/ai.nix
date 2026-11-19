{ pkgs, ... }:

{
  home.packages = [
    pkgs.files-to-prompt
    pkgs.llm-agents.pi
  ];

  services.ollama.enable = true;

  home.file.".claude/status.sh" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      input=$(cat)
      model=$(echo "$input" | jq -r '.model.display_name // empty')
      used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
      [ -z "$model" ] && exit 0
      if [ -n "$used" ]; then
        printf "%s  %s%%" "$model" "$(printf '%.0f' "$used")"
      else
        printf "%s" "$model"
      fi
    '';
  };

  programs.claude-code = {
    enable = true;
    package = pkgs.llm-agents.claude-code;

    settings = {
      model = "opus";
      effortLevel = "medium";
      statusLine = {
        type = "command";
        command = "$HOME/.claude/status.sh";
      };
      enabledPlugins = {
        "gopls-lsp@claude-plugins-official" = true;
        "typescript-lsp@claude-plugins-official" = true;
        "lua-lsp@claude-plugins-official" = true;
        "clangd-lsp@claude-plugins-official" = true;
        "rust-analyzer-lsp@claude-plugins-official" = true;
      };
      autoMemoryEnabled = false;
      permissions = {
        allow = [
          "Bash(git status:*)"
          "Bash(git diff:*)"
          "Bash(git log:*)"
        ];
      };
    };
  };
}
