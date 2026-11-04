# Cartografia — Ielmo Marinho

Mapa 3D interativo da rede do território de Ielmo Marinho-RN, feito para a atividade A3 "Cuidado em Rede / Atenção Psicossocial".

- Site: https://cartografia.rudyson.com.br
- Conteúdo: `site/index.html` (arquivo único; os pontos ficam nas listas `LOCAIS` e `SEM_LOCAL`)
- Dados do mapa © colaboradores do OpenStreetMap

## Primeira vez na VM

```bash
sudo mkdir -p /opt/projetos/cartografia
sudo chown deploy:deploy /opt/projetos/cartografia
sudo -u deploy git clone git@github.com:lucasRudyson/cartografia.git /opt/projetos/cartografia
cd /opt/projetos/cartografia
sudo make start
```

## Depois de cada mudança no GitHub

```bash
cd /opt/projetos/cartografia
sudo -u deploy git pull --ff-only && sudo make start
# ou, se o usuário tiver acesso ao git e ao docker: make reload
```

Como `site/` é montado como volume, o nginx serve o arquivo novo assim que o `git pull` termina; não precisa reiniciar o container.

## Comandos

| Comando       | O que faz                                   |
|---------------|---------------------------------------------|
| `make start`  | sobe o container                            |
| `make stop`   | derruba o container                         |
| `make reload` | `git pull` + garante o container no ar      |
| `make status` | mostra o container                          |
| `make logs`   | acompanha os logs do nginx                  |
