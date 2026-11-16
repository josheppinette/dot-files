{ inputs, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t480
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-a4843226-ebdf-4932-823f-cddaa4ed9fd8".allowDiscards = true;

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024;
    }
  ];
  boot.resumeDevice = "/dev/mapper/luks-a4843226-ebdf-4932-823f-cddaa4ed9fd8";
  boot.kernelParams = [ "resume_offset=246579200" ];

  networking.hostName = "t480";
  networking.networkmanager.enable = true;

  services.automatic-timezoned.enable = true;
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.trusted-users = [ "@wheel" ];

  services.xserver.enable = true;
  services.xserver.desktopManager.xfce.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.fwupd.enable = true;

  # Limit charging of both batteries (internal BAT0, removable BAT1) to extend
  # their lifespan; `sudo tlp fullcharge` overrides once.
  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 75;
    STOP_CHARGE_THRESH_BAT0 = 80;
    START_CHARGE_THRESH_BAT1 = 75;
    STOP_CHARGE_THRESH_BAT1 = 80;
  };

  programs.nix-ld.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "josh" ];
  };

  programs.zsh.enable = true;

  programs.firefox.enable = true;

  users.users.josh = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.josh = {
      imports = [ ../../modules/home ];

      # Start 1Password minimized to the tray so its SSH agent is available.
      xdg.autostart = {
        enable = true;
        entries = [
          "${
            pkgs.makeDesktopItem {
              name = "1password";
              desktopName = "1Password";
              exec = "1password --silent";
            }
          }/share/applications/1password.desktop"
        ];
      };
    };
  };

  system.stateVersion = "26.05";
}
