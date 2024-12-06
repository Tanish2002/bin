{
  description = "A flake for installing these scripts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
  };

  outputs =
    { self
    , nixpkgs
    , nur
    , ...
    }:
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
        nur.overlay
      ];
      packages =
        forAllSystems
          (system:
            let
              pkgs = nixpkgsFor.${system};
            in
            {
              scripts =
                pkgs.callPackage self
                  {
                    inherit self;
                    ffmpeg = pkgs.ffmpeg.override {
                      withXcb = true;
                      withXcbShape = true;
                      withXcbShm = true;
                      withXcbxfixes = true;
                    };
                  };
              default = self.packages.${system}.scripts;
            });
      defaultPackage = forAllSystems (system: self.packages.${system}.scripts);
    };
}
