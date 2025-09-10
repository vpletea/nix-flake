{ config, nixos-username, ...}:
let
  nixos-username = "valentin";
  nixos-hostname = "f2";
  domain = builtins.readFile /home/${nixos-username}/secrets/domain;
  cloudflareEmail = builtins.readFile /home/${nixos-username}/secrets/cloudflare_email;
  cloudflareToken = builtins.readFile /home/${nixos-username}/secrets/cloudflare_token;
in
{
  # Setting up internal network needed by traefik
  systemd.services.set-traefik-network = with config.virtualisation.oci-containers; {
    serviceConfig.Type = "oneshot";
    wantedBy = [ "docker-traefik.service" ];
    script = ''
      /run/current-system/sw/bin/docker network create -d bridge internal || true
      '';
  };

  # Dockerized services setup
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = true;
  virtualisation.docker.autoPrune.enable = true;
  virtualisation.docker.autoPrune.dates =  "weekly";
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    traefik = {
      autoStart = true;
      image = "docker.io/traefik:v3.4.0";
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Bucharest";
        CLOUDFLARE_EMAIL = "${cloudflareEmail}";
        CLOUDFLARE_DNS_API_TOKEN = "${cloudflareToken}";
      };
      cmd = [
        "--providers.docker=true"
        "--api.dashboard=true"
        "--api.insecure=true"
        "--serversTransport.insecureSkipVerify=true"
        # Set up LetsEncrypt
        "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
        "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare"
        "--certificatesresolvers.letsencrypt.acme.email=${cloudflareEmail}"
        "--certificatesresolvers.letsencrypt.acme.storage=/acme/acme.json"
        # Set up an insecure listener that redirects all traffic to TLS
        "--entrypoints.web.address=:80"
        "--entrypoints.web.http.redirections.entrypoint.to=websecure"
        "--entrypoints.web.http.redirections.entrypoint.scheme=https"
        "--entrypoints.websecure.address=:443"
        # Set up the TLS configuration for our websecure listener
        "--entrypoints.websecure.http.tls=true"
        "--entrypoints.websecure.http.tls.certResolver=letsencrypt"
        "--entrypoints.websecure.http.tls.domains[0].main=${domain}"
        "--entrypoints.websecure.http.tls.domains[0].sans=*.${domain}"
      ];
      ports = [ "80:80" "443:443" ];
      volumes = [
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "/home/valentin/apps/traefik:/acme"
      ];
      extraOptions = [
        "--network=internal"
        "-l" "traefik.enable=true"
        "-l" "traefik.http.routers.traefik.rule=Host(`traefik.${domain}`)"
        "-l" "traefik.http.routers.traefik.entrypoints=websecure"
        "-l" "traefik.http.routers.traefik.tls.certresolver=letsencrypt"
        "-l" "traefik.http.routers.traefik.service=api@internal"
        "-l" "traefik.http.services.traefik.loadbalancer.server.port=8080"
        "-l" "traefik.docker.network=internal"
      ];
    };
    jellyfin = {
      image = "lscr.io/linuxserver/jellyfin:latest";
      autoStart = true;
      ports = [ "8096" ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Bucharest";
      };
      volumes = [
        "/home/valentin/apps/jellyfin:/config"
        "/home/valentin/downloads:/downloads"
      ];
      extraOptions = [
        "--network=internal"
        "--device=/dev/dri/renderD128:/dev/dri/renderD128"
        "--device=/dev/dri/card0:/dev/dri/card0"
        "-l" "traefik.http.routers.jellyfin.rule=Host(`jellyfin.${domain}`)"
        "-l" "traefik.http.services.jellyfin.loadbalancer.server.port=8096"
      ];
    };
    vaultwarden = {
      image = "docker.io/vaultwarden/server:latest";
      autoStart = true;
      ports = [ "80" ];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Bucharest";
        SIGNUPS_ALLOWED = "true";
        ADMIN_TOKEN = "$$argon2id$v=19$m=65540,t=3,p=4$5x78o7XwzRF+n88kWuyuZKolbKvlSJ1SDmNsrFlPOHU$o1Wo41pC11ZYdaNYHgC79og4cDJoji56qlISi495wBo";
        WEBSOCKET_ENABLED = "true";
      };
      volumes = [
        "/home/valentin/apps/vaultwarden:/data"
      ];
      extraOptions = [
        "--network=internal"
        "-l" "traefik.http.routers.vaultwarden.rule=Host(`vaultwarden.${domain}`)"
        "-l" "traefik.http.services.vaultwarden.loadbalancer.server.port=80"
      ];
    };
    qbittorrent = {
      image = "lscr.io/linuxserver/qbittorrent:latest";
      autoStart = true;
      ports = [ "8080" "45000:45000/tcp"];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Bucharest";
      };
      volumes = [
        "/home/valentin/apps/qbittorrent:/config"
        "/home/valentin/downloads:/downloads"
      ];
      extraOptions = [
        "--network=internal"
        "-l" "traefik.http.routers.qbittorrent.rule=Host(`qbittorrent.${domain}`)"
        "-l" "traefik.http.services.qbittorrent.loadbalancer.server.port=8080"
      ];
    };
    unifi = {
      image = "jacobalberty/unifi:v9.1.120";
      autoStart = true;
      ports = [ "8443" "8080:8080/tcp"];
      environment = {
        PUID = "1000";
        PGID = "1000";
        TZ = "Europe/Bucharest";
      };
      volumes = [
        "/home/valentin/apps/unifi:/unifi"
      ];
      extraOptions = [
        "--network=internal"
        "-l" "traefik.http.routers.unifi.rule=Host(`unifi.${domain}`)"
        "-l" "traefik.http.services.unifi.loadbalancer.server.port=8443"
        "-l" "traefik.http.services.unifi.loadbalancer.server.scheme=https"
      ];
    };
  };
}
