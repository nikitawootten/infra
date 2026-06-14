rec {
  # Note that sk- keys cannot be used with agenix
  nikita_yubikey_1 = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIIgGx2KcXwXTYHMh5DOLzTq7YIBu0GngrYX9BYiCRnOvAAAABHNzaDo=";
  nikita_voyager = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINyxV6Jx53eFSFkl8z1yHOe0GYuG5SNCgf0s3nfJg/Ih";
  nikita_cochrane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDWBe6veTROKSNV/iieADl5/8tQ0un/VNN5UTaBDkvp6";
  nikita_defiant = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF2IY2vuIWsarBVZWul8XuSxiS39hAyIg1rNXtpAxjqX";

  # Key used by laptops' nix-daemon for remote builds on hades (private half in secrets/nix-builder-key.age)
  nixremote = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAT0KPrvhLnqyfdMKOy2V+odFG+abCXmMAm0C2w+129n nixremote-builder";

  # Signing key for the harmonia binary cache on hades (private half in secrets/harmonia-signing-key.age)
  hades_cache = "cache.hades.arpa.nikita.computer-1:nh/nrUoDcjJQLNRQv/v8HC1z4FRYGYW+i9iVu4TeBSA=";

  # Trusted users for decrypting agenix secrets
  trusted_users = [ nikita_voyager ];

  # Host keys used for decrypting agenix secrets
  voyager = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOey5VJAfPHiW0fdhempd8XosrbGN2BCHIrJcxeCz5MK";
  olympus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGC3o2QhkX8GaEoQBZwdEMtvUFZOsQmapl8eXhFwSB+F";
  hades = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICAhbHrBfTCi5TiyBVjhzjRJ4HzN5+JgY6rgvoaKP0ec";
  dionysus = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJutM0WGtPHMkziyE9g2nHbxuL1YrJu1y8ysvG0TtAeA";
  cochrane = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOH+EQFMwbqttKiVOkiMSranPH22J4XZwTtAhWIJB74D";
  hermes = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEujTbZxPrwrEaeW343jqs1CtaNPWOB8cUaQppNNPRkS";

  systems = [
    voyager
    olympus
    hades
    dionysus
    cochrane
    hermes
  ];

  # Keys used for ssh access
  authorized_keys = [
    nikita_yubikey_1
    nikita_voyager
  ];
}
