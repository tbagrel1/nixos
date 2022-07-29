# A trial to create Jetbrains Toolbox package

{ pkgs ? import <nixpkgs> {} }:

let

  name = "jetbrains-toolbox";
  version = "1.24.11947";
  sha256 = "8c794479e8fcab8874ace823b095b893f3e149ae1abbe480c20b712e7fc2ee38";


  jt = pkgs.stdenv.mkDerivation {
        inherit name version sha256;

        src = pkgs.fetchurl {
          url = "https://download.jetbrains.com/toolbox/${name}-${version}.tar.gz";
          sha256 = "${sha256}";
        };

        buildInputs = [ pkgs.makeWrapper ];

        buildCommand = ''
            mkdir -p "$out/lib/jetbrains-toolbox" "$out/bin"
            tar -zxf "$src" -C "$out/lib/jetbrains-toolbox" --strip-components 1

            ln -s "$out/lib/jetbrains-toolbox/jetbrains-toolbox" "$out/bin"

            fixupPhase

            patchelf \
            --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
            --set-rpath "${pkgs.lib.makeLibraryPath [pkgs.fuse pkgs.libcef pkgs.xorg.libX11 pkgs.xorg.libxcb pkgs.xorg.xcbutilkeysyms pkgs.xorg.libXrandr ]}:$out/lib/jetbrains-toolbox" \
            "$out/lib/jetbrains-toolbox/jetbrains-toolbox"
        '';
    };

in pkgs.buildFHSUserEnv {
    name = "jetbrains-toolbox";

    targetPkgs = pkgs: [
      jt
      pkgs.zlib
    ];
    
    runScript = "jetbrains-toolbox";
}
