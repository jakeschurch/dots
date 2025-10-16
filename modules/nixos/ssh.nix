{
  flake,
  ...
}:
let
  inherit (flake) config;
in
{
  programs.mosh.enable = true;

  services = {
    endlessh.enable = true;
    sshd.enable = true;
    openssh = {
      enable = true;
      ports = [ 22222 ];
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ config.me.username ];
      };
    };
  };
}
