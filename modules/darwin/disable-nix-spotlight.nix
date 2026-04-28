{ ... }:
{
  system.activationScripts.disableNixSpotlight.text = ''
    touch /nix/.metadata_never_index
    chmod 000 /nix/.metadata_never_index
  '';
}
