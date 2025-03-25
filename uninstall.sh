#!/usr/bin/env bash

if [ "$(uname -s)" == "Darwin" ]; then
  nix --extra-experimental-features "nix-command flakes" run nix-darwin#darwin-uninstaller

  sudo mv /etc/zshrc.backup-before-nix /etc/zshrc
  sudo mv /etc/bashrc.backup-before-nix /etc/bashrc
  sudo mv /etc/bash.bashrc.backup-before-nix /etc/bash.bashrc

  sudo launchctl unload /Library/LaunchDaemons/org.nixos.nix-daemon.plist
  sudo rm /Library/LaunchDaemons/org.nixos.nix-daemon.plist
  sudo launchctl unload /Library/LaunchDaemons/org.nixos.darwin-store.plist
  sudo rm /Library/LaunchDaemons/org.nixos.darwin-store.plist

  sudo dscl . -delete /Groups/nixbld
  nixbld_users=()
  mapfile -t nixbld_users < <(sudo dscl . -list /Users | grep _nixbld)
  for u in "${nixbld_users[@]}"; do sudo dscl . -delete /Users/"$u"; done

  sudo rm -rf /etc/nix /var/root/.nix-profile /var/root/.nix-defexpr /var/root/.nix-channels ~/.nix-profile ~/.nix-defexpr ~/.nix-channels

  sudo diskutil apfs deleteVolume /nix
else
  sudo systemctl stop nix-daemon.service
  sudo systemctl disable nix-daemon.socket nix-daemon.service
  sudo systemctl daemon-reload

  sudo rm -rf /etc/nix /etc/profile.d/nix.sh /etc/tmpfiles.d/nix-daemon.conf /nix ~root/.nix-channels ~root/.nix-defexpr ~root/.nix-profile ~root/.cache/nix

  nixbld_userids=()
  mapfile -t nixbld_userids < <(seq 1 32)

  for i in "${nixbld_userids[@]}"; do
    sudo userdel nixbld"$i"
  done
  sudo groupdel nixbld
fi
