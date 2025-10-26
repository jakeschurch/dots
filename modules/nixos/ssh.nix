{
  flake,
  ...
}:
let
  inherit (flake) config;
in
{
  programs.mosh.enable = true;

  users.users.${config.me.username}.authorizedKeys.keys = [
    ""
  ];

  services = {
    endlessh.enable = true;
    sshd.enable = true;

    openssh = {
      enable = true;
      ports = [ 22222 ];
      settings = {
        PasswordAuthentication = false;
        UseDns = true;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = [ config.me.username ];
      };
    };
  };
}
