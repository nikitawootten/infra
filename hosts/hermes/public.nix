{
  self,
  secrets,
  config,
  ...
}:
{
  imports = [ self.nixosModules.homelab ];

  homelab.domain = "cloud.nikita.computer";

  age.secrets.cloudflare-dns.file = secrets.traefik;
  homelab.acme.email = "me@nikita.computer";
  homelab.acme.dnsProvider = "cloudflare";
  homelab.acme.credentialsFile = config.age.secrets.cloudflare-dns.path;

  # Disable "homelab" defaults
  homelab.samba.enable = false;
  homelab.homepage.enable = false;

  services.nginx = {
    virtualHosts = {
      "cloud.nikita.computer" = {
        enableACME = true;
        forceSSL = true;
        locations."/" = {
          return = "200 '<html><body>It works</body></html>'";
          extraConfig = ''
            default_type text/html;
          '';
        };
      };
      # WIP
      # "media.cloud.nikita.computer" = {
      #   forceSSL = true;
      #   useACMEHost = "cloud.nikita.computer";
      #   locations."/" = {
      #     proxyPass = "https://hades";
      #     proxyWebsockets = true;
      #     # recommendedProxySettings = true;

      #     extraConfig = ''
      #       proxy_headers_hash_max_size 1024;
      #       proxy_headers_hash_bucket_size 128;

      #       proxy_set_header Host jellyfin.hades.arpa.nikita.computer;
      #       proxy_set_header X-Real-IP $remote_addr;
      #       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #       proxy_set_header X-Forwarded-Proto $scheme;
      #       proxy_set_header User-Agent $http_user_agent;
      #       proxy_set_header Referer $http_referer;

      #       proxy_ssl_server_name on;
      #       proxy_ssl_name hades.arpa.nikita.computer;
      #       proxy_ssl_verify_depth 2;
      #       proxy_ssl_trusted_certificate /etc/ssl/certs/ca-certificates.crt;
      #     '';
      #   };
      # };
    };
  };

}
