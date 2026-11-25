{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "homelab";
  networking.networkmanager.enable = true;
  # With Wi-Fi on the same subnet, replies to the wired address left over Wi-Fi.
  networking.networkmanager.unmanaged = [ "type:wifi" ];

  # Everything is reachable over the tailnet, and nothing over the LAN.
  networking.firewall.trustedInterfaces = [ "tailscale0" ];
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";

  systemd.sleep.settings.Sleep = {
    AllowSuspend = false;
    AllowHibernation = false;
    AllowHybridSleep = false;
    AllowSuspendThenHibernate = false;
  };

  services.fwupd.enable = true;

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.extraPools = [ "tank" ];
  # ZFS refuses to import a pool last used by a different host ID.
  networking.hostId = "553618c1";
  services.zfs.autoScrub.enable = true;
  services.smartd.enable = true;
  services.sanoid = {
    enable = true;
    datasets.tank = {
      recursive = true;
      autosnap = true;
      autoprune = true;
      hourly = 24;
      daily = 30;
      monthly = 6;
    };
  };

  hardware.graphics.enable = true;
  # This loads the driver, even without a desktop.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    nvidiaPersistenced = true;
  };

  services.ollama = {
    enable = true;
    # CUDA builds aren't cached, so build only for the 3070 to keep it short.
    package = pkgs.ollama-cuda.override { cudaArches = [ "sm_86" ]; };
    host = "0.0.0.0";
    # Coding agents send long prompts, and the last two halve their memory.
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32768";
      OLLAMA_FLASH_ATTENTION = "1";
      OLLAMA_KV_CACHE_TYPE = "q8_0";
    };
  };

  programs.nix-ld.enable = true;

  programs.zsh.enable = true;

  users.users.josh = {
    isNormalUser = true;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHl7vV84TxCJ44vxh7NY12XFHDQhqzSBv1zXi0E99sy4 Personal"
    ];
  };

  # Without the 1Password agent, sudo needs a password, so ask less often.
  security.sudo.extraConfig = "Defaults timestamp_timeout=30";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.josh.imports = [ ../../modules/home/base.nix ];
  };

  system.stateVersion = "26.05";
}
