![Build](https://github.com/thalesflores/aldo-shoes/actions/workflows/build.yml/badge.svg)

```
 █████╗ ██╗     ██████╗  ██████╗     ███████╗██╗  ██╗ ██████╗ ███████╗███████╗
██╔══██╗██║     ██╔══██╗██╔═══██╗    ██╔════╝██║  ██║██╔═══██╗██╔════╝██╔════╝
███████║██║     ██║  ██║██║   ██║    ███████╗███████║██║   ██║█████╗  ███████╗
██╔══██║██║     ██║  ██║██║   ██║    ╚════██║██╔══██║██║   ██║██╔══╝  ╚════██║
██║  ██║███████╗██████╔╝╚██████╔╝    ███████║██║  ██║╚██████╔╝███████╗███████║
╚═╝  ╚═╝╚══════╝╚═════╝  ╚═════╝     ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝
```

A simple inventory manager

## Requirements

Docker

## Getting Started

The project was designed to have simple usage and bootstrap in new machines. This means you will have
almost no effort to configure and start your "server".

To start the (not real) "production" server, run `$ make run`. The command creates the `docker compose` containing
all necessary containers.

For check if everything is running correctly, call `$ curl -X GET localhost:3000/stores/" | jq`

## Calling the API

The system has an API that you could interact with for:

- list the stores
- show one specific store
- transfer an inventory between stores
- list inventory transfer suggestions to a specific store

To learn how to use the API, visit the http://localhost:3000/api-docs

## Development

To use the development env, you can run `$ make run_dev`, and you will have a brand new development environment
to play with. Your container will be directly connected to your directory, so every code change will automatically reflect on the container.

To discovery, all possible actions, run `$ make help`.

## Known issues

- There is no CORS configuration. For a real environment, it must be configured
- We are using a simple `.env` file for all envs; this is not secure at all
- Not all Rubocop rules are respected or properly ignored
- We are not locking the `inventory` row when transferring it between stores. In cases of high volume, we could have a
  race condition

## Possible next steps

- Add a serializer for unifying the reponse format
- Add a WebSocket with a notification whenever a store has a low/high inventory
- Add GraphQL endpoint, enabling multiple ways for consuming the app data
- Increase code coverage
- Add dashboard UI for an easy way to follow up on the stores' inventories
- Configure the project to be deployed and configure an auto-deploy
