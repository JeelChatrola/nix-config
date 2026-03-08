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

  aiderWrapper = pkgs.writeShellScriptBin "aider" ''
    export OLLAMA_HOST="''${OLLAMA_HOST:-http://127.0.0.1:11434}"
    exec ${pkgs.uv}/bin/uv tool run --from aider-chat aider "$@"
  '';
in
{
  home.packages = [
    claudeWrapper
    opencodeWrapper
    aiderWrapper
  ];

  # Keep MCP and provider settings in the repo, activate them on the host.
  home.file.".config/claude/settings.json".source = ../../ai-stack/mcp/claude-settings.json;
  home.file.".config/opencode/mcp.toml".source = ../../ai-stack/mcp/opencode.toml;
  home.file.".config/opencode/opencode.json".source = ../../ai-stack/mcp/opencode.json;
}
