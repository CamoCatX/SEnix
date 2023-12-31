{ config, pkgs, lib, ... }:
{
  home-manager.users.jabbu = { pkgs, config, lib, ... }: {
     home.sessionVariables = {
        BROWSER = "firefox";
      };

    programs.firefox = {
      enable = true;
      package = pkgs.wrapFirefox pkgs.firefox-devedition-unwrapped {
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
            ublock-origin
            duckduckgo-privacy-essentials
            bypass-paywalls-clean
            censor-tracker
            darkreader
            behave
        ];
        profiles = {
          default = {
            isDefault = true;
              search = {
                force = true;
                default = "DuckDuckGo";
                engines = {
                  "Nix Packages" = {
                    urls = [{
                      template = "https://search.nixos.org/packages";
                      params = [
                        { name = "type"; value = "packages"; }
                        { name = "query"; value = "{searchTerms}"; }
                      ];
                    }];
                    icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                    definedAliases = [ "@np" ];
                  };
                  "NixOS Wiki" = {
                    urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
                    iconUpdateURL = "https://nixos.wiki/favicon.png";
                    updateInterval = 24 * 60 * 60 * 1000;
                    definedAliases = [ "@nw" ];
                  };
                  "Wikipedia (en)".metaData.alias = "@wiki";
                  "Google".metaData.hidden = true;
                  "Amazon.com".metaData.hidden = true;
                  "Bing".metaData.hidden = true;
                  "eBay".metaData.hidden = true;
                };
              };
              extraConfig = ''
                user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
                user_pref("browser.aboutConfig.showWarning", false);
                user_pref("browser.newtabpage.activity-stream.showSponsored", false); 
                user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);
                user_pref("browser.newtabpage.activity-stream.default.sites", "");
                user_pref("geo.provider.use_geoclue", false);
                user_pref("extensions.getAddons.showPane", false);
                user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
		user_pref("browser.discovery.enabled", false);
                user_pref("datareporting.policy.dataSubmissionEnabled", false);
		user_pref("datareporting.healthreport.uploadEnabled", false);
		user_pref("toolkit.telemetry.unified", false);
		user_pref("toolkit.telemetry.enabled", false);
		user_pref("toolkit.telemetry.server", "data:,");
		user_pref("toolkit.telemetry.archive.enabled", false);
		user_pref("toolkit.telemetry.newProfilePing.enabled", false);
		user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
		user_pref("toolkit.telemetry.updatePing.enabled", false);
		user_pref("toolkit.telemetry.bhrPing.enabled", false); 
		user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
		user_pref("toolkit.telemetry.coverage.opt-out", true);
		user_pref("toolkit.coverage.opt-out", true);
		user_pref("toolkit.coverage.endpoint.base", "");
		user_pref("browser.ping-centre.telemetry", false);
		user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
		user_pref("browser.newtabpage.activity-stream.telemetry", false);
                user_pref("app.shield.optoutstudies.enabled", false);
		user_pref("app.normandy.enabled", false);
		user_pref("app.normandy.api_url", "");
		user_pref("breakpad.reportURL", "");
		user_pref("browser.tabs.crashReporting.sendReport", false);
		user_pref("browser.crashReports.unsubmittedCheck.autoSubmit2", false); 
		user_pref("network.proxy.socks_remote_dns", true);
		user_pref("network.gio.supported-protocols", "");
		user_pref("browser.fixup.alternate.enabled", false);
		user_pref("browser.search.suggest.enabled", false);
		user_pref("browser.urlbar.suggest.searches", false);
		user_pref("browser.urlbar.speculativeConnect.enabled", false);
		user_pref("browser.urlbar.dnsResolveSingleWordsAfterSearch", 0);
		user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
		user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);
		user_pref("browser.urlbar.suggest.engines", false);
		user_pref("browser.formfill.enable", false);
		user_pref("signon.autofillForms", false);
		user_pref("signon.formlessCapture.enabled", false);
		user_pref("network.auth.subresource-http-auth-allow", 1);
		user_pref("browser.privatebrowsing.forceMediaMemoryCache", true);
		user_pref("media.memory_cache_max_size", 65536);
		user_pref("browser.sessionstore.privacy_level", 1);
		user_pref("security.tls.enable_0rtt_data", false);
		user_pref("security.OCSP.enabled", 1); 
		user_pref("dom.security.https_only_mode", true);
		user_pref("dom.security.https_only_mode_send_http_background_request", false);
		user_pref("security.ssl.treat_unsafe_negotiation_as_broken", true);
		user_pref("browser.xul.error_pages.expert_bad_cert", true);
		user_pref("network.http.referer.XOriginTrimmingPolicy", 2);
		user_pref("privacy.userContext.enabled", true);
		user_pref("privacy.userContext.ui.enabled", true);
		user_pref("browser.helperApps.deleteTempFileOnExit", true);
		user_pref("network.IDN_show_punycode", true);
		user_pref("pdfjs.disabled", false); 
		user_pref("pdfjs.enableScripting", false);
		user_pref("browser.download.manager.addToRecentDocs", false);
		user_pref("browser.download.always_ask_before_handling_new_types", true);
		user_pref("browser.download.useDownloadDir", false);
		user_pref("browser.download.alwaysOpenPanel", false);
		user_pref("extensions.postDownloadThirdPartyPrompt", false);
		user_pref("privacy.partition.serviceWorkers", true);
		user_pref("privacy.partition.always_partition_third_party_non_cookie_storage", true);
		user_pref("privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage", false); 
		user_pref("privacy.clearOnShutdown.cache", true); 
		user_pref("privacy.clearOnShutdown.offlineApps", true);
		user_pref("privacy.cpd.cache", true);
		user_pref("privacy.sanitize.timeSpan", 0);
		user_pref("privacy.resistFingerprinting", true);
		user_pref("browser.link.open_newwindow", 3);
		user_pref("extensions.webcompat-reporter.enabled", false);
		user_pref("extensions.quarantinedDomains.enabled", true);
		user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons", false);
		user_pref("browser.newtabpage.activity-stream.asrouter.userprefs.cfr.features", false);
		user_pref("browser.messaging-system.whatsNewPanel.enabled", false);
              '';
          }; 
        };
      };
    };
  };
}
