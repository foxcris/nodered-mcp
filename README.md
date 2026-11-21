# nodered-mcp (Docker image)

Docker-Image für den MCP-Server [`ljmerza/nodered-mcp`](https://github.com/ljmerza/nodered-mcp)
(MCP-Server für Node-RED: Flows lesen/ändern/deployen via Admin API).

- **Image:** `ghcr.io/<github-owner>/nodered-mcp:latest` (plus `:sha`-Tags)
- **CI:** `.github/workflows/build-mcp-nodered.yml` — wöchentlich + on push, baut mit
  gha-Cache, **Trivy-Scan** (CRITICAL/HIGH → fail, kein Push), push nach ghcr.io
- **Dependabot:** wöchentliche PRs für Base-Image, pip-Deps, Actions
- **Deploy:** im ansible-setup-Repo (home2.yaml, Tag `setup-mcp-nodered`) läuft der
  Container; watchtower aktualisiert ihn automatisch per Digest.

## Setup

1. Repo auf GitHub anlegen (public oder mit Packages-Token) und pushen:
   `git remote add origin git@github.com:<owner>/nodered-mcp.git && git push -u origin main`
2. ghcr-Package `nodered-mcp` auf **public** stellen (Repo → Packages → nodered-mcp),
   oder auf dem Docker-Host `docker login ghcr.io`.
3. Image-Quelle im ansible-setup anpassieren: `nodered_mcp_image` in home2.yaml
   (default `ghcr.io/foxcris/nodered-mcp:latest`).

## Lokal testen

```bash
docker build -t nodered-mcp:local .
docker run --rm -e NODE_RED_URL=http://localhost:1880 -e NODE_RED_TOKEN=... -p 8000:8000 nodered-mcp:local
```

## Security / Trivy-Gate

Der CI-Scan (Trivy, CRITICAL/HIGH mit Fix → fail) läuft gegen das gebaute Image.
Bei einem Fail wird der JSON-Report auf den Branch `ci/trivy-report` gepusht und als
Workflow-Artefakt (`trivy-report`) bereitgestellt — Details siehe Run-Seite.

**`.trivyignore` (begründete Ausnahmen):** `nodered-mcp` nutzt von fastmcp nur die
`FastMCP`-Serverklasse mit 8 eigenen Tools (kein `OpenAPIProvider`, kein `OAuthProxy`).
Daher sind ignoriert:

- `CVE-2026-32871` (CRITICAL): SSRF/Path-Traversal im fastmcp-**OpenAPIProvider** —
  Code-Pfad wird von nodered-mcp nicht verwendet.
- `CVE-2026-27124` (HIGH): Confused Deputy im fastmcp-**OAuthProxy** (GitHub OAuth) —
  wird nicht verwendet (Auth gegen Node-RED per Bearer-Token).

Der Fix beider CVEs ist fastmcp 3.2.0; upstream `nodered-mcp 2.0.1` erlaubt nur `fastmcp<3`.
Sobald upstream fastmcp ≥3.2 erlaubt (Dependabot bumpt nodered-mcp), wird der
`.trivyignore` entfernt.
