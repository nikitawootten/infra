{
  pkgs ?
    let
      lock = (builtins.fromJSON (builtins.readFile ../../flake.lock)).nodes.nixpkgs.locked;
      nixpkgs = fetchTarball {
        url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
        sha256 = lock.narHash;
      };
    in
    import nixpkgs { },
  # Keep in sync with the source version
  electron ? pkgs.electron_41,
  ...
}:
let
  inherit (pkgs) lib;
  pname = "lotion";
  version = "1.6.0";
  debs = {
    x86_64-linux = {
      suffix = "amd64";
      hash = "sha256-S7yWiNbBxRJa3p3Kd+25kZSeyYNLRm0njt4odQEVXJU=";
    };
    aarch64-linux = {
      suffix = "arm64";
      hash = "sha256-Fg356Qdi9lZPLeBBUHj0Gfba/s2CUqa7kmq5VRDyp/w=";
    };
  };
  deb =
    debs.${pkgs.stdenv.hostPlatform.system}
      or (throw "lotion: unsupported system ${pkgs.stdenv.hostPlatform.system}");
in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = pkgs.fetchurl {
    url = "https://github.com/puneetsl/lotion/releases/download/v${version}/lotion_${version}_${deb.suffix}.deb";
    inherit (deb) hash;
  };

  nativeBuildInputs = with pkgs; [
    dpkg
    makeWrapper
  ];

  unpackPhase = ''
    dpkg-deb --fsys-tarfile $src | tar -x \
      ./usr/lib/lotion/resources/app.asar \
      ./usr/share/applications/lotion.desktop \
      ./usr/share/pixmaps/lotion.png
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 usr/lib/lotion/resources/app.asar $out/share/lotion/app.asar
    install -Dm644 usr/share/applications/lotion.desktop -t $out/share/applications
    install -Dm644 usr/share/pixmaps/lotion.png -t $out/share/pixmaps

    makeWrapper ${electron}/bin/electron $out/bin/${pname} \
      --add-flags $out/share/lotion/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-wayland-ime}}"

    runHook postInstall
  '';

  meta = {
    description = "Unofficial Notion.so desktop app for Linux";
    homepage = "https://github.com/puneetsl/lotion";
    license = lib.licenses.mit;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    platforms = lib.attrNames debs;
    mainProgram = pname;
  };
}
