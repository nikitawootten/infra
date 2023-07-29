{ pkgs, ...}:
{
  virtualisation.arion.projects.lab.settings.services.traefik = {
    image.command = [
      "${pkgs.traefik}/bin/traefik"
      "--api.insecure=true"
      "--providers.docker=true"
      "--providers.docker.exposedbydefault=false"
      "--entrypoints.web.address=:80"
    ];
    service = {
      container_name = "traefik";
      stop_signal = "SIGINT";
      ports = [
        "80:80"
        "8080:8080"
      ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
      ];
      useHostStore = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    80
    443
    8080 # Traefik management port
  ];
}