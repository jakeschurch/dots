{ ... }:
{
  services.microvm-host = {
    enable = true;
    network = {
      gateway = "192.168.100.1";
      subnet = "192.168.100.0/24";
      externalInterface = "enp5s0";
      # vxlan = {
      #   enable = true;
      #   local = "<apollo-LAN-IP>";   # e.g. the IP enp5s0 gets — fill in before deploying
      #   remotes = [
      #     "<new-host-LAN-IP>"        # add one entry per additional host
      #   ];
      # };
    };
  };

  services.k3s-cluster = {
    enable = true;
    token = "my-cluster-token-12345";
    vip = "192.168.100.100";

    embeddedRegistry = {
      enable = true;
      mirrors = [
        "docker.io"
        "registry.k8s.io"
      ];
    };

    argocd = {
      enable = true;
      targetRevision = "v1";
      path = "vmetal/apps";
    };

    network = {
      prefix = "192.168.100";
      firstServerIp = "192.168.100.10";
      gateway = "192.168.100.1";
      dns = "192.168.100.1";
    };

    sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1C4EE4sKPgzsmkDUwA3YojcAC0cL6HdFabWryqHlIZ" ];

    vms.k3s-server-1 = {
      role = "server";
      ip = "192.168.100.10";
      mac = "02:00:00:00:00:10";
      initial = true;
      vsockCid = 10;
      vcpu = 4;
      mem = 8192;
    };

    vms.k3s-server-2 = {
      role = "server";
      ip = "192.168.100.11";
      mac = "02:00:00:00:00:11";
      vsockCid = 11;
      vcpu = 4;
      mem = 8192;
    };

    vms.k3s-server-3 = {
      role = "server";
      ip = "192.168.100.12";
      mac = "02:00:00:00:00:12";
      vsockCid = 12;
      vcpu = 4;
      mem = 8192;
    };

    vms.k3s-worker-1 = {
      role = "agent";
      ip = "192.168.100.20";
      mac = "02:00:00:00:00:20";
      vsockCid = 20;
      vcpu = 8;
      mem = 24000;
      disk = 100;
      dataDisk = 250;
      # Storage node: Garage + Longhorn prefer this node (soft affinity, no taint so general workloads also land here)
      extraLabels = [ "workload=storage" ];
    };

    vms.k3s-worker-2 = {
      role = "agent";
      ip = "192.168.100.21";
      mac = "02:00:00:00:00:21";
      vsockCid = 21;
      vcpu = 16;
      mem = 60000;
      disk = 100;
      dataDisk = 250;
      # Inference node: GPU passthrough, hard-isolated via taint (vLLM requires this label)
      extraLabels = [ "workload=inference" ];
      extraTaints = [ "workload=inference:NoSchedule" ];
      passthroughDevices = [
        {
          bus = "pci";
          path = "0000:0c:00.0";
        }
      ];
    };
  };

  # NAT for microVM external network access
  networking.nat.externalInterface = "enp5s0";

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
