# RTK (Rust Token Killer) — prebuilt release binary from github.com/rtk-ai/rtk
final: prev: {
  rtk = prev.stdenv.mkDerivation rec {
    pname = "rtk";
    version = "0.42.4";
    src = prev.fetchurl {
      url = "https://github.com/rtk-ai/rtk/releases/download/v${version}/rtk-x86_64-unknown-linux-musl.tar.gz";
      hash = "sha256-NJdRFtoR4J5QJQHa91gUPgsi7TpCoQ62f7aTpicNnjY=";
    };
    unpackPhase = ''
      runHook preUnpack
      tar xf $src
      sourceRoot="."
      runHook postUnpack
    '';
    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin
      install -m755 rtk $out/bin/rtk
      runHook postInstall
    '';
    meta = with prev.lib; {
      description = "CLI proxy that reduces LLM token consumption on dev commands";
      homepage = "https://github.com/rtk-ai/rtk";
      license = licenses.asl20;
      platforms = [ "x86_64-linux" ];
      sourceProvenance = with prev.lib.sourceTypes; [ binaryNativeCode ];
    };
  };
}
