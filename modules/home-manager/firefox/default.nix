{ pkgs, pkgs-unstable, inputs, lib, config, ... }:

let
    addons = inputs.firefox-addons.packages.${pkgs.system};
    getId = str:
        builtins.substring 1 (builtins.stringLength str - 2) str;
in
{
    programs.firefox = {
        enable = true;
        package = pkgs.firefox-bin;
        languagePacks = [
        "fr"
        ];
        nativeMessagingHosts = [ pkgs-unstable.firefoxpwa ];
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
          ];

          search = {
              default = "youtube";
              force = true;
              engines = {
                  youtube = {
                      name = "YouTube";
                      urls = [{
                          template = "https://www.youtube.com/results";
                          params = [
                          { name = "search_query"; value = "{searchTerms}"; }
                          ];
                      }];
                      iconMapObj."16" = "file://${config.home.homeDirectory}/.mozilla/firefox/default/youtube-icon.svg";
                      definedAliases = [ "@yt" ];
                  };

                  bing.metaData.hidden = true;
                  google.metaData.hidden = true;
                  # ebay.metaData.hidden = true;
              };
              order = [
                  "ddg"
                  "qwant"
                  "youtube"
              ];
              privateDefault = "qwant";
          };
            "browser.startup.homepage" = "https://www.youtube.com";
            "browser.search.region" = "FR";
            "browser.search.isUS" = false;
            "distribution.searchplugins.defaultLocale" = "fr-FR";
            "general.useragent.locale" = "fr-FR";
            "browser.bookmarks.showMobileBookmarks" = true;
            "browser.newtabpage.pinned" = [{
              title = "youtube";
              url = "https://www.youtube.com";
            }];
        };
        "default" = {
            id = 0;
            name = "default";
            isDefault = true;
            extensions.packages = with addons; [
            bitwarden
            ublock-origin
            ghostery
            # darkreader
            user-agent-string-switcher
            pwas-for-firefox
            multi-account-containers
            sponsorblock
            ];

            settings = {
            "app.normandy.first_run" = 0;
            "browser.aboutConfig.showWarning" = false;
            "browser.bookmarks.restore_default_bookmarks" = false;
            "browser.contentblocking.category" = "custom";
            "browser.discovery.enabled" = false;
            "browser.display.document_color_use" = 0;
            "browser.download.useDownloadDir" = false;
            "browser.download.viewableInternally.typeWasRegistered.avif" = true;
            "browser.download.viewableInternally.typeWasRegistered.webp" = true;
            "browser.engagement.sidebar-button.has-used" = true;
            "browser.laterrun.enabled" = true;
            "browser.newtabpage.activity-stream.asrouter.userprefs.cfr.addons" = false;
            "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.feeds.topsites" = false;
            "browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;

            "browser.newtabpage.blocked" = lib.genAttrs [
                # Youtube
                "26UbzFJ7qT9/4DhodHKA1Q=="
                # Facebook
                "4gPpjkxgZzXPVtuEoAL9Ig=="
                # Wikipedia
                "eV8/WsSLxHadrTL1gAxhug=="
                # Reddit
                "gLv0ja2RYVgxKdp0I5qwvA=="
                # Amazon
                "K00ILysCaEq8+bEqV/3nuw=="
                # Twitter
                "T9nJot5PurhJSy8n038xGA=="
                # Le monde
                "QSdQrU6w/DXzjR/8lOKeoQ=="
            ] (_: 1);

            "browser.ping-centre.telemetry" = false;
            "browser.policies.applied" = true;
            "browser.preferences.experimental.hidden" = false;

            "browser.search.region" = "FR";
            "browser.search.serpEventTelemetryCategorization.regionEnabled" = false;
            "browser.search.suggest.enabled" = false;
            "browser.startup.page" = 3;
            "browser.tabs.vertical" = true;
            "browser.ui.layout" = "vertical-tabs";

            "identity.fxaccounts.toolbar.enabled" = false;
            "browser.newtabpage.activity-stream.showFxa" = false;
            "browser.tabs.drawInTitlebar" = false;
            "browser.tabs.firefox-view" = false;

            "browser.uiCustomization.state" = builtins.toJSON {
                dirtyAreaCache = [
                  "vertical-tabs"
                  "nav-bar"
                  "PersonalToolbar"
                  "toolbar-menubar"
                  "TabsToolbar"
                  "widget-overflow-fixed-list"
                  "unified-extensions-area"
                ];
                placements = {
                PersonalToolbar = ["personal-bookmarks"];
                TabsToolbar = [];
                unified-extensions-area = [
                    "_${getId addons.user-agent-string-switcher.addonId}_-browser-action" # user agent switcher
                    "sponsorblocker_ajay_app-browser-action"
                ];
                nav-bar = [
                  "sidebar-button"
                  "back-button"
                  "forward-button"
                  "stop-reload-button"
                  "home-button"
                  "vertical-spacer"
                  "urlbar-container"
                  "downloads-button"
                  "sync-button"
                  "ublock0_raymondhill_net-browser-action"
                  "firefox_ghostery_com-browser-action"
                  "_${getId addons.bitwarden.addonId}_-browser-action" # bitwarden
                  "reset-pbm-toolbar-button"
                  "unified-extensions-button"
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

            "browser.urlbar.placeholderName" = "DuckDuckGo";
            "browser.urlbar.suggest.bookmark" = false;
            "browser.urlbar.suggest.quickactions" = false;
            "browser.urlbar.suggest.searches" = false;
            "datareporting.healthreport.service.enabled" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "datareporting.sessions.current.clean" = true;
            "devtools.onboarding.telemetry.logged" = false;

            "dom.security.https_only_mode" = true;
            "dom.security.https_only_mode_ever_enabled" = true;
            "dom.security.https_only_mode_ever_enabled_pbm" = true;
            "extensions.activeThemeID" = "default-theme@mozilla.org";
            "extensions.autoDisableScopes" = 0;
            "extensions.blocklist.pingCountVersion" = 0;
            "extensions.colorway-builtin-themes-cleanup" = 1;
            "extensions.formautofill.creditCards.enabled" = false;

            "extensions.pictureinpicture.enable_picture_in_picture_overrides" = true;

            "extensions.ui.dictionary.hidden" = true;
            "extensions.ui.extension.hidden" = false;
            "extensions.ui.lastCategory" = "addons://discover/";
            "extensions.ui.locale.hidden" = false;
            "extensions.ui.mlmodel.hidden" = true;
            "extensions.ui.sitepermission.hidden" = true;
            "extensions.webcompat.enable_shims" = true;
            "extensions.webcompat.perform_injections" = true;

            "extensions.pocket.enabled" = false;

            "intl.accept_languages" = "fr-fr,en-us";
            "intl.locale.requested" = "fr";
            "intl.regional_prefs.use_os_locales" = true;
            "media.eme.enabled" = true;

            "places.frecency.accelerateRecalculation" = true;
            "pref.downloads.disable_button.edit_actions" = false;
            "pref.privacy.disable_button.cookie_exceptions" = false;
            "privacy.annotate_channels.strict_list.enabled" = true;
            "privacy.bounceTrackingProtection.hasMigratedUserActivationData" = true;
            "privacy.bounceTrackingProtection.mode" = 1;
            "privacy.clearOnShutdown.downloads" = false;
            "privacy.clearOnShutdown.formdata" = false;
            "privacy.clearOnShutdown.history" = false;
            "privacy.clearOnShutdown.offlineApps" = true;
            "privacy.clearOnShutdown_v2.browsingHistoryAndDownloads" = false;
            "privacy.clearOnShutdown_v2.downloads" = false;
            "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = false;
            "privacy.donottrackheader.enabled" = true;
            "privacy.fingerprintingProtection" = true;
            "privacy.globalprivacycontrol.enabled" = true;
            "privacy.globalprivacycontrol.was_ever_enabled" = true;
            "privacy.history.custom" = true;
            "privacy.query_stripping.enabled" = true;
            "privacy.query_stripping.enabled.pbmode" = true;
            "privacy.sanitize.clearOnShutdown.hasMigratedToNewPrefs3" = true;
            "privacy.sanitize.pending" = builtins.toJSON [
                {
                id = "shutdown";
                itemsToClear = [
                    "cache"
                    "cookiesAndStorage"
                ];
                options = {};
                }
                {
                id = "newtab-container";
                itemsToClear = [];
                options = {};
                }
            ];
            "privacy.sanitize.sanitizeOnShutdown" = true;
            "privacy.trackingprotection.consentmanager.skip.pbmode.enabled" = false;
            "privacy.trackingprotection.emailtracking.enabled" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.userContext.newTabContainerOnLeftClick.enabled" = false;

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
            "signon.autofillForms" = false;
            "signon.generation.enabled" = false;
            "signon.rememberSignons" =	false;

            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;

            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.hybridContent.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.prompted" = 2;
            "toolkit.telemetry.rejected" = true;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.server" = "";
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.unifiedIsOptIn" = false;
            "toolkit.telemetry.updatePing.enabled" = false;
            "trailhead.firstrun.didSeeAboutWelcome" = true;
            "widget.use-xdg-desktop-portal.file-picker" = 1;

            "browser.ml.chat.enabled" = true;
            "browser.ml.chat.provider" = "localhost:8080";
            "browser.uiCustomization.navBarWhenVerticalTabs" = builtins.toJSON [
                "sidebar-button"
                "back-button"
                "forward-button"
                "stop-reload-button"
                "home-button"
                "vertical-spacer"
                "urlbar-container"
                "downloads-button"
                "sync-button"
                "ublock0_raymondhill_net-browser-action"
                "firefox_ghostery_com-browser-action"
                "_${getId addons.bitwarden.addonId}_-browser-action" # bitwarden
                "reset-pbm-toolbar-button"
                "unified-extensions-button"
            ];
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
                        urls = [
                            {
                            template = "https://search.nixos.org/options";
                            params = [
                                { name = "type"; value = "packages"; }
                                { name = "query";   value = "{searchTerms}"; }
                            ];
                            }
                        ];
                        icon           = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
                        definedAliases = [ "@no" ];
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
                            params = [
                            { name = "search_query"; value = "{searchTerms}"; }
                            ];
                        }];
                        iconMapObj."16" = "file://${config.home.homeDirectory}/.mozilla/firefox/default/youtube-icon.svg";
                        definedAliases = [ "@yt" ];
                    };

                    bing.metaData.hidden = true;
                    google.metaData.hidden = true;
                    # ebay.metaData.hidden = true;
                };
                order = [
                    "ddg"
                    "qwant"
                    "Nix Packages"
                    "NixOS Options"
                    "NixOS Wiki"
                    "youtube"
                ];
                privateDefault = "qwant";
            };
        };
    };
  };
  home.file.".mozilla/firefox/default/permissions.sqlite".source = ./permissions.sqlite;
  home.file.".mozilla/firefox/default/youtube-icon.svg".source = ./youtube-icon.svg;
  home.sessionVariables = {
    MOZ_USE_XINPUT2 = "1";
  };
  home.packages = [
    pkgs-unstable.firefoxpwa
  ];
}
