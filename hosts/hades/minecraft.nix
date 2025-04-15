{ config, ... }: {
  virtualisation.oci-containers.containers.minecraft-server = {
    image = "itzg/minecraft-server";
    environment = {
      UID = "1000";
      GID = toString config.users.groups.${config.homelab.media.group}.gid;
      TZ = config.time.timeZone;
      EULA = "TRUE";
      MAX_MEMORY = "4G";
      DIFFICULTY = "hard";
      SPAWN_PROTECTION = "0";
      ENABLE_RCON = "true";
      RCON_PASSWORD = "zapzap123";
      LEVEL_TYPE = "minecraft:amplified";
    };
    ports = [ "25565:25565" "25575:25575" ];
    volumes = [ "/home/nikita/minecraft:/data" ];
  };
}
