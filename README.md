# Cartografia — Ielmo Marinho

Mapa 3D interativo da rede do território de Ielmo Marinho-RN, feito para a atividade A3 "Cuidado em Rede / Atenção Psicossocial".

- Site: https://cartografia.rudyson.com.br
- Conteúdo: `site/index.html` (arquivo único; os pontos ficam nas listas `LOCAIS` e `SEM_LOCAL`)
- Dados do mapa © colaboradores do OpenStreetMap

## Como funciona em produção

Um container Caddy (`docker-compose.prod.yml`) atrás do Traefik da VM. `site/` e `caddy/` são
montados como volumes, então não há build: o `git pull` já publica o site e o `deploy.sh` só
recarrega o Caddy.

Todo push na `main` passa pelo CI (`.github/workflows/ci-cd.yml`: compose, Caddyfile,
shellcheck e o site respondendo com os cabeçalhos) e, se passar, o Actions entra na VM por SSH
e roda `scripts/deploy.sh <commit>`.

## Primeira vez na VM

```bash
sudo mkdir -p /opt/projetos/cartografia
sudo chown deploy:deploy /opt/projetos/cartografia
sudo -u deploy git clone git@github.com:lucasRudyson/cartografia.git /opt/projetos/cartografia
sudo -u deploy bash /opt/projetos/cartografia/scripts/deploy.sh
```

## Ligar o deploy automático

1. **Chave do Actions** (na sua máquina):
   ```bash
   ssh-keygen -t ed25519 -N "" -C "github-actions-cartografia" -f cartografia-deploy
   ```
   Acrescente `cartografia-deploy.pub` ao `~/.ssh/authorized_keys` do usuário `deploy` na VM
   (precisa estar no grupo `docker`). Recomendado: prenda a chave ao script, para que ela não
   abra um shell:
   ```
   command="bash /opt/projetos/cartografia/scripts/deploy.sh",restrict ssh-ed25519 AAAA... github-actions-cartografia
   ```
2. **Segredos no GitHub** (repo › Settings › Secrets and variables › Actions):

   | Segredo | Valor |
   |---|---|
   | `VPS_HOST` | IP ou domínio da VM |
   | `VPS_USER` | `deploy` |
   | `VPS_SSH_KEY` | conteúdo de `cartografia-deploy` (a chave privada inteira) |
   | `VPS_KNOWN_HOSTS` | a saída de `ssh-keyscan -p <porta> <VPS_HOST>` |
   | `VPS_PORT` | só se o SSH não for a 22 |

   Depois, apague o `cartografia-deploy` da sua máquina.
3. **Ligar:** aba *Variables*, crie `DEPLOY_ATIVO` = `true`. Sem ela o deploy é pulado (o CI
   roda normalmente).

## Deploy à mão

```bash
sudo -u deploy bash /opt/projetos/cartografia/scripts/deploy.sh          # git pull + reload
sudo -u deploy bash /opt/projetos/cartografia/scripts/deploy.sh <commit> # avança até o commit
sudo -u deploy bash /opt/projetos/cartografia/scripts/deploy.sh logs     # últimos logs
```
