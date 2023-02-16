.DEFAULT_GOAL: help

help: ## Prints available commands
	awk 'BEGIN {FS = ":.*##"; printf "Usage: make \033[36m<target>\033[0m\n"} /^[.a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

run_dev: dev_build dev_db_create dev_db_migrate dev_up ## Starts the dev compose complete, including image building and DB setup

# Local development
dev_db_create: ## Creates DB in development env
	(cd ./infrastructure/dev && docker compose run --rm web rake db:create)

dev_db_setup: ## Setups DB in development env
	(cd ./infrastructure/dev && docker compose run --rm web rake db:setup)

dev_db_migrate: ## Runs DB migrations in development env
	(cd ./infrastructure/dev && docker compose run --rm web rake db:migrate)

dev_up: ## Starts compose to the development env
	docker compose -f ./infrastructure/dev/docker-compose.yml up

dev_down: ## Stops compose to the development env
	docker-compose -f ./infrastructure/dev/docker-compose.yml down

dev_build: ## Build project image for development env
	docker-compose -f ./infrastructure/dev/docker-compose.yml build --no-cache

test: ## Runs test in the dev container
	(cd ./infrastructure/dev && docker compose run --rm web bundle exec rspec)

console: ## Opens a bash console on the aldo-shoes container
	(cd ./infrastructure/dev && docker compose run --rm web /bin/bash)

generate_docs: ## Creates/Updates API docs
	SWAGGER_DRY_RUN=0 RAILS_ENV=test rails rswag

# Prod env
run: build db_create db_migrate up ## Starts the "production" compose complete, including image building and DB setup

up: ## Starts the "production" compose
	docker-compose up

down: ## Stops the "production" compose
	docker-compose down

build: ## Builds project image for "production"
	docker compose build

db_create: ## Creates the DB for "production"
	docker-compose run --rm web rake db:create

db_migrate: ## Creates the DB for "production"
	docker-compose run --rm web rake db:migrate

