{ config, pkgs, ... }:
{
  nixpkgs.config.firefox.speechSynthesisSupport = true;

  programs.firefox = {
    enable = true;
    package = pkgs.firefox-devedition;
    preferences = { 
    // https://kb.mozillazine.org/User.js_file
    // disable about:config warning
      user_pref("browser.aboutConfig.showWarning", false);

    // disable default browser check
    //user_pref("browser.shell.checkDefaultBrowser", false);

/*
 * set startup page:
 *    0 = blank
 *    1 = home
 *    2 = last visited page
 *    3 = resume previous session
 */
user_pref("browser.startup.page",  1);
user_pref("browser.startup.homepage", "about:home");

// disable activity stream on new windows and tab pages
user_pref("browser.newtabpage.enabled", false);
user_pref("browser.newtab.preload", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false); // disable telemetry
user_pref("browser.newtabpage.activity-stream.telemetry", false); // disable telemetry
user_pref("browser.newtabpage.activity-stream.feeds.snippets", false);
user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
user_pref("browser.newtabpage.activity-stream.feeds.discoverystreamfeed", false);
user_pref("browser.newtabpage.activity-stream.showSponsored", false); // Pocket -> Sponsored Stories
user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false); // Sponsored Shortcuts
user_pref("browser.newtabpage.activity-stream.default.sites", "");


/*********************************************************************
 * Geolocation
 *********************************************************************/

// use Mozilla geolocation service instead of Google if permission is granted
user_pref("geo.provider.network.url", "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%");

// disable using the OS’s geolocation service
//user_pref("geo.provider.ms-windows-location", false); // Windows
//user_pref("geo.provider.use_corelocation", false);    // macOS
user_pref("geo.provider.use_gpsd", false);              // Linux
user_pref("geo.provider.use_geoclue", false);           // Linux

// disable region updates
user_pref("browser.region.network.url", "");
user_pref("browser.region.update.enabled", false);


/*********************************************************************
 * Language / Locale
 *********************************************************************/

// set language for displaying web pages:
user_pref("intl.accept_languages", "en-US, en");
user_pref("javascript.use_us_english_locale", true); // [HIDDEN PREF]


/*********************************************************************
 * Auto-updates / Recommendations
 *********************************************************************/

// disable auto-installing Firefox updates
//user_pref("app.update.background.scheduling.enabled", false); // Windows
user_pref("app.update.auto", false);                            // Non-Windows

// disable addons recommendations (use Google Analytics)
user_pref("extensions.getAddons.showPane", false); // [HIDDEN PREF]
user_pref("extensions.htmlaboutaddons.recommendations.enabled", false);
user_pref("browser.discovery.enabled", false);


/*********************************************************************
 * Telemetry
 *********************************************************************/

// disable telemetry
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("toolkit.telemetry.enabled", false); // Default: false
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.server", "data:,");
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.coverage.opt-out", true); // [HIDDEN PREF]
user_pref("toolkit.coverage.opt-out", true); // [HIDDEN PREF]
user_pref("toolkit.coverage.endpoint.base.", "");
user_pref("browser.ping-centre.telemetry", false);
user_pref("beacon.enabled", false);


/*********************************************************************
 * Studies
 *********************************************************************/

// disable studies
user_pref("app.shield.optoutstudies.enabled", false);

// disable normandy/shield
user_pref("app.normandy.enabled", false);
user_pref("app.normandy.api_url", "");


/*********************************************************************
 * Crash Reports
 *********************************************************************/

// disable crash reports
user_pref("breakpad.reportURL", "");
user_pref("browser.tabs.crashReporting.sendReport", false);


/*********************************************************************
 * Captive Portal Detection / Network Checks
 *********************************************************************/

// disable captive portal detection
user_pref("captivedetect.canonicalURL", "");
user_pref("network.captive-portal-service.enabled", false);

// disable network connections checks
user_pref("network.connectivity-service.enabled", false);


/*********************************************************************
 * Safe Browsing
 *********************************************************************/

// disable safe browsing service
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);

// disable list of blocked URI
user_pref("browser.safebrowsing.blockedURIs.enabled", false);

// disable fetch of updates
user_pref("browser.safebrowsing.provider.google4.gethashURL", "");
user_pref("browser.safebrowsing.provider.google4.updateURL", "");
user_pref("browser.safebrowsing.provider.google.gethashURL", "");
user_pref("browser.safebrowsing.provider.google.updateURL", "");
user_pref("browser.safebrowsing.provider.google4.dataSharingURL", "");

// disable checks for downloads
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.url", "");

// disable checks for unwanted software
user_pref("browser.safebrowsing.downloads.remote.block_potentially_unwanted", false);
user_pref("browser.safebrowsing.downloads.remote.block_uncommon", false);

// disable bypasses the block of safe browsing with a click for current session
user_pref("browser.safebrowsing.allowOverride", false);


/*********************************************************************
 * Network: DNS, Proxy, IPv6
 *********************************************************************/

// disable link prefetching
user_pref("network.prefetch-next", false);

// disable DNS prefetching
user_pref("network.dns.disablePrefetch", true);

// disable predictor / prefetching
user_pref("network.predictor.enabled", false);

// disable link-mouseover opening connection to linked server
user_pref("network.http.speculative-parallel-limit", 0);

// disable mousedown speculative connections on bookmarks and history
user_pref("browser.places.speculativeConnect.enabled", false);

// disable IPv6
user_pref("network.dns.disableIPv6", true);

// disable "GIO" protocols as a potential proxy bypass vectors
user_pref("network.gio.supported-protocols", ""); // [HIDDEN PREF]

// disable using UNC (Uniform Naming Convention) paths (prevent proxy bypass)
user_pref("network.file.disable_unc_paths", true); // [HIDDEN PREF]

// remove special permissions for certain mozilla domains
user_pref("permissions.manager.defaultsUrl", "");

// use Punycode in Internationalized Domain Names to eliminate possible spoofing
user_pref("network.IDN_show_punycode", true);


/*********************************************************************
 * Search Bar: Suggestions, Autofill
 *********************************************************************/

// disable search suggestions
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.urlbar.suggest.searches", false);


// disable location bar domain guessing
user_pref("browser.fixup.alternate.enabled", false);

// display all parts of the url in the bar
user_pref("browser.urlbar.trimURLs", false);

// disable location bar making speculative connections
user_pref("browser.urlbar.speculativeConnect.enabled", false);

// disable form autofill
user_pref("browser.formfill.enable", false); // form history
user_pref("extensions.formautofill.addresses.enabled", false);
user_pref("extensions.formautofill.available", "off");
user_pref("extensions.formautofill.creditCards.available", false);
user_pref("extensions.formautofill.creditCards.enabled", false);
user_pref("extensions.formautofill.heuristics.enabled", false);

// disable location bar contextual suggestions:
user_pref("browser.urlbar.quicksuggest.scenario", "history");
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.suggest.quicksuggest.nonsponsored", false);
user_pref("browser.urlbar.suggest.quicksuggest.sponsored", false);


/*********************************************************************
 * Passwords
 *********************************************************************/

// disable saving passwords
user_pref("signon.rememberSignons", false);

// disable autofill login and passwords
user_pref("signon.autofillForms", false);

// disable formless login capture for Password Manager
user_pref("signon.formlessCapture.enabled", false);

/*
 * hardens against potential credentials phishing:
 *    0 = don't allow sub-resources to open HTTP authentication credentials dialogs
 *    1 = don't allow cross-origin sub-resources to open HTTP authentication credentials dialogs
 *    2 = allow sub-resources to open HTTP authentication credentials dialogs (default)
 */
user_pref("network.auth.subresource-http-auth-allow", 1);


/*********************************************************************
 * Disk Cache / Memory
 *********************************************************************/

// disable disk cache
user_pref("browser.cache.disk.enable", false);

/*
 * disable storing extra session data:
 *    0 = everywhere
 *    1 = unencrypted sites
 *    2 = nowhere
 */
user_pref("browser.sessionstore.privacy_level", 2);

// disable resuming session from crash
user_pref("browser.sessionstore.resume_from_crash", false);

// disable page thumbnail collection
user_pref("browser.pagethumbnails.capturing_disabled", true); // [HIDDEN PREF]

// disable favicons in profile folder
user_pref("browser.shell.shortcutFavicons", false)

// delete temporary files opened with external apps
user_pref("browser.helperApps.deleteTempFileOnExit", true);


/*********************************************************************
 * HTTPS / SSL/TLS / OSCP / CERTS
 *********************************************************************/

// enable HTTPS-Only mode in all windows
user_pref("dom.security.https_only_mode", true);

// disable sending HTTP request for checking HTTPS support by the server
user_pref("dom.security.https_only_mode_send_http_background_request", false);

// display advanced information on Insecure Connection warning pages
user_pref("browser.xul.error_pages.expert_bad_cert", true);

// disable TLS 1.3 0-RTT (round-trip time)
user_pref("security.tls.enable_0rtt_data", false);

// set OCSP to terminate the connection when a CA isn't validate
user_pref("security.OCSP.require", true);

// disable SHA-1 certificates
user_pref("security.pki.sha1_enforcement_level", 1);

/*
 * enable strict pinning (PKP (Public Key Pinning)):
 *    0 = disabled
 *    1 = allow user MiTM (i.e. your Antivirus)
 *    2 = strict
 */
user_pref("security.cert_pinning.enforcement_level", 2);

/*
 * enable CRLite
 *    0 = disabled
 *    1 = consult CRLite but only collect telemetry (default)
 *    2 = consult CRLite and enforce both "Revoked" and "Not Revoked" results
 *    3 = consult CRLite and enforce "Not Revoked" results, but defer to OCSP for "Revoked"
 */
user_pref("security.remote_settings.crlite_filters.enabled", true);
user_pref("security.pki.crlite_mode", 2);
/*
 * control when to send a referer:
 *    0 = always (default)
 *    1 = only if base domains match
 *    2 = only if hosts match
 */
user_pref("network.http.referer.XOriginPolicy", 2);

/*
 * control amount of information to send:
 *    0 = send full URI (default):  https://example.com:8888/foo/bar.html?id=1234
 *    1 = scheme+host+port+path:    https://example.com:8888/foo/bar.html
 *    2 = scheme+host+port:         https://example.com:8888
 */
user_pref("network.http.referer.XOriginTrimmingPolicy", 2);


/*********************************************************************
 * Audio/Video: WebRTC, WebGL
 *********************************************************************/

// force WebRTC inside the proxy
user_pref("media.peerconnection.ice.proxy_only_if_behind_proxy", true);

// force a single network interface for ICE candidates generation
user_pref("media.peerconnection.ice.default_address_only", true);

// force exclusion of private IPs from ICE candidates
user_pref("media.peerconnection.ice.no_host", true);

/*
 * disable autoplay of HTML5 media, You can set exceptions under site
 * permissions.
 *    0 = allow all
 *    1 = block non-muted media (default)
 *    5 = block all
 */
user_pref("media.autoplay.default", 5);

/*********************************************************************
 * Downloads
 *********************************************************************/

// always ask you where to save files:
user_pref("browser.download.useDownloadDir", false);

// disable adding downloads to system's "recent documents" list
user_pref("browser.download.manager.addToRecentDocs", false);


/*********************************************************************
 * Cookies
 *********************************************************************/

/*
 * enable ETP (Enhanced Tracking Protection)
 * ETP strict mode enables Total Cookie Protection (TCP)
 */
user_pref("browser.contentblocking.category", "strict");

// enable state partitioning of service workers
user_pref("privacy.partition.serviceWorkers", true); // Default: true

// enable APS (Always Partitioning Storage)
user_pref("privacy.partition.always_partition_third_party_non_cookie_storage", true);
user_pref("privacy.partition.always_partition_third_party_non_cookie_storage.exempt_sessionstorage", false);


/*********************************************************************
 * UI Features
 *********************************************************************/

// limit events that can cause a popup
user_pref("dom.popup_allowed_events", "click dblclick mousedown pointerdown");

// disable Pocket extension
user_pref("extensions.pocket.enabled", false);

// disable Screenshots extension
user_pref("extensions.screenshots.disabled", true);

// enable Containers and show the UI settings
user_pref("privacy.userContext.enabled", true);
user_pref("privacy.userContext.ui.enabled", true);


/*********************************************************************
 * Extensions
 *********************************************************************/

/*
 * extensions are allowed to work on restricted domains, while their scope
 * is set to profile+applications.
 * See: https://web.archive.org/web/20220325021055/https://mike.kaply.com/2012/02/21/understanding-add-on-scopes/ (sorry it's insecure)
 */
      user_pref("extensions.enabledScopes", 5); // [HIDDEN PREF]
      user_pref("extensions.webextensions.restrictedDomains", "");

      // Display always the installation prompt
      user_pref("extensions.postDownloadThirdPartyPrompt", false);


      /*********************************************************************
      * Shutdown Settings
      \*********************************************************************/

      // clear unessisarry data when Firefox closes
      user_pref("network.cookie.lifetimePolicy", 2);
      user_pref("privacy.sanitize.sanitizeOnShutdown", true);
      user_pref("privacy.clearOnShutdown.cache", true);
      // user_pref("privacy.clearOnShutdown.cookies", true);
      user_pref("privacy.clearOnShutdown.downloads", true);
      user_pref("privacy.clearOnShutdown.formdata", true);
      // user_pref("privacy.clearOnShutdown.history", true);
      user_pref("privacy.clearOnShutdown.offlineApps", true);
      user_pref("privacy.clearOnShutdown.sessions", true);
      // user_pref("privacy.clearOnShutdown.sitesettings", true);
      user_pref("privacy.sanitize.timeSpan", 0);
 
    };

    policies = {
      "DisableFirefoxStudies": true,
      "DisableFirefoxStudies_comment": "Disable Firefox studies (Shield).",
      "SearchEngines": {
        "Default": "DuckDuckGo",
        "Default_comment": "Set the default search engine to DuckDuckGo instead of Google." 
      }
    };

    extraPrefs = ''

      // Enable dark dev tools
      devtools.theme"
    '';
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
  environment.variables = {
    BROWSER = ["firefox"];
  };

}
