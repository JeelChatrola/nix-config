{ config, pkgs, lib, aiStackSrc, aiConfigRoot ? null, ... }:

let
  aiRoot = aiStackSrc;
  nixConfigRepo =
    if aiConfigRoot != null then aiConfigRoot else config.home.homeDirectory + "/nix-config";
  aiStackDir = nixConfigRepo + "/ai-stack";

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

  hermesWrapper = pkgs.writeShellScriptBin "hermes" ''
    exec "${aiStackDir}/bin/hermes" "$@"
  '';
in
{
  home.packages = [
    claudeWrapper
    opencodeWrapper
    hermesWrapper
  ];

  home.file = commandDeployment // opencodeAgentDeployment // claudeAgentDeployment;

  # Generated MCP JSON under ai-stack/generated/ (mutable, gitignored). Refresh on switch, symlink into ~/.config.
  home.activation.aiStackGeneratedAndLinks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    set -euo pipefail
    export AI_STACK_DIR="${aiStackDir}"
    export PATH="${lib.makeBinPath [ pkgs.jq pkgs.yq-go pkgs.curl ]}:$PATH"
    if [[ -x "${aiStackDir}/bin/ai-stack" ]]; then
      "${aiStackDir}/bin/ai-stack" sync
    else
      echo "home-manager: missing ${aiStackDir}/bin/ai-stack" >&2
      exit 1
    fi
    mkdir -p "${config.home.homeDirectory}/.config/opencode" "${config.home.homeDirectory}/.config/claude"
    ln -sfn "${aiStackDir}/generated/opencode.json" "${config.home.homeDirectory}/.config/opencode/opencode.json"
    ln -sfn "${aiStackDir}/generated/claude-settings.json" "${config.home.homeDirectory}/.config/claude/settings.json"
  '';
}
