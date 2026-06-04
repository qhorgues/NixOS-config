{ pkgs, lib, config, inputs, ... }:

let
  cfg = config.mx.programs.firefox;
  addons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
  getId = str:
    builtins.substring 1 (builtins.stringLength str - 2) str;
  firefoxConfigPath = "${config.xdg.configHome}/mozilla/firefox";

  firefoxpwa = pkgs.firefoxpwa.unwrapped.overrideAttrs (old: {
    postInstall = ''
      mkdir -p $out/lib/firefoxpwa
    '' + old.postInstall;
  });
in
{
  options.mx.programs.firefox = {
    enable = lib.mkEnableOption "Use firefox with custom config";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = pkgs.firefox-bin;
      configPath = firefoxConfigPath;
      languagePacks = [ "fr" ];
      nativeMessagingHosts = [ firefoxpwa ];

      policies = {
        DisableTelemetry = true;
        DisableFirefoxStudies = true;
        DisablePocket = true;
        DisableFirefoxAccounts = true;
        DisableFormHistory = true;
        DisablePasswordReveal = true;
        DontCheckDefaultBrowser = true;
        NoDefaultBookmarks = true;
        OverrideFirstRunPage = "";
        OverridePostUpdatePage = "";
        PasswordManagerEnabled = false;

        Cookies = {
          Behavior = "reject-tracker-and-partition-foreign";
          BehaviorPrivateBrowsing = "reject-tracker-and-partition-foreign";
        };

        EnableTrackingProtection = {
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = true;
          EmailTracking = true;
        };

        HttpsOnlyMode = "force_enabled";

        SanitizeOnShutdown = {
          Cache = true;
          Cookies = true;
          Downloads = false;
          FormData = false;
          History = false;
          Sessions = true;
          SiteSettings = true;
          OfflineApps = true;
          Locked = true;
        };

        FirefoxHome = {
          Search = true;
          TopSites = false;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = false;
          Locked = true;
        };

        UserMessaging = {
          WhatsNew = false;
          ExtensionRecommendations = false;
          FeatureRecommendations = false;
          SkipOnboarding = true;
          MoreFromMozilla = false;
          Locked = true;
        };

        ExtensionSettings = {
          "uBlock0@raymondhill.net" = {
            installation_mode = "force_installed";
            install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          };
        };

        DNSOverHTTPS = {
          Enabled = true;
          ProviderURL = "https://firefox.dns.nextdns.io";
          Fallback = false;
          Locked = true;
        };
      };

      profiles = {
        "youtube" = {
          id = 1;
          name = "YouTube";
          extensions.packages = with addons; [
            ublock-origin
            ghostery
            user-agent-string-switcher
            multi-account-containers
            sponsorblock
            gnome-shell-integration
          ];
          settings = {
            "gfx.webrender.all" = true;
            "WebglAllowWindowsNativeGl" = true;
            "browser.startup.homepage" = "https://www.youtube.com";
            "browser.search.region" = "FR";
            "browser.bookmarks.showMobileBookmarks" = true;
            "browser.newtabpage.pinned" = [{
              title = "youtube";
              url = "https://www.youtube.com";
            }];
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
            "browser.newtabpage.activity-stream.feeds.snippets" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.system.showSponsored" = false;
          };
          search = {
            default = "youtube";
            force = true;
            engines = {
              youtube = {
                name = "YouTube";
                urls = [{
                  template = "https://www.youtube.com/results";
                  params = [{ name = "search_query"; value = "{searchTerms}"; }];
                }];
                iconMapObj."16" = "file://${firefoxConfigPath}/youtube/youtube-icon.svg";
                definedAliases = [ "@yt" ];
              };
              bing.metaData.hidden = true;
              google.metaData.hidden = true;
              ebay.metaData.hidden = true;
              perplexity.metaData.hidden = true;
            };
            order = [ "ddg" "qwant" "youtube" ];
            privateDefault = "qwant";
          };
        };

        "default" = {
          id = 0;
          name = "default";
          isDefault = true;
          extensions.packages = with addons; [
            bitwarden
            ublock-origin
            ghostery
            user-agent-string-switcher
            pwas-for-firefox
            multi-account-containers
            sponsorblock
            gnome-shell-integration
          ];

          settings = {
            "gfx.webrender.all" = true;
            "WebglAllowWindowsNativeGl" = true;

            "browser.aboutConfig.showWarning" = false;
            "browser.display.document_color_use" = 0;
            "browser.download.useDownloadDir" = false;
            "browser.download.viewableInternally.typeWasRegistered.avif" = true;
            "browser.download.viewableInternally.typeWasRegistered.webp" = true;
            "browser.engagement.sidebar-button.has-used" = true;
            "browser.gnome-search-provider.enabled" = true;
            "browser.search.region" = "FR";
            "browser.search.suggest.enabled" = false;
            "browser.search.serpEventTelemetryCategorization.regionEnabled" = false;
            "browser.startup.page" = 3;
            "browser.tabs.vertical" = true;
            "browser.ui.layout" = "vertical-tabs";
            "browser.tabs.drawInTitlebar" = false;
            "browser.tabs.firefox-view" = false;
            "browser.urlbar.placeholderName" = "DuckDuckGo";
            "browser.urlbar.suggest.bookmark" = false;
            "browser.urlbar.suggest.quickactions" = false;
            "browser.urlbar.suggest.searches" = false;

            "browser.newtabpage.blocked" = lib.genAttrs [
              "26UbzFJ7qT9/4DhodHKA1Q=="  # Youtube
              "4gPpjkxgZzXPVtuEoAL9Ig=="  # Facebook
              "eV8/WsSLxHadrTL1gAxhug=="  # Wikipedia
              "gLv0ja2RYVgxKdp0I5qwvA=="  # Reddit
              "K00ILysCaEq8+bEqV/3nuw=="  # Amazon
              "T9nJot5PurhJSy8n038xGA=="  # Twitter
              "QSdQrU6w/DXzjR/8lOKeoQ=="  # Le monde
            ] (_: 1);

            "browser.uiCustomization.state" = builtins.toJSON {
              dirtyAreaCache = [
                "vertical-tabs" "nav-bar" "PersonalToolbar"
                "toolbar-menubar" "TabsToolbar"
                "widget-overflow-fixed-list" "unified-extensions-area"
              ];
              placements = {
                PersonalToolbar = ["personal-bookmarks"];
                TabsToolbar = [];
                unified-extensions-area = [
                  "_${getId addons.user-agent-string-switcher.addonId}_-browser-action"
                  "sponsorblocker_ajay_app-browser-action"
                ];
                nav-bar = [
                  "sidebar-button" "back-button" "forward-button"
                  "stop-reload-button" "home-button" "vertical-spacer"
                  "urlbar-container" "downloads-button" "sync-button"
                  "ublock0_raymondhill_net-browser-action"
                  "firefox_ghostery_com-browser-action"
                  "_${getId addons.bitwarden.addonId}_-browser-action"
                  "reset-pbm-toolbar-button" "unified-extensions-button"
                ];
                toolbar-menubar = ["menubar-items"];
                widget-overflow-fixed-list = [];
                vertical-tabs = ["tabbrowser-tabs"];
              };
              seen = [
                "developer-button"
                "ublock0_raymondhill_net-browser-action"
                "_testpilot-containers-browser-action"
                "addon_darkreader_org-browser-action"
                "_${getId addons.bitwarden.addonId}_-browser-action"
                "firefox_ghostery_com-browser-action"
                "screenshot-button"
                "_${getId addons.user-agent-string-switcher.addonId}_-browser-action"
                "firefoxpwa_filips_si-browser-action"
              ];
            };

            "browser.uiCustomization.navBarWhenVerticalTabs" = builtins.toJSON [
              "sidebar-button" "back-button" "forward-button"
              "stop-reload-button" "home-button" "vertical-spacer"
              "urlbar-container" "downloads-button" "sync-button"
              "ublock0_raymondhill_net-browser-action"
              "firefox_ghostery_com-browser-action"
              "_${getId addons.bitwarden.addonId}_-browser-action"
              "reset-pbm-toolbar-button" "unified-extensions-button"
            ];

            "sidebar.backupState" = builtins.toJSON {
              panelOpen = false;
              launcherWidth = 55;
              launcherExpanded = false;
              launcherVisible = true;
              pinnedTabsHeight = 0;
              collapsedPinnedTabsHeight = 0;
            };
            "sidebar.new-sidebar.has-used" = true;
            "sidebar.revamp" = true;
            "sidebar.verticalTabs" = true;

            "network.dns.disablePrefetch" = true;
            "privacy.annotate_channels.strict_list.enabled" = true;
            "privacy.bounceTrackingProtection.hasMigratedUserActivationData" = true;
            "privacy.bounceTrackingProtection.mode" = 1;
            "privacy.donottrackheader.enabled" = true;
            "privacy.globalprivacycontrol.enabled" = true;
            "privacy.globalprivacycontrol.was_ever_enabled" = true;
            "privacy.history.custom" = true;
            "privacy.query_stripping.enabled" = true;
            "privacy.query_stripping.enabled.pbmode" = true;
            "privacy.trackingprotection.consentmanager.skip.pbmode.enabled" = false;
            "privacy.userContext.newTabContainerOnLeftClick.enabled" = false;

            "extensions.activeThemeID" = "default-theme@mozilla.org";
            "extensions.autoDisableScopes" = 0;
            "extensions.formautofill.creditCards.enabled" = false;
            "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;
            "extensions.ui.dictionary.hidden" = true;
            "extensions.ui.extension.hidden" = false;
            "extensions.ui.locale.hidden" = false;
            "extensions.ui.mlmodel.hidden" = true;
            "extensions.ui.sitepermission.hidden" = true;
            "extensions.webcompat.enable_shims" = true;
            "extensions.webcompat.perform_injections" = true;

            "intl.accept_languages" = "fr-fr,en-us";
            "intl.locale.requested" = "fr";
            "intl.regional_prefs.use_os_locales" = true;
            "media.eme.enabled" = true;
            "places.frecency.accelerateRecalculation" = true;
            "widget.use-xdg-desktop-portal.file-picker" = 1;

            "browser.ml.chat.enabled" = true;
            "browser.ml.chat.provider" = "localhost:8080";

            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
            "browser.newtabpage.activity-stream.feeds.snippets" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.system.showSponsored" = false;
          };

          search = {
            default = "ddg";
            force = true;
            engines = {
              nix-packages = {
                name = "Nix Packages";
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
              nix-options = {
                name = "NixOS Options";
                urls = [{
                  template = "https://search.nixos.org/options";
                  params = [
                    { name = "type"; value = "options"; }
                    { name = "query"; value = "{searchTerms}"; }
                  ];
                }];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                definedAliases = [ "@no" ];
              };
              my-nixos = {
                name = "MyNixOS";
                urls = [{
                  template = "https://mynixos.com/search";
                  params = [
                    { name = "type"; value = "packages"; }
                    { name = "q"; value = "{searchTerms}"; }
                  ];
                }];
                icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake-white.svg";
                definedAliases = [ "@mn" ];
              };
              nixos-wiki = {
                name = "NixOS Wiki";
                urls = [{ template = "https://wiki.nixos.org/w/index.php?search={searchTerms}"; }];
                iconMapObj."16" = "https://wiki.nixos.org/favicon.ico";
                definedAliases = [ "@nw" ];
              };
              youtube = {
                name = "YouTube";
                urls = [{
                  template = "https://www.youtube.com/results";
                  params = [{ name = "search_query"; value = "{searchTerms}"; }];
                }];
                iconMapObj."16" = "file://${firefoxConfigPath}/youtube/youtube-icon.svg";
                definedAliases = [ "@yt" ];
              };
              bing.metaData.hidden = true;
              google.metaData.hidden = true;
              ebay.metaData.hidden = true;
              perplexity.metaData.hidden = true;
            };
            order = [ "ddg" "qwant" "Nix Packages" "NixOS Options" "NixOS Wiki" "youtube" ];
            privateDefault = "qwant";
          };
        };
      };
    };

    home.file."${firefoxConfigPath}/default/permissions.sqlite".source = ./permissions.sqlite;
    home.file."${firefoxConfigPath}/youtube/youtube-icon.svg".source = ./youtube-icon.svg;

    home.sessionVariables.MOZ_USE_XINPUT2 = "1";

    home.packages = [ firefoxpwa ];

    xdg.desktopEntries."youtube" = {
      name = "Youtube";
      genericName = "Video player";
      comment = "Watch vidéo on youtube";
      exec = "${pkgs.firefox-bin}/bin/firefox -P YouTube --no-remote";
      icon = "${firefoxConfigPath}/youtube/youtube-icon.svg";
      categories = [ "Network" "WebBrowser" ];
      terminal = false;
    };
  };
}
