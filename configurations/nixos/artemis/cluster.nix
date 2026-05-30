{ ... }:
let
  # TODO: fill in real IPs once artemis hardware is provisioned
  artemisLanIp = "TODO_ARTEMIS_LAN_IP"; # e.g. "10.20.0.6"
  apolloLanIp = "TODO_APOLLO_LAN_IP"; # e.g. "10.20.0.5"
  artemisNic = "TODO_NIC"; # e.g. "enp3s0" — check with `ip link`
in
{
  services.microvm-host = {
    enable = true;
    network = {
      gateway = "192.168.100.1";
      subnet = "192.168.100.0/24";
      externalInterface = artemisNic;
      vip = "192.168.100.100";
      bgp = {
        enable = true;
        asn = 64512;
        peerAsn = 64513;
        peerSubnet = "192.168.100.0/24";
      };
      vxlan = {
        enable = true;
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
      asn = 64512;
      peerAsn = 64513;
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

    network = {
      prefix = "192.168.100";
      firstServerIp = "192.168.100.10"; # apollo's initial server — unchanged
      gateway = "192.168.100.1";
      dns = "192.168.100.1";
    };

    sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1C4EE4sKPgzsmkDUwA3YojcAC0cL6HdFabWryqHlIZ" ];

    # Non-initial server — expands etcd quorum from 3 → 5
    vms.k3s-server-4 = {
      role = "server";
      ip = "192.168.100.13";
      mac = "02:00:00:00:00:13";
      vsockCid = 13;
      readinessVsockPort = 9013;
      vcpu = 4;
      mem = 8192;
    };

    vms.k3s-server-5 = {
      role = "server";
      ip = "192.168.100.14";
      mac = "02:00:00:00:00:14";
      vsockCid = 14;
      readinessVsockPort = 9014;
      vcpu = 4;
      mem = 8192;
    };

    # TODO: size workers to actual artemis hardware
    vms.k3s-worker-4 = {
      role = "agent";
      ip = "192.168.100.23";
      mac = "02:00:00:00:00:23";
      vsockCid = 23;
      readinessVsockPort = 9023;
      vcpu = 6;
      mem = 24000;
      disk = 100;
    };

    vms.k3s-worker-5 = {
      role = "agent";
      ip = "192.168.100.24";
      mac = "02:00:00:00:00:24";
      vsockCid = 24;
      readinessVsockPort = 9024;
      vcpu = 6;
      mem = 24000;
      disk = 100;
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
