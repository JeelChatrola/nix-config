{ pkgs, lib, ... }:

let
  aiRoot = ../../ai-stack;

  mdFiles = dir:
    lib.sort lib.lessThan (
      lib.filter (n: lib.hasSuffix ".md" n) (builtins.attrNames (builtins.readDir dir))
    );

  commandsDir = aiRoot + "/commands";
  opencodeAgentsDir = aiRoot + "/agents/opencode";
  claudeAgentsDir = aiRoot + "/agents/claude";

  commandNames = mdFiles commandsDir;
  opencodeAgentNames = mdFiles opencodeAgentsDir;
  claudeAgentNames = mdFiles claudeAgentsDir;

  commandDeployment = builtins.listToAttrs (
    builtins.concatMap (name: [
      {
        name = ".claude/commands/${name}";
        value.source = aiRoot + "/commands/" + name;
      }
      {
        name = ".config/opencode/commands/${name}";
        value.source = aiRoot + "/commands/" + name;
      }
    ]) commandNames
  );

  opencodeAgentDeployment = builtins.listToAttrs (
    map (name: {
      name = ".config/opencode/agents/${name}";
      value.source = aiRoot + "/agents/opencode/" + name;
    }) opencodeAgentNames
  );

  claudeAgentDeployment = builtins.listToAttrs (
    map (name: {
      name = ".claude/agents/${name}";
      value.source = aiRoot + "/agents/claude/" + name;
    }) claudeAgentNames
  );

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
in
{
  home.packages = [
    claudeWrapper
    opencodeWrapper
  ];

  home.file =
    commandDeployment
    // opencodeAgentDeployment
    // claudeAgentDeployment
    // {
      ".config/claude/settings.json".source = aiRoot + "/mcp/claude-settings.json";
      ".config/opencode/opencode.json".source = aiRoot + "/mcp/opencode.json";
    };
}
