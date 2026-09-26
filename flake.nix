{
  description = "TUI clipboard picker for cliphist";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "cliphist-picker";
            version = "0.1.0";

            src = ./.;

            nativeBuildInputs = [
              pkgs.makeWrapper
            ];

            installPhase = ''
              mkdir -p $out/bin

              install -Dm755 src/cliphist-picker \
                $out/bin/cliphist-picker

              install -Dm755 src/cliphist-preview \
                $out/bin/cliphist-preview

              wrapProgram $out/bin/cliphist-picker \
                --prefix PATH : ${
                  pkgs.lib.makeBinPath [
                    pkgs.cliphist
                    pkgs.fzf
                    pkgs.wl-clipboard
                  ]
                }

              wrapProgram $out/bin/cliphist-preview \
                --prefix PATH : ${
                  pkgs.lib.makeBinPath [
                    pkgs.cliphist
                    pkgs.chafa
                    pkgs.file
                  ]
                }
            '';

            meta = {
              description = "TUI clipboard picker for cliphist with image preview";
              homepage = "https://github.com/mhkarimi1383/cliphist-picker";
              license = pkgs.lib.licenses.mit;
              platforms = pkgs.lib.platforms.linux;
              mainProgram = "cliphist-picker";
            };
          };
        });
    };
}
