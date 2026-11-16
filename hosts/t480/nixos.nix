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

  # Closing the lid suspends, then hibernates after 2h on battery (or sooner if
  # the battery runs low). On AC it stays suspended.
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "2h";
    HibernateOnACPower = false;
  };

  # Hibernate instead of hybrid-sleeping when the battery is critically low.
  services.upower.criticalPowerAction = "Hibernate";

  networking.hostName = "t480";
  networking.networkmanager.enable = true;

  services.automatic-timezoned.enable = true;
  i18n.defaultLocale = "en_US.UTF-8";

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

  xdg.mime.defaultApplications."text/markdown" = "firefox.desktop";

  programs.nix-ld.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "josh" ];
  };

  programs.zsh.enable = true;

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

      # Smaller than the Mac's 16pt because of the 1.5x DPI below.
      programs.kitty.settings.font_size = "12.0";

      xfconf.settings = {
        # Let logind handle the lid (see HandleLidSwitch) instead of XFCE's power
        # manager, which can't suspend-then-hibernate.
        xfce4-power-manager."logind-handle-lid-switch" = true;

        # Scale the UI 1.5x for the 14" 2560x1440 (~210 DPI) panel.
        xsettings = {
          "Xft/DPI" = 144;
          "Gtk/CursorThemeSize" = 36;
        };
        xfwm4."general/theme" = "Default-hdpi";
        xfce4-panel = {
          "panels/panel-1/size" = 36;
          "panels/panel-1/icon-size" = 0;
        };
      };
    };
  };

  system.stateVersion = "26.05";
}
