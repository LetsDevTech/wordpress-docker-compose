


fix_exec:
	chmod +x ./configure.sh
	chmod +x ./configure-databases.sh
	chmod +x ./wp/setup-env.sh
	chmod +x ./sql/setup-env.sh
	chmod +x ./mautic/setup-env.sh

configure: fix_exec
	mkdir -p ./caddy
	./configure.sh

reset:
	docker compose down -v || echo ""
	mkdir -p ./caddy
	rm -rf ./sql/.env
	rm -rf ./wp/.env
	rm -rf ./mautic/.env
	rm -rf ./caddy/Caddyfile
	sudo rm -rf ./caddy/config
	sudo rm -rf ./caddy/data
	sudo rm -rf ./mautic/data
	sudo rm -rf ./sql/data
	sudo rm -rf ./wp/data

rebuild: 
	make reset
	make configure
