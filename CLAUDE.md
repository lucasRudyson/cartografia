# Cartografia — Ielmo Marinho

Site estático de um arquivo só: `site/index.html` (mapa 3D com three.js; os pontos ficam nas
listas `LOCAIS` e `SEM_LOCAL`, a malha do OpenStreetMap no objeto `OSM`). Sem build, sem backend.

## Produção

- VM com Traefik (rede `traefik-public`, certresolver `le`), igual a myenglish, poup e resenha.
- `docker-compose.prod.yml`: um Caddy que serve `site/` e lê `caddy/Caddyfile`, os dois como
  volumes de pasta. Um `git pull` já publica o site; Caddyfile novo entra com `caddy reload`.
- Deploy: `scripts/deploy.sh <commit>` (chamado pelo GitHub Actions na `main`) ou
  `scripts/deploy.sh logs`.

## Convenções

- Textos, comentários e commits em português.
- Recurso externo novo (CDN, fonte, tiles) precisa entrar na CSP do `caddy/Caddyfile`, senão o
  navegador bloqueia. O CI só confere que o cabeçalho existe, não que a página funciona.
