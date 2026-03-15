{ pkgs, ... }:

let
  claudeWrapper = pkgs.writeShellScriptBin "claude" ''
    export OLLAMA_HOST="''${OLLAMA_HOST:-http://127.0.0.1:11434}"
    export ANTHROPIC_BASE_URL="''${ANTHROPIC_BASE_URL:-http://localhost:11434}"
    export ANTHROPIC_AUTH_TOKEN="''${ANTHROPIC_AUTH_TOKEN:-ollama}"
    exec ${pkgs.nodejs_22}/bin/npx -y @anthropic-ai/claude-code "$@"
  '';

  opencodeWrapper = pkgs.writeShellScriptBin "opencode" ''
    export OLLAMA_HOST="''${OLLAMA_HOST:-http://127.0.0.1:11434}"
    exec ${pkgs.nodejs_22}/bin/npx -y opencode-ai "$@"
  '';

  commandFiles = [
    { name = "commit.md"; }
    { name = "review.md"; }
    { name = "setup-project.md"; }
  ];

  # One source of truth for commands, deployed to both agents
  commandDeployment = builtins.listToAttrs (
    builtins.concatMap (cmd: [
      {
        name = ".claude/commands/${cmd.name}";
        value = { source = ../../ai-stack/commands/${cmd.name}; };
      }
      {
        name = ".config/opencode/commands/${cmd.name}";
        value = { source = ../../ai-stack/commands/${cmd.name}; };
      }
    ]) commandFiles
  );
in
{
  home.packages = [
    claudeWrapper
    opencodeWrapper
  ];

  home.file = commandDeployment // {
    # Claude Code: MCP + permissions
    ".config/claude/settings.json".source = ../../ai-stack/mcp/claude-settings.json;

    # OpenCode: MCP + provider + permissions
    ".config/opencode/mcp.toml".source = ../../ai-stack/mcp/opencode.toml;
    ".config/opencode/opencode.json".source = ../../ai-stack/mcp/opencode.json;
  };
}
