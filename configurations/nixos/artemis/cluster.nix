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
        peers = [ { lanIp = apolloLanIp; asn = 64512; } ];
        lanInterface = artemisNic;
        noMasqueradeCidrs = [ "192.168.100.0/24" "10.42.0.0/16" ];
        extraPeerSubnets = [ "192.168.100.0/24" ];
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
      extraHostPeers = [ { address = "192.168.100.1"; asn = 64512; } ];
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
      vcpu = 4;
      mem = 8192;
    };

    vms.k3s-server-5 = {
      role = "server";
      ip = "192.168.101.14";
      mac = "02:00:00:00:00:14";
      vsockCid = 14;
      readinessVsockPort = 9014;
      vcpu = 4;
      mem = 8192;
    };

    vms.k3s-worker-4 = {
      role = "agent";
      ip = "192.168.101.23";
      mac = "02:00:00:00:00:23";
      vsockCid = 23;
      readinessVsockPort = 9023;
      vcpu = 12;
      mem = 32768;
      disk = 200;
      extraLabels = [ "openebs.io/engine=mayastor" ];
      extraModules = [ { boot.kernelParams = [ "hugepages=1024" ]; } ];
    };

    vms.k3s-worker-5 = {
      role = "agent";
      ip = "192.168.101.24";
      mac = "02:00:00:00:00:24";
      vsockCid = 24;
      readinessVsockPort = 9024;
      vcpu = 12;
      mem = 32768;
      disk = 200;
      extraLabels = [ "openebs.io/engine=mayastor" ];
      extraModules = [ { boot.kernelParams = [ "hugepages=1024" ]; } ];
    };
  };

  microvm.vms = {
    k3s-worker-4.restartPriority = 0;
    k3s-worker-5.restartPriority = 0;
    k3s-server-4 = {
      restartPriority = 1;
      restartTimeout = 300;
    };
    k3s-server-5 = {
      restartPriority = 1;
      restartTimeout = 300;
    };
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
