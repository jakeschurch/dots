{ ... }:
let
  clusterData = import ../../../modules/data/cluster.nix;
  self = clusterData.hosts.apollo;
  peer = clusterData.hosts.artemis;
in
{
  services.microvm-host = {
    enable = true;
    network = {
      gateway = self.gateway;
      subnet = self.subnet;
      externalInterface = self.nic;
      vip = clusterData.vip;
      bgp = {
        enable = true;
        asn = self.asn;
        localAsn = self.asn;
        peerAsn = clusterData.bgp.peerAsn;
        peerSubnet = self.subnet;
        ciliumPeerAsn = clusterData.bgp.ciliumPeerAsn;
        ciliumPeerSubnet = self.subnet;
        peers = [
          {
            lanIp = peer.lanIp;
            asn = peer.asn;
          }
        ];
        lanInterface = self.nic;
        noMasqueradeCidrs = [
          peer.subnet
          "10.42.0.0/16"
        ];
        extraPeerSubnets = [ peer.subnet ];
        # Advertise the API VIP /32 to the UDM (AS64511) so external clients get
        # ECMP/failover across hosts instead of a static pin to apollo. (2026-06-24)
        upstreamPeers = clusterData.bgp.upstreamPeers;
      };
      vxlan = {
        enable = false;
        local = self.lanIp;
        remotes = [ peer.lanIp ];
      };
    };
  };

  services.k3s-cluster = {
    enable = true;
    primary = true;
    # TODO(secrets): move to SOPS once vmetal services.k3s-cluster gains a
    # tokenFile option — current module only accepts an inline string.
    token = "my-cluster-token-12345";
    vip = clusterData.vip;
    bgp = {
      enable = true;
      asn = self.asn;
      peerAsn = clusterData.bgp.peerAsn;
      extraHostPeers = [
        {
          address = peer.gateway;
          asn = peer.asn;
        }
      ];
    };

    embeddedRegistry = {
      enable = true;
      mirrors = clusterData.registryMirrors;
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
      servers = clusterData.lbVipServers;
    };

    network = {
      prefix = self.prefix;
      firstServerIp = clusterData.firstServerIp;
      gateway = self.gateway;
      dns = self.dns;
      nodeCidr = self.subnet;
      clusterNodeCidrs = clusterData.clusterNodeCidrs;
      hostId = "apollo";
    };

    sshKeys = clusterData.sshKeys;

    vms.k3s-server-1 = {
      role = "server";
      ip = "192.168.100.10";
      mac = "02:00:00:00:00:10";
      initial = true;
      vsockCid = 10;
      readinessVsockPort = 9010;
      vcpu = 4; # bumped from 2: etcd raft consensus was hitting CPU scheduling jitter at 2 vCPU (2026-05-04)
      mem = 12288; # 8→12Gi (2026-07-10): 8Gi starved the etcd voters (~122% of allocatable, 33k+ Event bloat) → apiserver lease writes timed out → ~2-min leader-election storms + registry 520s. Matches servers 4/5.
    };

    vms.k3s-server-2 = {
      role = "server";
      ip = "192.168.100.11";
      mac = "02:00:00:00:00:11";
      vsockCid = 11;
      readinessVsockPort = 9011;
      vcpu = 3; # 4→3 (2026-06-28): 1 core freed for host; etcd floor is 2, 3 has headroom
      mem = 12288; # 8→12Gi (2026-07-10): 8Gi starved the etcd voters (~122% of allocatable, 33k+ Event bloat) → apiserver lease writes timed out → ~2-min leader-election storms + registry 520s. Matches servers 4/5.
    };

    vms.k3s-server-3 = {
      role = "server";
      ip = "192.168.100.12";
      mac = "02:00:00:00:00:12";
      vsockCid = 12;
      readinessVsockPort = 9012;
      vcpu = 3; # 4→3 (2026-06-28): 1 core freed for host; etcd floor is 2, 3 has headroom
      mem = 12288; # 8→12Gi (2026-07-10): 8Gi starved the etcd voters (~122% of allocatable, 33k+ Event bloat) → apiserver lease writes timed out → ~2-min leader-election storms + registry 520s. Matches servers 4/5.
    };

    # 2026-07-14 rebuild: 3 workers → 2 BEEFY workers, mayastor on RAW BLOCK
    # only. img-on-btrfs pools are gone — the shared btrfs transaction between
    # mayastor writes and desktop fsyncs was the typing-freeze root cause. Each
    # worker passes ONE raw device through (virtio serial mayastor-sda,
    # autoCreate=false, SPDK owns/formats it): w1 = whole 860 EVO
    # (apollovg/mayastor-w1), w2 = nvme tail LV (nvmevg/mayastor-w2, see
    # disko-config.nix). repl=2 spans exactly these two nodes. VM system imgs
    # live on the dedicated xfs partition, also off btrfs.
    vms.k3s-worker-1 = {
      role = "agent";
      ip = "192.168.100.20";
      mac = "02:00:00:00:00:20";
      vsockCid = 20;
      readinessVsockPort = 9020;
      vcpu = 8; # 2-worker layout: 8 vcpu each (was 6/4/6 across 3 workers)
      mem = 28000;
      disk = 100;
      extraLabels = [
        "workload=storage"
        "openebs.io/engine=mayastor"
      ];
      mayastorBlockDevice = "/dev/apollovg/mayastor-w1";
      podStoreGiB = 64; # nix-csi pod store (foundrybox-b20x.4)
      nixStoreOverlayGiB = 32; # CSI churn moves to pod store; delete old img on recreate
      extraModules = [ { boot.kernelParams = [ "hugepages=1024" ]; } ];
    };

    vms.k3s-worker-2 = {
      role = "agent";
      ip = "192.168.100.21";
      mac = "02:00:00:00:00:21";
      vsockCid = 21;
      readinessVsockPort = 9021;
      vcpu = 8; # 2-worker layout: 8 vcpu each (was 6/4/6 across 3 workers)
      mem = 28000;
      disk = 100;
      dataDisk = 250;
      extraLabels = [
        "workload=storage"
        "openebs.io/engine=mayastor"
      ];
      mayastorBlockDevice = "/dev/nvmevg/mayastor-w2";
      podStoreGiB = 64; # nix-csi pod store (foundrybox-b20x.4)
      nixStoreOverlayGiB = 32; # CSI churn moves to pod store; delete old img on recreate
      extraModules = [ { boot.kernelParams = [ "hugepages=1024" ]; } ];
      # GPU passthrough (vLLM) parked during 2-worker rebuild; re-add via
      # passthroughDevices = [{ bus = "pci"; path = "0000:0c:00.0"; }];
    };
  };

  # Tier-based rolling restarts enforced via systemd dependencies.
  # Workers restart first (drain workloads), non-initial servers next,
  # initial server (etcd bootstrap) last. Readiness gate is the guest's
  # microvm-readiness-signal.service connecting via vsock (port auto-wired
  # from services.k3s-cluster.vms.<name>.readinessVsockPort).
  microvm.vms = {
    # Rolling restart: DISTINCT priorities so a host rebuild restarts VMs one
    # tier at a time, each gated on the prior tier's vsock readiness
    # (microvm-readiness-signal → kubelet healthz). Same priority = parallel,
    # which bounced all workers at once (kyverno admission outage 2026-06-17),
    # and previously had server-2/server-3 sharing priority 1 — restarting two
    # etcd members simultaneously. Workers first, then etcd servers strictly
    # sequentially so the 5-member quorum never loses two at once.
    k3s-worker-1 = {
      restartPriority = 0;
      restartTimeout = 300;
    };
    k3s-worker-2 = {
      restartPriority = 1;
      restartTimeout = 300;
    };
    k3s-server-2 = {
      restartPriority = 2;
      restartTimeout = 300;
    };
    k3s-server-3 = {
      restartPriority = 3;
      restartTimeout = 300;
    };
    k3s-server-1 = {
      restartPriority = 4;
      restartTimeout = 300;
    };
  };

  # CPU affinity pinning (foundrybox-oh4q.4). Confine each guest's
  # cloud-hypervisor process to a DISJOINT set of WHOLE physical cores so the
  # host scheduler stops migrating vCPU threads across guests and no two guests
  # share an SMT pair. apollo has 16 physical cores; the SMT sibling of core N
  # is thread N+16.
  systemd.services = {
    "microvm@k3s-worker-1".serviceConfig.CPUAffinity = "0-3 16-19";
    "microvm@k3s-worker-2".serviceConfig.CPUAffinity = "4-7 20-23";
    "microvm@k3s-server-1".serviceConfig.CPUAffinity = "8-9 24-25";
    "microvm@k3s-server-2".serviceConfig.CPUAffinity = "10-11 26-27";
    "microvm@k3s-server-3".serviceConfig.CPUAffinity = "12-13 28-29";
  };

  # NAT for microVM external network access
  networking.nat.externalInterface = self.nic;

  networking.nameservers = [
    "1.1.1.1#one.one.one.one"
    "1.0.0.1#one.one.one.one"
  ];

  services.resolved = {
    enable = true;
    settings = {
      Resolve = {
        MulticastDNS = "no"; # because of avahi
        DNSSEC = "allow-downgrade";
        Domains = [ "~." ];
        FallbackDNS = [
          "1.1.1.1#one.one.one.one"
          "1.0.0.1#one.one.one.one"
        ];
        DNSOverTLS = "opportunistic";
      };
    };
  };
}
