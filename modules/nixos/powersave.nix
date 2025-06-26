{ pkgs, ... }:

# let
#   ppd_wait = pkgs.writeShellScriptBin "ppd_wait" ''
#     SERVICE="power-profiles-daemon.service"
#     RETRY=20
#     PROFILE=$1
#
#     for ((i=0; i<RETRY; i++)); do
#         if systemctl is-active --quiet "$SERVICE"; then
#             ${pkgs.power-profiles-daemon}/bin/powerprofilesctl set $PROFILE
#             echo "Apply profile $PROFILE"
#             exit 0
#         else
#             echo "Wait service $SERVICE... ($i)"
#             sleep 2
#         fi
#     done
#
#     echo "$SERVICE service don't start on time."
#     exit 1
#   '';
# in
{
  # systemd.services.ppd_wait_eco = {
  #   enable = true;
  #   description = "Wait power profile daemon for eco mode";
  #   after = [ "network.target" ];
  #   wantedBy = [ "default.target" ];
  #   serviceConfig = {
  #       Type = "simple";
  #       ExecStart = ''${ppd_wait}/bin/ppd_wait power-saver'';
  #   };
  # };

  # systemd.services.ppd_wait_balanced = {
  #   enable = true;
  #   description = "Wait power profile daemon for balanced mode";
  #   after = [ "network.target" ];
  #   wantedBy = [ "default.target" ];
  #   serviceConfig = {
  #       Type = "simple";
  #       ExecStart = ''${ppd_wait}/bin/ppd_wait balanced'';
  #   };
  # };

  # services.udev.extraRules =
  #     ''
  #     # Plug charger
  #     SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",ENV{SYSTEMD_WANTS}="power-profiles-daemon.service",RUN+="${pkgs.systemd}/bin/systemctl start ppd_wait_balanced.service"

  #     # Unplug charger
  #     SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",ENV{SYSTEMD_WANTS}="power-profiles-daemon.service",RUN+="${pkgs.systemd}/bin/systemctl start ppd_wait_eco.service"
  #     '';
  #
  services.udev.extraRules = ''
    # Unplug
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="0",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set power-saver"

    # Plug
    SUBSYSTEM=="power_supply",ENV{POWER_SUPPLY_ONLINE}=="1",RUN+="${pkgs.power-profiles-daemon}/bin/powerprofilesctl set balanced"
  '';
}
