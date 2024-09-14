#!/usr/bin/env bash
# vim:filetype=bash

if [ "$(uname -s)" = "Darwin" ]; then
	sudo rm /Library/LaunchDaemons/org.nixos.activate-system.plist
	sudo launchctl bootout system/org.nixos.activate-system
	/nix/nix-installer uninstall
	sudo rm /etc/ssl/certs/*
fi

/nix/nix-installer uninstall
