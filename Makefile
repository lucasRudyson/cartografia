COMPOSE = docker compose -p cartografia-prod -f docker-compose.prod.yml
URL = https://cartografia.rudyson.com.br

.PHONY: start stop reload status logs

## Sobe o site
start:
	$(COMPOSE) up -d

## Para o site
stop:
	$(COMPOSE) down

## Puxa a versão nova do GitHub e garante que o container está no ar
reload:
	git pull --ff-only
	$(COMPOSE) up -d
	@curl -s -o /dev/null -w "HTTP %{http_code}\n" $(URL) || true

status:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f --tail=50
