{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchPnpmDeps,
  nodejs,
  pnpm_9,
  pnpmConfigHook,
  makeWrapper,
}:

let
  pname = "yepanywhere";
  version = "0.4.9";

  src = fetchFromGitHub {
    owner = "kzahel";
    repo = "yepanywhere";
    rev = "v${version}";
    hash = "sha256-CGda5IoeCwo3xh9znKJZloARDrnapS2nWanovqtWzhA=";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    nodejs
    pnpm_9
    pnpmConfigHook
    makeWrapper
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    pnpm = pnpm_9;
    hash = "sha256-B9dRKYJ3fm9+GbDtEdkH9SNeptxg5RdEOcp8ibNyBNs=";
    fetcherVersion = 3;
  };

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/yepanywhere $out/bin

    cp -r packages $out/lib/yepanywhere/
    cp -r node_modules $out/lib/yepanywhere/
    cp package.json $out/lib/yepanywhere/

    makeWrapper ${nodejs}/bin/node $out/bin/yepanywhere \
      --add-flags "$out/lib/yepanywhere/packages/server/dist/index.js" \
      --set NODE_ENV production

    runHook postInstall
  '';

  meta = {
    description = "ACP wrapper providing a web UI for remote Claude Code sessions";
    homepage = "https://github.com/kzahel/yepanywhere";
    license = lib.licenses.mit;
    # TODO
    maintainers = [ ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "yepanywhere";
  };
}
