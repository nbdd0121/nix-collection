{
  config,
  lib,
  pkgs,
  ...
}:
{
  options.security.pki.selectiveTrust = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          certificateFile = lib.mkOption {
            type = lib.types.path;
            description = ''
              Path to the (self-signed) root certificate of the CA
            '';
          };

          domains = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            description = ''
              Domains to trust this root certificate for.
            '';
          };
        };
      }
    );
  };

  config = {
    security.pki.certificateFiles = lib.mapAttrsToList (
      name: value:
      let
        drv = pkgs.runCommand "${name}.crt" { } ''
          echo "nameConstraints = critical, ${
            lib.concatStringsSep ", " (map (d: "permitted;DNS:${d}") value.domains)
          }" > ext
          ${lib.getExe pkgs.openssl} x509 -in ${value.certificateFile} -CA ${./root.pem} -CAkey ${./root.key} -out $out -extfile ext
        '';
      in
      "${drv}"
    ) config.security.pki.selectiveTrust;
  };
}
