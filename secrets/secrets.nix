let
  nikita_voyager = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyxV6Jx53eFSFkl8z1yHOe0GYuG5SNCgf0s3nfJg/Ih";

  users = [ nikita_voyager ];

  voyager = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOey5VJAfPHiW0fdhempd8XosrbGN2BCHIrJcxeCz5MK";
  olympus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC3o2QhkX8GaEoQBZwdEMtvUFZOsQmapl8eXhFwSB+F";
  hades = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAhbHrBfTCi5TiyBVjhzjRJ4HzN5+JgY6rgvoaKP0ec";

  systems = [ voyager olympus hades ];
in
{
  "homepage.env.age".publicKeys = [ nikita_voyager voyager hades ];
  "openldap.rootpw.age".publicKeys = [ nikita_voyager voyager hades ];
  "traefik.env.age".publicKeys = [ nikita_voyager voyager hades ];
  "transmission-ovpn.env.age".publicKeys = [ nikita_voyager voyager hades ];
  "keycloak.env.age".publicKeys = [ nikita_voyager voyager hades ];
  "postgres.env.age".publicKeys = [ nikita_voyager voyager hades ];
  "oauth2-proxy.env.age".publicKeys = [ nikita_voyager voyager hades ];
  "watchtower.env.age".publicKeys = [ nikita_voyager voyager hades ];
  "freshrss.env.age".publicKeys = [ nikita_voyager voyager hades ];
}