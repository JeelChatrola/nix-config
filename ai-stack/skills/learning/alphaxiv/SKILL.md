---
name: alphaxiv
description: Research papers via arXiv. Prefer the arxiv MCP tools when available; otherwise use arXiv's export API or public URLs.
---

# arXiv / alphaXiv research

## Prefer MCP (this machine)

When the **[arxiv-mcp-server](https://github.com/blazickjp/arxiv-mcp-server)** MCP is enabled, use its tools first:

- `search_papers` — query, categories, date range  
- `download_paper` / `read_paper` / `list_papers` — local cache under `~/.arxiv-mcp-server/papers` (or `ARXIV_STORAGE_PATH`)

One-time install:

```bash
uv tool install arxiv-mcp-server
```

## Without MCP: official arXiv API

```bash
curl -sS "https://export.arxiv.org/api/query?id_list=2401.12345&max_results=1"
```

Respect [arXiv API usage](https://info.arxiv.org/help/api/user-manual.html).

## URLs

| Site | URL |
|------|-----|
| arXiv abs | `https://arxiv.org/abs/<id>` |
| arXiv PDF | `https://arxiv.org/pdf/<id>.pdf` |
| alphaXiv (UI) | `https://www.alphaxiv.org/abs/<id>` |

## alphaXiv assistant API

Optional, account-based, undocumented HTTP API. If `ALPHAXIV_API_KEY` is set, you may call it per user instructions; never commit keys.
