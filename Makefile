# Local development

create:
	(cd ./infrastructure/dev && docker compose run web rake db:create)

migrate:
	(cd ./infrastructure/dev && docker compose run web rake db:migrate)

dev_up:
	docker compose -f ./infrastructure/dev/docker-compose.yml up

dev_down:
	docker-compose -f ./infrastructure/dev/docker-compose.yml down

dev_build:
	docker-compose -f ./infrastructure/dev/docker-compose.yml build --no-cache
