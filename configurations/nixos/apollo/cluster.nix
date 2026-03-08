{ ... }:
{
  environment.variables.VK_ICD_FILENAMES = "/run/opengl-driver/share/vulkan/icd.d/nvidia_icd.x86_64.json";

  services.microvm-host = {
    enable = true;
    network = {
      gateway = "192.168.100.1";
      subnet = "192.168.100.0/24";
      externalInterface = "enp5s0";
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

    cilium.enable = true;
    argocd = {
      enable = true;
      targetRevision = "v1";
      path = "vmetal/manifests";
    };

    network = {
      prefix = "192.168.100";
      firstServerIp = "192.168.100.10";
      gateway = "192.168.100.1";
      dns = "192.168.100.1";
    };

    sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1C4EE4sKPgzsmkDUwA3YojcAC0cL6HdFabWryqHlIZ" ];

    servers.k3s-server-1 = {
      ip = "192.168.100.10";
      mac = "02:00:00:00:00:10";
      initial = true;
      vsockCid = 10;
    };

    servers.k3s-server-2 = {
      ip = "192.168.100.11";
      mac = "02:00:00:00:00:11";
      vsockCid = 11;
    };

    servers.k3s-server-3 = {
      ip = "192.168.100.12";
      mac = "02:00:00:00:00:12";
      vsockCid = 12;
    };

    workers.k3s-worker-1 = {
      ip = "192.168.100.20";
      mac = "02:00:00:00:00:20";
      vsockCid = 20;
      mem = 16384;
      dataDisk = 250;
    };

    workers.k3s-worker-2 = {
      ip = "192.168.100.21";
      mac = "02:00:00:00:00:21";
      vsockCid = 21;
      mem = 16384;
      dataDisk = 250;
    };

    workers.k3s-worker-3 = {
      ip = "192.168.100.22";
      mac = "02:00:00:00:00:22";
      vsockCid = 22;
      mem = 16384;
      dataDisk = 250;
    };

    workers.k3s-worker-4 = {
      ip = "192.168.100.23";
      mac = "02:00:00:00:00:24";
      vsockCid = 23;
      mem = 20000;
      disk = 60;
      dataDisk = 250;
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
