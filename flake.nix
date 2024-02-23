{
  description = "horizon-minimal-template";

  nixConfig = {
    extra-substituters = "https://horizon.cachix.org";
    extra-trusted-public-keys =
      "horizon.cachix.org-1:MeEEDRhRZTgv/FFGCv3479/dmJDfJ82G6kfUDxMSAw0=";
  };

  inputs = {

    flake-parts.url = "github:hercules-ci/flake-parts";

    horizon-platform.url =
      "git+https://gitlab.horizon-haskell.net/package-sets/horizon-platform";

    old_nixpkgs.url = "nixpkgs/nixos-20.09";

    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  };

  outputs = inputs@{ self, flake-parts, horizon-platform, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" "x86_64-darwin" "x86_64-linux" ];
      perSystem = { pkgs, system, ... }:
        let

          myOverlay = final: prev: {
            horizon-minimal-template =
              final.callCabal2nix "horizon-minimal-template" ./. { };
            fast-downward = pkgs.haskell.lib.doJailbreak
              (final.callHackage "fast-downward" "0.2.3.0" { });

          };
          oldpkgs = inputs.old_nixpkgs.legacyPackages.${system};
          legacyPackages =
            horizon-platform.legacyPackages.${system}.extend myOverlay;

        in {

          devShells.default =
            legacyPackages.horizon-minimal-template.env.overrideAttrs (attrs: {
              buildInputs = attrs.buildInputs ++ [
                legacyPackages.cabal-install
                (pkgs.fast-downward.overrideAttrs (old: {
                  name = "fast-downward-2019-05-13";

                  src = pkgs.fetchhg {
                    url = "http://hg.fast-downward.org/";
                    rev = "090f5df5d84a";
                    sha256 =
                      "14pcjz0jfzx5269axg66iq8js7lm2w3cnqrrhhwmz833prjp945g";
                  };

                }))
                pkgs.ponysay
              ];
            });

          packages.default = legacyPackages.horizon-minimal-template;

        };
    };
}
