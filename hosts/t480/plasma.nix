{ inputs, ... }:

{
  imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

  programs.plasma = {
    enable = true;

    powerdevil = {
      AC.whenSleepingEnter = "standbyThenHibernate";
      battery.whenSleepingEnter = "standbyThenHibernate";
      lowBattery.whenSleepingEnter = "standbyThenHibernate";
    };

    input.touchpads = [
      {
        name = "Synaptics TM3276-022";
        vendorId = "06cb";
        productId = "0000";
        naturalScroll = true;
      }
    ];

    configFile.kdeglobals.General.TerminalApplication = "kitty";
  };
}
