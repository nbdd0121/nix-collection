{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.security.github-key-sync;
  usersCfg = lib.attrValues (
    lib.filterAttrs (name: user: user.github-key-sync != null) config.users.users
  );
in
{
  options = {
    security.github-key-sync = {
      enable = lib.mkEnableOption "SSH key synchronization from GitHub";

      user = lib.mkOption {
        type = lib.types.str;
        default = "root";
        description = ''
          User to run key synchronization command in.

          The user is not automatically created by setting this option.
        '';
      };

      dataDir = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/github-key-sync";
        description = "The data directory for github-key-sync.";
      };
    };

    users.users = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options.github-key-sync = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = ''
              GitHub username to sync authorized_keys from.
            '';
            example = "ghost";
          };
        }
      );
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # OpenSSH will complain about script not being "secure" because things in nix store is also
      # writable by nixbld users. So we add a script in /etc/ssh/github-key-auth which redirects to
      # the shell script.
      environment.etc."ssh/github-key-auth" =
        let
          script = pkgs.writeShellApplication {
            name = "github-key-sync";

            runtimeInputs = with pkgs; [
              coreutils
              findutils
              curl
              config.programs.ssh.package
            ];

            text = ''
              USER="$1"

              # Map Unix username to GitHub handle. Fail for unknown users.
              case "$USER" in
            ''
            + lib.concatStrings (
              map (user: ''
                "${user.name}")
                  HANDLE="${user.github-key-sync}"
                  ;;
              '') usersCfg
            )
            + ''
                *)
                    echo "Unknown user" >&2
                    exit 1;
                ;;
              esac

              TMP_FILE=
              tmp_cleanup() {
                rm -rf "$TMP_FILE"
              }
              trap tmp_cleanup EXIT

              # If there exists a cached file recently updated within 60 minutes, skip updating from GitHub.
              if ! test "$(find "${cfg.dataDir}/$USER" -mmin -60)"; then
                  # Fetch from GitHub, turn HTTP error into error status. Set a max timeout of 5 seconds.
                  # We then verify that it is a valid authorized_keys file with ssh-keygen and move it into place.
                  #
                  # If the step fails (e.g. GitHub server is down), don't terminate, but try to use the cached keys.
                  # SC complains that `A && B || true` is not if-then-else, but we're using `|| true` to prevent pipefail.
                  # shellcheck disable=SC2015
                  TMP_FILE=$(mktemp -p "${cfg.dataDir}") &&
                      curl -m 5 -sSLf "https://github.com/$HANDLE.keys" > "$TMP_FILE" &&
                      ssh-keygen -lf "$TMP_FILE" 1>&2 &&
                      mv "$TMP_FILE" "${cfg.dataDir}/$USER" || true
              fi

              cat "${cfg.dataDir}/$USER"
            '';
          };
        in
        {
          mode = "0555";
          text = ''
            #!${pkgs.stdenv.shell}
            exec ${script}/bin/github-key-sync "$@"
          '';
        };

      # Create the state directory.
      systemd.tmpfiles.settings."github-key-sync".${cfg.dataDir}.d = {
        mode = "0700";
        user = cfg.user;
      };

      services.openssh = {
        authorizedKeysCommand = "/etc/ssh/github-key-auth";
        authorizedKeysCommandUser = cfg.user;
      };
    })
    {
      assertions = [
        {
          assertion = usersCfg != [ ] -> cfg.enable;
          message = "`user.users.<name>.github-key-sync` is used, but `security.github-key-sync.enable = false;`";
        }
      ];
    }
  ];
}
