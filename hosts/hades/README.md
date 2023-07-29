# `hades` - General purpose "homelab" server

This NixOS configuration manages my main home server, named `hades`.

The bulk of this deployment uses [Arion](https://github.com/hercules-ci/arion) to manage Docker-Compose-like container stacks.
These containers are configured in the [`lab/`](./lab/) directory.

## Hardware

This lab is currently running on a Dell PowerEdge R610 with a PERC H200 re-flashed for JBOD/software raid.

## Features

- [Traefik](https://traefik.io/traefik/) reverse proxy with HTTPS wildcard certificates using Let's Encrypt. ([config](./lab/infra/traefik.nix))
- [Keycloak](https://www.keycloak.org/) IAM with [OAuth2-Proxy](https://oauth2-proxy.github.io/oauth2-proxy/) configured for [Traefik ForwardAuth](https://doc.traefik.io/traefik/middlewares/http/forwardauth/) ([config](./lab/auth))
- [Homepage](https://gethomepage.dev/) dashboard ([config](./lab/homepage.nix))
- [Jellyfin](https://jellyfin.org/) media server with additional media management services ([config](./lab/media))

## TODO

- [ ] OpenLDAP <-> Keycloak
- [ ] [ErsatzTV](https://ersatztv.org/) custom "live channel" streams
- [ ] Observability (metrics, data, alerting) with [Grafana](https://grafana.com/)
- [ ] Replace the hardware with my Dell PowerEdge R720XD (currently performing duty as a backup server)
- [ ] Backup job
