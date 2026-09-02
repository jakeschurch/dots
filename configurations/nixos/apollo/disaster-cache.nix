# Disaster substituter (foundrybox-zff6): host-level static nix binary cache
# serving /var/lib/foundry-disaster-cache over HTTP on the LAN IP. Sits
# OUTSIDE the cluster storage blast radius (garage/nix-cache), so nix-csi
# builders/nodes can still substitute critical closures (platform, operator,
# gateway, shim, nix-cache) when in-cluster S3 loses quorum — the 2026-09-02
# artemis-return outage forced 30-40min source rebuilds for want of this.
#
# Seed/refresh (from a foundrybox checkout):
#   nix build .#platform .#operator .#gateway .#shim .#nix-cache
#   nix copy --to file:///var/lib/foundry-disaster-cache ./result*
# NARs keep their existing signatures, so cluster nix.conf trust needs no
# change. Consumed via node.cacheURIs / controller.nixCache.urls in
# homelab vmetal/lib/apps/nix-csi-go.nix (http://10.10.5.7:8082).
{ ... }:
{
  systemd.tmpfiles.rules = [
    "d /var/lib/foundry-disaster-cache 0755 jake users -"
  ];

  services.nginx = {
    enable = true;
    virtualHosts."foundry-disaster-cache" = {
      listen = [
        {
          addr = "0.0.0.0";
          port = 8082;
        }
      ];
      root = "/var/lib/foundry-disaster-cache";
      extraConfig = "autoindex off;";
    };
  };
}
