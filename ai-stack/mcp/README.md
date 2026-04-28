# MCP layout

OpenCode and Claude MCP JSON are generated at runtime from templates in [`../config/`](../config/) into [`../generated/`](../generated/) (gitignored). Do not rely on committed JSON in this folder for live agent config.

- Run `bin/ai-stack sync` or `scripts/render-mcp-templates.sh` after changing `config/*.template.json` or `stack-models.json`.
- MCPO output is `generated/mcpo-config.json`.
