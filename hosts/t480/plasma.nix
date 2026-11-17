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

    configFile.kdeglobals.General.TerminalApplication = "kitty";
  };
}
