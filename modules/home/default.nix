{ config, ... }:
{
  imports = [ ./all ];

  home.username = config.me.username;
}
