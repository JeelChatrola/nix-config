---
name: security-review
description: Review code for security vulnerabilities, hardcoded secrets, injection risks, and unsafe patterns. Use when asked for a security review, audit, or when touching auth, networking, deserialization, or user input handling.
---

# Security Review

## Scan Order

Check for these categories in priority order:

### 1. Secrets & Credentials
- Hardcoded API keys, tokens, passwords in source
- Secrets in config files checked into git (check `.gitignore`)
- Private keys, certificates in the repo
- `.env` files without `.gitignore` entry
- Docker images with embedded secrets

### 2. Injection
- SQL injection (unparameterized queries)
- Command injection (`os.system()`, `subprocess.run(shell=True)`, `system()`)
- Path traversal (user input in file paths without sanitization)
- YAML/pickle deserialization of untrusted data (`yaml.load()` without `SafeLoader`)
- Template injection (f-strings or `.format()` with user input in templates)

### 3. Dependency Risks
- Known vulnerable versions (check against advisories if possible)
- Unpinned dependencies (any version could be pulled)
- Typosquatting risk on unusual package names
- Dependencies with no maintenance (last commit >2 years)

### 4. Network & Auth
- HTTP instead of HTTPS for sensitive endpoints
- Missing authentication on endpoints
- Overly permissive CORS
- Exposed debug endpoints in production configs
- Default credentials in config files

### 5. C++ Specific
- Buffer overflows (`strcpy`, `sprintf`, raw arrays with user-controlled size)
- Use-after-free patterns
- Integer overflow in size calculations
- Missing bounds checks on array access
- `reinterpret_cast` on network/file data without validation

### 6. Python Specific
- `eval()` / `exec()` with any dynamic input
- `pickle.load()` on untrusted data
- `subprocess` with `shell=True`
- Logging sensitive data (passwords, tokens)
- Debug mode in production (`DEBUG=True`, `FLASK_DEBUG=1`)

## Output Format

```markdown
## Critical (fix immediately)
- What, where (file:line), why it's dangerous, fix

## High (fix before merge)
- What, where, why, fix

## Medium (fix when practical)
- What, where, why, fix

## Recommendations
- Preventive measures (pre-commit hooks, CI checks, etc.)
```

## Rules

- Concrete findings only. No generic advice like "consider using a WAF."
- Include file path and line number for every finding.
- Provide the minimal fix, not a rewrite.
- If no issues found, say so -- don't invent problems.
