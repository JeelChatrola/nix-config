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

  opencodeAgentFiles = [
    "ask.md"
    "debug.md"
    "docs.md"
  ];

  claudeAgentFiles = [
    "ask.md"
    "debug.md"
    "docs.md"
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

  opencodeAgentDeployment = builtins.listToAttrs (
    map (f: {
      name = ".config/opencode/agents/${f}";
      value = { source = ../../ai-stack/agents/opencode/${f}; };
    }) opencodeAgentFiles
  );

  claudeAgentDeployment = builtins.listToAttrs (
    map (f: {
      name = ".claude/agents/${f}";
      value = { source = ../../ai-stack/agents/claude/${f}; };
    }) claudeAgentFiles
  );
in
{
  home.packages = [
    claudeWrapper
    opencodeWrapper
  ];

  home.file = commandDeployment // opencodeAgentDeployment // claudeAgentDeployment // {
    # Claude Code: MCP + permissions
    ".config/claude/settings.json".source = ../../ai-stack/mcp/claude-settings.json;

    # OpenCode: MCP lives in opencode.json (type local + command[]); see opencode.ai/docs/mcp-servers
    ".config/opencode/opencode.json".source = ../../ai-stack/mcp/opencode.json;
  };
}
