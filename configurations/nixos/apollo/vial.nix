{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    vial
    via
  ];

  # Vial/VIA keyboard configurators: allow non-root access to the HID device.
  # https://get.vial.today/manual/linux-udev.html
  services.udev.extraRules = ''
    # Vial-firmware boards (matched by magic serial signature)
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{serial}=="*vial:f64c2b3c*", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
    # Keebio Quefrency Rev. 4 (VIA firmware, VID:PID cb10:4257)
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="cb10", ATTRS{idProduct}=="4257", MODE="0660", GROUP="users", TAG+="uaccess", TAG+="udev-acl"
  '';
}
