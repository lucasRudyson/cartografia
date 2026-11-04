#!/usr/bin/env bash
# Deploy NA VM. Chamado pelo GitHub Actions por SSH (ver README.md), ou à mão:
#   /opt/projetos/cartografia/scripts/deploy.sh [commit|logs]
# Com o commit (o que passou no CI), só avança até ele; sem, faz git pull; "logs" mostra os
# logs (o Actions usa quando o site não responde depois do deploy).
# Se a chave do Actions estiver presa a este script (command= no authorized_keys), o argumento
# é a última palavra do SSH_ORIGINAL_COMMAND. Só aceita um hash de commit ou "logs".
# Tudo dentro de main(): o git pull pode reescrever este arquivo enquanto ele roda, e o bash
# lê o script aos poucos. Assim ele já leu tudo antes de começar.
set -euo pipefail

main() {
	cd "$(dirname "$0")/.."
	local compose=(docker compose -p cartografia-prod -f docker-compose.prod.yml)

	if [ "${1:-}" = "logs" ]; then
		"${compose[@]}" logs --tail 80 web
		return
	fi
	if [ -n "${1:-}" ] && ! [[ "$1" =~ ^[0-9a-f]{7,40}$ ]]; then
		echo "Argumento inválido: use um hash de commit ou \"logs\"." >&2
		exit 2
	fi

	if [ -n "${1:-}" ]; then
		git fetch --quiet origin
		# Commit mais antigo que o já implantado (pushes fora de ordem): não faz nada.
		git merge --ff-only --quiet "$1"
	else
		git pull --ff-only --quiet
	fi
	echo "Implantando $(git log -1 --format='%h %s')"

	# site/ e caddy/ são volumes: o git já publicou o site. O up só recria o container se o
	# compose mudou; o reload aplica um Caddyfile novo sem derrubar nada (se o Caddyfile for
	# inválido, o reload falha e o Caddy segue com a configuração antiga).
	"${compose[@]}" up -d --remove-orphans

	# Container recém-criado pode ainda não ter o admin do Caddy no ar: tenta até 1 min.
	for _ in $(seq 1 12); do
		if "${compose[@]}" exec -T web caddy reload --config /etc/caddy/Caddyfile 2>/dev/null &&
			"${compose[@]}" exec -T web wget -q --spider http://127.0.0.1/ 2>/dev/null; then
			echo "No ar: https://cartografia.rudyson.com.br"
			return 0
		fi
		sleep 5
	done
	echo "Em 1 min o Caddy não recarregou (Caddyfile inválido?) ou o site não respondeu. Logs:" >&2
	"${compose[@]}" logs --tail 80 web >&2
	return 1
}

if [ $# -eq 0 ] && [ -n "${SSH_ORIGINAL_COMMAND:-}" ]; then
	set -- "${SSH_ORIGINAL_COMMAND##* }"
fi
main "$@"
exit
