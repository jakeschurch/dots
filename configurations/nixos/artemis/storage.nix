{ ... }:
{
  services.btrfs.autoScrub = {
    enable = true;
    interval = "weekly";
    fileSystems = [ "/" ];
  };

  services.btrbk.instances.btrbk = {
    onCalendar = "hourly";
    settings = {
      snapshot_preserve_min = "2h";
      snapshot_preserve = "24h 7d 4w 3m";
      target_preserve_min = "no";
      target_preserve = "48h 14d 6w 6m";

      volume."/" = {
        snapshot_dir = "/.snapshots";
        target = "/snapshots-archive";
        subvolume = {
          "/home/jake" = { };
        };
      };
    };
  };
}
