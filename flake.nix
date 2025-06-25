{
  description = "Hexagonal chess";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      perSystem =

        { pkgs, ... }:
        {
          formatter = pkgs.nixfmt-rfc-style;

          devShells.default = pkgs.mkShell {
            shellHook = "unset SOURCE_DATE_EPOCH";
            packages = [
              # Shortcuts for compiling
              pkgs.just

              # Main tool
              pkgs.typst

              # LSPs for writing
              pkgs.marksman
              pkgs.typos-lsp
              pkgs.tinymist
              pkgs.typstyle # typst formatter
              pkgs.harper

              # For presenting
              pkgs.pympress

              # Font
              pkgs.lora
              pkgs.scientifica
            ];
          };

        };
    };
}
