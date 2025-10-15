# Nix derivation for psp_at3tool.exe; outputs an ELF binary named psp-at3tool
# Usage:
#   nix-store --add-fixed sha256 psp_at3tool.exe
#   cd atrac3-encoder-linux  # (the path of this repo)
#   nix-build  # build ELF without installing
#   nix-env -f . -i  # install, building if not already built

{ pkgs ? import <nixpkgs> {} }:
let psp-at3tool-exe = pkgs.requireFile {
  name = "psp_at3tool.exe";
  message = ''
    psp_at3tool.exe must be in the Nix store before building this derivation.
    Add it to the nix store with this command:
      nix-store --add-fixed sha256 psp_at3tool.exe
  '';
  hash = "sha256-gjGZETxZ/80/w+GFXbuIqc1E0p6C56fPxC6MkvKmE0E=";
};
in with pkgs;
pkgsi686Linux.stdenv.mkDerivation {
  pname = "psp-at3tool";
  version = "2.0.0.0";
  src = builtins.path {
    name = "psp-at3tool-src";
    path = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./convert.sh
        ./linker.ld
        ./loader.S
        ./sections.diff
      ];
    };
  };
  nativeBuildInputs = [ hexdump nasm ];
  buildPhase = ''
    runHook preBuild

    cp ${psp-at3tool-exe} ./psp_at3tool.exe
    bash convert.sh

    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    install -Dm 755 psp_at3tool.exe.elf $out/bin/psp-at3tool

    runHook postInstall
  '';
}
