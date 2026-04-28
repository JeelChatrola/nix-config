# Pin llmfit 0.9.2 from upstream. Many nixpkgs revisions no longer expose pkgs.llmfit,
# so we define metadata here instead of inheriting prev.llmfit.meta.

final: prev: {
  llmfit = prev.rustPlatform.buildRustPackage (finalAttrs: {
    pname = "llmfit";
    version = "0.9.2";
    src = prev.fetchFromGitHub {
      owner = "AlexsJones";
      repo = "llmfit";
      tag = "v${finalAttrs.version}";
      hash = "sha256-ZRICjMj3/kdturKAOYdnujMVH35O+Ojq2/eh5pj+ahM=";
    };
    cargoHash = "sha256-Df7MmVReTO+3MvAJ2wyUTgmeFH/ZX/sPfOADllslUy4=";
    meta = with prev.lib; {
      description = "LLM fitness / benchmarking CLI";
      homepage = "https://github.com/AlexsJones/llmfit";
      changelog = "https://github.com/AlexsJones/llmfit/releases/tag/v${finalAttrs.version}";
      license = licenses.mit;
      maintainers = [ ];
      platforms = platforms.all;
    };
  });
}
