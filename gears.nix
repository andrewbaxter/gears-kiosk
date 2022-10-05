{ config, modulesPath, pkgs, lib, ... }:
let
  joinl = (list: lib.lists.foldr (a: b: a + "\n" + b) "" list);
in
{
  config = {
    nixpkgs.localSystem.system = "x86_64-linux";

    users = {
      users = {
        kiosk = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = [ "input" "video" "audio" "tty" ];
        };
        root = {
          initialPassword = "x";
        };
      };
    };

    networking = {
      hostName = "gears";
    };

    hardware = {
      opengl = {
        enable = true;
      };
    };

    systemd = {
      extraConfig = joinl [ "DefaultStandardOutput=journal+console" ];
      targets = {
        getty = {
          enable = false;
        };
      };
      user = {
        services = {
          "user-i3" = {
            wantedBy = [ "default.target" ];
            description = "desktop";
            unitConfig = {
              ConditionUser = "1000";
            };
            serviceConfig = {
              Type = "simple";
              TimeoutSec = "60m";
              ExecStartPre = pkgs.writeShellScript "wait-for-update" ''
                while true;
                do
                  if [[ $(systemctl show -P SubState organixm-update.service) = "dead" ]];
                  then
                    break;
                  fi
                  sleep 1
                done
                sleep 10
              '';
              ExecStart =
                let
                  config = joinl [
                    "font pango:monospace 8"
                    "workspace_layout stacking"
                    "default_border none"
                  ];
                in
                "${pkgs.xorg.xinit}/bin/xinit ${pkgs.i3}/bin/i3 -a -c ${pkgs.writeText "config-i3" config} -- ${pkgs.xorg.xorgserver}/bin/X -s 0 -dpms -nolisten tcp vt7";
              Restart = "always";
              RestartSec = "15";
            };
          };
          "user-kiosk" = {
            wantedBy = [ "default.target" ];
            requires = [ "user-i3.service" ];
            description = "user-kiosk";
            unitConfig = {
              ConditionUser = "1000";
            };
            serviceConfig = {
              Type = "simple";
              ExecStart = "${pkgs.glxinfo}/bin/glxgears";
              Restart = "always";
              RestartSec = "15";
              Environment = "DISPLAY=:0";
            };
          };
        };
      };
    };
    services = {
      journald = {
        extraConfig = joinl [ "Storage=volatile" ];
      };
      pipewire = {
        enable = true;
      };
      xserver = {
        enable = true;
        displayManager = {
          startx = {
            enable = true;
          };
        };
      };
      udev = {
        extraRules = joinl [
          "SUBSYSTEM==\"tty\", KERNEL==\"tty7*\", OWNER=\"kiosk\""
        ];
      };
    };

    extraRootFiles = [
      {
        source = builtins.toFile "linger-kiosk" "";
        target = "/var/lib/systemd/linger/kiosk";
        mode = "600";
        user = "root";
        group = "root";
      }
    ];
  };
}

