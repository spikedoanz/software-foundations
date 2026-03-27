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

        vscoq-legacy = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
          mktplcRef = {
            name = "vscoq1";
            publisher = "coq-community";
            version = "0.5.0";
            hash = "sha256-aahmggiDaw+tuzneNfyYTGvpRUfO+QxvvJOhgqoddJQ=";
          };
        };

        extensions = [
          vscoq-legacy
          pkgs.vscode-extensions.vscodevim.vim
        ];

        extensionDir = pkgs.linkFarm "vscodium-extensions" (map (ext: {
          name = "${ext.vscodeExtPublisher}.${ext.vscodeExtName}";
          path = "${ext}/share/vscode/extensions/${ext.vscodeExtUniqueId}";
        }) extensions);

        userSettings = ./. + "/.vscode/settings.json";
        userKeybindings = ./. + "/.vscode/keybindings.json";
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            coq
            coqPackages.stdlib
            coqPackages.dpdgraph
            graphviz
            vscodium
          ];

          shellHook = ''
            export ROCQPATH="${pkgs.coqPackages.stdlib}/lib/coq/${pkgs.coq.coq-version}/user-contrib:${pkgs.coqPackages.dpdgraph}/lib/coq/${pkgs.coq.coq-version}/user-contrib''${ROCQPATH:+:$ROCQPATH}"
            export OCAMLPATH="$(find ${pkgs.coqPackages.dpdgraph}/lib/ocaml -name site-lib -type d 2>/dev/null | head -1)''${OCAMLPATH:+:$OCAMLPATH}"
            echo "Rocq $(rocq --version 2>/dev/null || coqc --version | head -1)"

            # Set up VSCodium user data with Nix-managed settings
            export CODIUM_DATA="$PWD/.vscode/user-data"
            export CODIUM_EXTENSIONS="$PWD/.vscode/extensions"
            mkdir -p "$CODIUM_DATA/User" "$CODIUM_EXTENSIONS"
            cp -f "${userSettings}" "$CODIUM_DATA/User/settings.json"
            cp -f "${userKeybindings}" "$CODIUM_DATA/User/keybindings.json"

            # Symlink Nix-managed extensions into mutable dir
            for ext in "${extensionDir}"/*; do
              ln -sfn "$ext" "$CODIUM_EXTENSIONS/$(basename "$ext")"
            done

            codium() {
              command codium --user-data-dir "$CODIUM_DATA" --extensions-dir "$CODIUM_EXTENSIONS" "$@"
            }
            export -f codium

            echo "Run 'codium .' to launch VSCodium with VsCoq Legacy"
          '';
        };
      }
    );
}
