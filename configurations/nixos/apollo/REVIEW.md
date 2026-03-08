# Apollo Config Review Notes

## Security

- **Hardcoded k3s token** (`default.nix:40`): `token = "my-cluster-token-12345"` is a weak
  placeholder committed to git. Replace with a SOPS secret.

- **Shared password hash for root and jake** (`configuration.nix:151,169`): Both accounts use the
  same `hashedPassword` value, and it's checked into git. sha-512 crypt hashes in public repos are
  brute-forceable. Move to `hashedPasswordFile` via SOPS.

- **Firewall disabled** (`configuration.nix:112`): `networking.firewall.enable = false` with no
  replacement ruleset. The `openFirewall` options in the steam module are currently meaningless.

- **Auto-login via greetd** (`default.nix:541`): The tuigreet prompt is commented out; greetd runs
  `uwsm start hyprland-uwsm.desktop` directly as `jake` with no authentication. Intentional for
  `test-autologin` branch — ensure this is reverted before merging.

## Reliability

- **ncps is the only substituter** (`configuration.nix:216`): `lib.mkForce` removes
  `cache.nixos.org` as a fallback. If ncps is down (first boot, crash), all substitutions fail and
  everything builds from source. Add a fallback substituter or remove `mkForce`.

- **`vulkan-validation-layers` in `extraPackages`** (`configuration.nix:64`): Validation layers are
  a debug tool. They add overhead to all Vulkan apps and can cause issues with some games. Remove
  for production.

## Minor

- **`mesa-demos` duplicated**: installed in both `configuration.nix:237` and `steam.nix:33`.
