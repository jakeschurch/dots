{ pkgs, ... }:
let
  # The single NVMe that holds everything latency-sensitive on artemis: the
  # etcd voters' disks (k3s-server-4 on ext4 /var/lib/microvms = nvme0n1p4,
  # k3s-server-5/6 on btrfs /microvm-disks = nvme0n1p5), the worker-4/5/6
  # rancher/kata/mayastor-pool images, swap and the host root. Resolved by
  # by-id (same path as disko-config.nix) so a future second NVMe cannot shift
  # the nvme0n1 name under us. The cold-wN worker disks are LVs on the WD HDD
  # (coldvg) and are not governed by this.
  nvmeById = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_2TB_S6B0NL0TC03605L_1";
  majMin = ''$(cat "/sys/class/block/$(basename "$(readlink -f ${nvmeById})")/dev")'';
in
{
  # Weekly scrub of "/" reads the whole ~1.2 TiB btrfs partition, which carries
  # /microvm-disks (k3s-server-5/6 etcd). It used to fire Mon 00:00, 42 min
  # before fstrim.timer (Mon ~00:42), with no rate limit: an unthrottled
  # full-device read on the disk the etcd voters fsync against. apollo's 990 PRO
  # also hung its controller twice under scrub (apollo/storage.nix), so keep the
  # scrub but move it to a quiet window away from fstrim and cap it with
  # btrfs's own per-device scrub_speed_max (the limit option); IOSchedulingClass
  # =idle is ignored under kyber, so the limit is the knob that actually bounds
  # it. Saturday 04:30 local: weekend pre-dawn, outside the weekday CI window
  # and two days clear of fstrim.
  services.btrfs.autoScrub = {
    enable = true;
    interval = "Sat *-*-* 04:30:00";
    limit = "200M";
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

  # blk-iocost on the 980 PRO so cgroup IOWeight (k3s-server-* = 1000, see
  # cluster.nix) is honoured under kyber. Without a controller, io.weight is a
  # no-op and the etcd voters queue behind worker/mayastor IO on equal terms.
  #
  # Baseline, 2026-11-10 07:20 EST, 10s /sys/block/nvme0n1/stat delta, iocost
  # off, all 6 VMs up:
  #   reads   446/s   13.9 MB/s  avg await 0.39 ms
  #   writes 4122/s  138   MB/s  avg await 3.83 ms
  #   flushes  56/s              avg 19.3 ms   <- etcd fsync pain
  #   discards 69/s   8 MB/s     avg 12.6 ms   (btrfs discard=async)
  #   io_ticks 100% ("%util" on NVMe = >=1 IO in flight, not bandwidth
  #   saturation: we are latency-bound, nowhere near the device's MB/s).
  #
  # Linear model, derived from Samsung's 980 PRO 2TB datasheet and derated
  # (the datasheet figures are QD32/T16 burst numbers into the SLC
  # TurboWrite cache; ours is a mixed, fsync-heavy, mostly-full drive):
  #   rbps      7000 MB/s seq read   x0.85 -> 6.0 GB/s
  #   rseqiops  6.0 GB/s / 4K = 1.46M is not reachable at 4K; ~half -> 700k
  #   rrandiops 1000k 4K rand read   x0.6  -> 600k
  #   wbps      5100 MB/s seq write is SLC-only; the 2TB drops to ~2000 MB/s
  #             once TurboWrite is exhausted -> 2.0 GB/s (sustained figure)
  #   wseqiops  2.0 GB/s / 4K ~= 488k        -> 450k
  #   wrandiops 1000k burst; steady-state 4K rand write is a small fraction
  #             -> 200k
  # Lower-than-real coefficients only make iocost consider the device busy
  # sooner; the QoS loop below rescales vrate from observed latency either way.
  #
  # QoS (conservative): p95 read 5 ms, p95 write 10 ms. apollo uses 5 ms for
  # writes, but artemis already averages 3.8 ms write await at baseline, so a
  # 5 ms p95 would be missed continuously and pin vrate to min. min=25 floor:
  # at the floor the write budget is 25% of the model (500 MB/s, 50k rand IOPS),
  # and today's demand costs roughly 9% of the model (4.1k/200k IOPS + 138/2000
  # MB/s), i.e. ~36% of the floor budget: a saturated device can never squeeze
  # the VMs below their current throughput; weights decide who absorbs bursts
  # above it (mayastor rebuilds, kata/nix builds on workers). iocost does not
  # cost flushes, so the 19 ms flush latency is only helped indirectly (less
  # worker data queued ahead of each etcd fsync).
  #
  # Re-deriving the model (needs an otherwise idle device: stop all
  # microvm@ units first): run linux tools/cgroup/iocost_coef_gen.py
  # --testdev /dev/nvme0n1 (fio + python3) and paste its io.cost.model line
  # here. After enabling, watch vrate and per-cgroup usage/debt with
  # tools/cgroup/iocost_monitor.py nvme0n1 (drgn); if vrate sits at min for
  # long stretches, raise wlat or lower min before touching the model.
  #
  # Off-switch:
  #   systemctl stop iocost-nvme          (ExecStop below writes enable=0)
  # or by hand, without systemd:
  #   echo "$(cat /sys/block/nvme0n1/dev) enable=0" > /sys/fs/cgroup/io.cost.qos
  # (259:0 at the time of writing). Re-enable: systemctl start iocost-nvme.
  # Permanently: delete this unit (or wantedBy = [ ]) and switch.
  systemd.services.iocost-nvme = {
    description = "Enable blk-iocost QoS on the 980 PRO (nvme0n1)";
    wantedBy = [ "multi-user.target" ];
    after = [ "local-fs.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "iocost-nvme" ''
        set -eu
        dev=${majMin}
        echo "$dev ctrl=user model=linear \
          rbps=6000000000 rseqiops=700000 rrandiops=600000 \
          wbps=2000000000 wseqiops=450000 wrandiops=200000" \
          > /sys/fs/cgroup/io.cost.model
        echo "$dev enable=1 ctrl=user rpct=95.00 rlat=5000 wpct=95.00 wlat=10000 min=25.00 max=10000.00" \
          > /sys/fs/cgroup/io.cost.qos
      '';
      ExecStop = pkgs.writeShellScript "iocost-nvme-off" ''
        echo "${majMin} enable=0" > /sys/fs/cgroup/io.cost.qos
      '';
    };
  };
}
