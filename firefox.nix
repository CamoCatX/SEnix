{ config, pkgs, ... }:
let
  fetchfirefoxaddon=callPackage ./modules/fetchfirefoxaddon {};
  callPackage = pkgs.lib.callPackageWith (pkgs);
  wrapper = pkgs.callPackage ./overlays/wrapper.nix { fx_cast_bridge=pkgs.unstable.pkgs.fx_cast_bridge; };

  hardenedFirefox= wrapper pkgs.firefox-devedition-unwrapped {
    extraPolicies = {
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      UserMessaging = {
        ExtensionRecommendations = false;
        SkipOnboarding = true;
      };
      FirefoxHome = {
        Pocket = false;
        Snippets = false;
      };
    };

    extraPrefs = ''
      // Show more ssl cert infos
      lockPref("security.identityblock.show_extended_validation", true);

      // Enable userchrome css
      lockPref("toolkit.legacyUserProfileCustomizations.stylesheets", true);

      // Enable dark dev tools
      lockPref("devtools.theme","dark");
    '';

    gdkWayland = true;
  };

    languagePacks = [ 
      "ach", "af", "an", "ar", "ast", "az", 
      "be", "bg", "bn", "br", "bs", "ca-valencia", 
      "ca", "cak", "cs", "cy", "da", "de", "dsb", 
      "el", "en-CA", "en-GB", "en-US", "eo", "es-AR", 
      "es-CL", "es-ES", "es-MX", "et", "eu", "fa", "ff", 
      "fi", "fr", "fy-NL", "ga-IE", "gd", "gl", "gn", "gu-IN", 
      "he", "hi-IN", "hr", "hsb", "hu", "hy-AM", "ia", "id", "is",
      "it", "ja", "ka", "kab", "kk", "km", "kn", "ko", "lij", "lt", 
      "lv", "mk", "mr", "ms", "my", "nb-NO", "ne-NP", "nl", "nn-NO", "oc",
      "pa-IN", "pl", "pt-BR", "pt-PT", "rm", "ro", "ru", "sco", "si", "sk",
      "sl", "son", "sq", "sr", "sv-SE", "szl", "ta", "te", "th", "tl", "tr", 
      "trs", "uk", "ur", "uz", "vi", "xh", "zh-CN", "zh-TW"
    ];
in {

environment.variables = {
  BROWSER = ["firefox"];
};

environment.systemPackages = with pkgs; [
  # firefox
  hardenedFirefox
];

}

}
