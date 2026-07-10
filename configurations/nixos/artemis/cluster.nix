{ ... }:
let
  artemisLanIp = "10.10.5.110";
  apolloLanIp = "10.10.5.7";
  artemisNic = "bond0";
in
{
  services.microvm-host = {
    enable = true;
    network = {
      gateway = "192.168.101.1";
      subnet = "192.168.101.0/24";
      externalInterface = artemisNic;
      vip = "192.168.100.100";
      bgp = {
        enable = true;
        asn = 64520;
        localAsn = 64520;
        peerAsn = 64513;
        peerSubnet = "192.168.101.0/24";
        ciliumPeerAsn = 64514;
        ciliumPeerSubnet = "192.168.101.0/24";
        peers = [{ lanIp = apolloLanIp; asn = 64512; }];
        lanInterface = artemisNic;
        noMasqueradeCidrs = [ "192.168.100.0/24" "10.42.0.0/16" ];
        extraPeerSubnets = [ "192.168.100.0/24" ];
        # Advertise the API VIP /32 to the UDM (AS64511) so external clients get
        # ECMP/failover across hosts instead of a static pin to apollo. (2026-06-24)
        upstreamPeers = [{ address = "10.10.5.1"; asn = 64511; }];
      };
      vxlan = {
        enable = false;
        local = artemisLanIp;
        remotes = [ apolloLanIp ];
      };
    };
  };

  services.k3s-cluster = {
    enable = true;
    # Not the bootstrap host — no cluster-init, no gateway/dns assertions
    primary = false;
    token = "my-cluster-token-12345";
    vip = "192.168.100.100";
    bgp = {
      enable = true;
      asn = 64520;
      peerAsn = 64513;
      extraHostPeers = [{ address = "192.168.100.1"; asn = 64512; }];
    };

    embeddedRegistry = {
      enable = true;
      mirrors = [
        "docker.io"
        "registry.k8s.io"
        "registry.jakeschurch.com"
      ];
    };

    argocd = {
      enable = true;
      targetRevision = "v1";
      path = "vmetal/apps";
    };

    cilium.hubble = {
      enable = false;
      ui = false;
    };

    cilium.bgp.enable = true;

    cilium.lbVip = {
      enable = true;
      # {ip, name} per server: name is emitted as the Endpoints nodeName so the
      # eTP=Local VIP Service can resolve endpoint locality (see k3s-node.nix).
      servers = [
        { ip = "192.168.100.10"; name = "k3s-server-1"; }
        { ip = "192.168.100.11"; name = "k3s-server-2"; }
        { ip = "192.168.100.12"; name = "k3s-server-3"; }
        { ip = "192.168.101.13"; name = "k3s-server-4"; }
        { ip = "192.168.101.14"; name = "k3s-server-5"; }
      ];
    };

    network = {
      prefix = "192.168.101";
      firstServerIp = "192.168.100.10"; # apollo's initial server — unchanged
      gateway = "192.168.101.1";
      dns = "192.168.101.1";
      nodeCidr = "192.168.101.0/24";
      clusterNodeCidrs = [ "192.168.100.0/24" "192.168.101.0/24" ];
      hostId = "artemis";
    };

    sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1C4EE4sKPgzsmkDUwA3YojcAC0cL6HdFabWryqHlIZ" ];

    # Non-initial server — expands etcd quorum from 3 → 5
    vms.k3s-server-4 = {
      role = "server";
      ip = "192.168.101.13";
      mac = "02:00:00:00:00:13";
      vsockCid = 13;
      readinessVsockPort = 9013;
      # 6 vCPU: 4 ran load ~9.5 (>2x oversubscribed) post-12G bump; host
      # has 128 cores, plenty of headroom.
      vcpu = 6;
      # 12G: 8G wedged repeatedly under the ~5G k3s server monolith +
      # workload (full thrash 2026-06-12/13 even after kube-reserved+zram).
      mem = 12288;
    };

    vms.k3s-server-5 = {
      role = "server";
      ip = "192.168.101.14";
      mac = "02:00:00:00:00:14";
      vsockCid = 14;
      readinessVsockPort = 9014;
      # 6 vCPU: 4 ran load ~9.5 (>2x oversubscribed) post-12G bump; host
      # has 128 cores, plenty of headroom.
      vcpu = 6;
      # 12G: 8G wedged repeatedly under the ~5G k3s server monolith +
      # workload (full thrash 2026-06-12/13 even after kube-reserved+zram).
      mem = 12288;
    };

    # =========================================================================
    # MOCK (foundrybox-6j1j): worker-4/5/6 become Garage storage nodes.
    #   - coldStorageDevice: LVM LV on the 8TB HDD (VG coldvg, one LV per worker)
    #     passed through as virtio-blk -> guest mounts /var/lib/rancher/openebs-cold ->
    #     openebs cold-hdd localpv-hostpath -> Garage cold DATA tier.
    #   - mayastorPoolGiB: small NVMe pool for the WARM metadata tier (Garage
    #     LMDB metadata must stay fast/reliable — worker-6 LMDB corruption
    #     2026-06-23 when it landed on the wrong disk). DiskPool CR per node
    #     added in vmetal openebs.nix (pool-worker-4/5/6).
    #   - NO workload=storage label: the nix-csi-go builder nodeAffinity requires
    #     `workload DoesNotExist` (builders run on mayastor nodes that are NOT
    #     storage-workload). Labeling these workers workload=storage left ZERO
    #     builder-eligible nodes -> builders Pending -> NixMounts unresolved ->
    #     cluster-wide ContainerCreating cascade (2026-07-10). Garage runs here
    #     fine without the label (mayastor engine label is enough). No taint
    #     either (these are also kata session hosts, foundrybox-51kk).
    # =========================================================================
    vms.k3s-worker-4 = {
      role = "agent";
      ip = "192.168.101.23";
      mac = "02:00:00:00:00:23";
      vsockCid = 23;
      readinessVsockPort = 9023;
      vcpu = 28;
      # 32G→28G (2026-07-10): 3×32G workers + 2×12G servers = 120G committed
      # on a 125G host left ~4G for kernel/page-cache/virtiofsd — any IO burst
      # (image pulls, nix builds) forced host reclaim, stalling etcd voters
      # 4/5 → recurring apiserver flaps. Workers ran ~28% used; 28G is ample.
      mem = 28672;
      disk = 200;
      mayastorPoolGiB = 16; # warm metadata pool (NVMe)
      coldStorageDevice = "/dev/coldvg/cold-w4"; # cold data (HDD LV)
      extraLabels = [ "openebs.io/engine=mayastor" ];
      extraModules = [{ boot.kernelParams = [ "hugepages=1024" ]; }];
    };

    vms.k3s-worker-5 = {
      role = "agent";
      ip = "192.168.101.24";
      mac = "02:00:00:00:00:24";
      vsockCid = 24;
      readinessVsockPort = 9024;
      vcpu = 28;
      # 32G→28G (2026-07-10): 3×32G workers + 2×12G servers = 120G committed
      # on a 125G host left ~4G for kernel/page-cache/virtiofsd — any IO burst
      # (image pulls, nix builds) forced host reclaim, stalling etcd voters
      # 4/5 → recurring apiserver flaps. Workers ran ~28% used; 28G is ample.
      mem = 28672;
      disk = 200;
      mayastorPoolGiB = 16; # warm metadata pool (NVMe)
      coldStorageDevice = "/dev/coldvg/cold-w5"; # cold data (HDD LV)
      extraLabels = [ "openebs.io/engine=mayastor" ];
      extraModules = [{ boot.kernelParams = [ "hugepages=1024" ]; }];
    };

    vms.k3s-worker-6 = {
      role = "agent";
      ip = "192.168.101.25";
      mac = "02:00:00:00:00:25";
      vsockCid = 25;
      readinessVsockPort = 9025;
      vcpu = 28;
      # 32G→28G (2026-07-10): 3×32G workers + 2×12G servers = 120G committed
      # on a 125G host left ~4G for kernel/page-cache/virtiofsd — any IO burst
      # (image pulls, nix builds) forced host reclaim, stalling etcd voters
      # 4/5 → recurring apiserver flaps. Workers ran ~28% used; 28G is ample.
      mem = 28672;
      disk = 200;
      mayastorPoolGiB = 16; # warm metadata pool (NVMe)
      coldStorageDevice = "/dev/coldvg/cold-w6"; # cold data (HDD LV)
      extraLabels = [ "openebs.io/engine=mayastor" ];
      extraModules = [{ boot.kernelParams = [ "hugepages=1024" ]; }];
    };
  };

  microvm.vms = {
    # Rolling restart: DISTINCT priorities so a host rebuild restarts VMs one
    # tier at a time, each gated on the prior tier's vsock readiness
    # (microvm-readiness-signal → kubelet healthz). Same priority = parallel,
    # which bounced all workers at once (kyverno admission outage 2026-06-17).
    # Workers first (no etcd impact), then etcd servers sequentially so the
    # 5-member quorum never loses two at once.
    k3s-worker-4 = {
      restartPriority = 0;
      restartTimeout = 300;
    };
    k3s-worker-5 = {
      restartPriority = 1;
      restartTimeout = 300;
    };
    k3s-worker-6 = {
      restartPriority = 2;
      restartTimeout = 300;
    };
    k3s-server-4 = {
      restartPriority = 3;
      restartTimeout = 300;
    };
    k3s-server-5 = {
      restartPriority = 4;
      restartTimeout = 300;
    };
  };

  # CPU affinity pinning (foundrybox-oh4q.4). Confine each guest's
  # cloud-hypervisor process to a DISJOINT set of WHOLE physical cores so the
  # host scheduler stops migrating vCPU threads across guests and no two guests
  # share an SMT pair. artemis has 64 physical cores; the SMT sibling of core N
  # is thread N+64. Sets are NPS2-boundary-aware (node0=cores 0-31,
  # node1=cores 32-63) so they upgrade cleanly if NPS2 is ever enabled.
  systemd.services = {
    "microvm@k3s-worker-4".serviceConfig.CPUAffinity = "0-13 64-77";
    "microvm@k3s-worker-5".serviceConfig.CPUAffinity = "14-27 78-91";
    "microvm@k3s-worker-6".serviceConfig.CPUAffinity = "32-45 96-109";
    "microvm@k3s-server-4".serviceConfig.CPUAffinity = "28-30 92-94";
    "microvm@k3s-server-5".serviceConfig.CPUAffinity = "46-48 110-112";
  };

  networking.nat.externalInterface = artemisNic;

  networking.nameservers = [
    "1.1.1.1#one.one.one.one"
    "1.0.0.1#one.one.one.one"
  ];

  services.resolved = {
    enable = true;
    settings.Resolve = {
      DNSSEC = "allow-downgrade";
      Domains = [ "~." ];
      FallbackDNS = [
        "1.1.1.1#one.one.one.one"
        "1.0.0.1#one.one.one.one"
      ];
      DNSOverTLS = "opportunistic";
    };
  };
}
