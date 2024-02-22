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

          legacyPackages =
            horizon-platform.legacyPackages.${system}.extend myOverlay;

        in {

          devShells.default =
            legacyPackages.horizon-minimal-template.env.overrideAttrs (attrs: {
              buildInputs = attrs.buildInputs ++ [
                legacyPackages.cabal-install
                legacyPackages.fast-downward
              ];
            });

          packages.default = legacyPackages.horizon-minimal-template;

        };
    };
}
