# Non-secret cluster facts shared across NixOS hosts. Plain data — no `config`,
# NOT a NixOS module — imported directly by
# configurations/nixos/{apollo,artemis}/cluster.nix.
#
# The k3s join token is a SECRET and is deliberately NOT here — it still lives
# inline in each host's cluster.nix (blocked on vmetal gaining a `tokenFile`
# option; see the TODO there).
rec {
  # API-server VIP, advertised as a /32 via BGP so external clients get
  # ECMP/failover across hosts instead of a static pin to one host.
  vip = "192.168.100.100";

  # apollo's initial etcd server — the cluster bootstrap address. Same value on
  # every host (non-primary hosts join against it), so it lives here once.
  firstServerIp = "192.168.100.10";

  # Every node routes to both host subnets.
  clusterNodeCidrs = [
    "192.168.100.0/24"
    "192.168.101.0/24"
  ];

  # BGP ASNs shared by both hosts (the route-reflector peer + cilium peer), and
  # the upstream UDM peer the VIP /32 is advertised to (2026-06-24).
  bgp = {
    peerAsn = 64513;
    ciliumPeerAsn = 64514;
    upstreamPeers = [
      {
        address = "10.10.5.1";
        asn = 64511;
      }
    ];
  };

  # Per-host identity registry. CROSS-REFERENCED: each host's BGP `peers` list
  # names the OTHER host by lanIp + asn, and `noMasqueradeCidrs` / vxlan point at
  # the peer's subnet / lanIp — so any drift here silently breaks the iBGP
  # session between the two hosts. Single source of truth.
  hosts = {
    apollo = {
      lanIp = "10.10.5.7";
      asn = 64512;
      nic = "enp5s0";
      subnet = "192.168.100.0/24";
      prefix = "192.168.100";
      gateway = "192.168.100.1";
      dns = "192.168.100.1";
    };
    artemis = {
      lanIp = "10.10.5.110";
      asn = 64520;
      nic = "bond0";
      subnet = "192.168.101.0/24";
      prefix = "192.168.101";
      gateway = "192.168.101.1";
      dns = "192.168.101.1";
    };
  };

  # k3s node SSH access key (identical on every host).
  sshKeys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIP1C4EE4sKPgzsmkDUwA3YojcAC0cL6HdFabWryqHlIZ" ];

  # Embedded-registry mirror set (identical on every host).
  registryMirrors = [
    "docker.io"
    "registry.k8s.io"
    "registry.jakeschurch.com"
  ];

  # Cilium LB-VIP endpoint set — {ip, name} per server, emitted as the Endpoints
  # nodeName for eTP=Local locality. Full 5-server list declared on both hosts.
  lbVipServers = [
    {
      ip = "192.168.100.10";
      name = "k3s-server-1";
    }
    {
      ip = "192.168.100.11";
      name = "k3s-server-2";
    }
    {
      ip = "192.168.100.12";
      name = "k3s-server-3";
    }
    {
      ip = "192.168.101.13";
      name = "k3s-server-4";
    }
    {
      ip = "192.168.101.14";
      name = "k3s-server-5";
    }
  ];
}
