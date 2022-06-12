{
  description = "A flake for installing these scripts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  };

  outputs = { self, nixpkgs, unstable, nur, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
          inherit (self) overlays;
        });

    in
    {
      overlays = [
        (final: prev: {
          unstable = unstable.legacyPackages.${final.system};
          colorpicker-ym1234 = prev.colorpicker.overrideAttrs (o: {
            src = prev.fetchFromGitHub {
              owner = "ym1234";
              repo = "colorpicker";
              rev = "3b5076f5bb3392830e7d1d97fa86621ca19c4d1a";
              sha256 = "lt8l387Kc3RGCTEcE+zIf0sXdLrmVVu3L6qhhSlEQ2Q=";
            };
          });
        })
        nur.overlay
      ];
      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in
        {
          scripts = pkgs.callPackage self {
            inherit self;
            inherit (pkgs.unstable) yt-dlp-light imagemagick_light;
            inherit (pkgs.nur.repos.kira-bruneau) rofi-wayland;
          };
          default = self.packages.${system}.scripts;
        });
      defaultPackage = forAllSystems (system: self.packages.${system}.scripts);
    };
}
