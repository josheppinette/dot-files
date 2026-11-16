{ lib, pkgs, ... }:

let
  # Extension ID (see about:support) = addons.mozilla.org slug.
  extensions = {
    "{d634138d-c276-4fc8-924b-40a0ea21d284}" = "1password-x-password-manager";
    "{88ebde3a-4581-4c6b-8019-2a05a9e3e938}" = "hide-youtube-shorts";
    "{f3ee08f8-d4d8-4095-8096-4bb784d082f9}" = "markdown-reader-ext";
    "uBlock0@raymondhill.net" = "ublock-origin";
  };
in
{
  programs.firefox = {
    enable = true;

    # Home Manager wraps `package`, breaking the macOS signature 1Password needs; install it below.
    package = if pkgs.stdenv.isDarwin then null else pkgs.firefox;

    policies = {
      # Updated with the flake, like every other package.
      DisableAppUpdate = true;
      DisableTelemetry = true;
      DisableFirefoxStudies = true;

      # Passwords live in 1Password.
      OfferToSaveLogins = false;

      ExtensionSettings = lib.mapAttrs (_: slug: {
        install_url = "https://addons.mozilla.org/firefox/downloads/latest/${slug}/latest.xpi";
        installation_mode = "normal_installed";
      }) extensions;
    };
  };

  home.packages = lib.optional pkgs.stdenv.isDarwin pkgs.firefox-bin-unwrapped;
}
