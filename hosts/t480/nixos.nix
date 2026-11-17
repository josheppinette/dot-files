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

  services.desktopManager.plasma6.enable = true;
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    discover
    elisa
    kate
    khelpcenter
    konsole
    krdp
    plasma-browser-integration
    plasma-keyboard
    plasma-workspace-wallpapers
    qrca
    qtvirtualkeyboard
  ];
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  hardware.bluetooth.enable = true;
  services.fwupd.enable = true;

  # Limit charging to 75-80% to extend the lifespan of both batteries.
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="power_supply", KERNEL=="BAT[01]", ATTR{charge_control_start_threshold}="75", ATTR{charge_control_end_threshold}="80"
  '';

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

      # The font is smaller than on the Mac because of the 150% scaling.
      programs.kitty.settings.font_size = "12.0";

      programs.firefox.policies.Preferences = {
        # The UHD 620 can't decode AV1, so this makes YouTube use VP9.
        "media.av1.enabled" = {
          Value = false;
          Status = "locked";
        };
        "widget.use-xdg-desktop-portal.file-picker" = {
          Value = 1;
          Status = "locked";
        };
      };
    };
  };

  system.stateVersion = "26.05";
}
