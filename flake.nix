{
  description = "Coq dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            coq
            coqPackages.stdlib
            coqPackages.vscoq-language-server
          ];

          shellHook = ''
            export ROCQPATH="${pkgs.coqPackages.stdlib}/lib/coq/${pkgs.coq.coq-version}/user-contrib''${ROCQPATH:+:$ROCQPATH}"
            echo "Rocq $(coqc --version | head -1)"
          '';
        };
      }
    );
}
