let
  nikita_voyager = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyxV6Jx53eFSFkl8z1yHOe0GYuG5SNCgf0s3nfJg/Ih";

  users = [ nikita_voyager ];

  voyager = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOey5VJAfPHiW0fdhempd8XosrbGN2BCHIrJcxeCz5MK";
  hades = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC3o2QhkX8GaEoQBZwdEMtvUFZOsQmapl8eXhFwSB+F";

  systems = [ voyager hades ];
in
{
  "homepage.env.age".publicKeys = [ nikita_voyager voyager hades ];
  "openldap.rootpw.age".publicKeys = [ nikita_voyager voyager hades ];
  "traefik.env.age".publicKeys = [ nikita_voyager voyager hades ];
  "transmission-ovpn.env.age".publicKeys = [ nikita_voyager voyager hades ];
  "keycloak.env.age".publicKeys = [ nikita_voyager voyager hades ];
  "postgres.env.age".publicKeys = [ nikita_voyager voyager hades ];
}