rec {
  # Note that sk- keys cannot be used with Agenix
  nikita_yubikey_1 = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIgGx2KcXwXTYHMh5DOLzTq7YIBu0GngrYX9BYiCRnOvAAAABHNzaDo=";
  nikita_voyager = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyxV6Jx53eFSFkl8z1yHOe0GYuG5SNCgf0s3nfJg/Ih";
  nikita_cochrane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK//BoiABsGP0THb282KhGU0hLqUM2biGCK6qRcbZcMB";
  
  trusted_users = [ nikita_voyager ];

  # Host keys used for decrypting agenix secrets
  voyager = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOey5VJAfPHiW0fdhempd8XosrbGN2BCHIrJcxeCz5MK";
  olympus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC3o2QhkX8GaEoQBZwdEMtvUFZOsQmapl8eXhFwSB+F";
  hades = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAhbHrBfTCi5TiyBVjhzjRJ4HzN5+JgY6rgvoaKP0ec";
  dionysus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJutM0WGtPHMkziyE9g2nHbxuL1YrJu1y8ysvG0TtAeA";
  cochrane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDG/GfRCnWYx7xhD0k8qxpzOYfVnhlsGiNIkk/TwHx2Q";

  systems = [ voyager olympus hades dionysus cochrane ];
}
