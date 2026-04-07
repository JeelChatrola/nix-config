# Pin llmfit newer than nixpkgs-unstable until upstream ships >= 0.9.2.
# Remove this overlay once `pkgs.llmfit.version` from unstable is 0.9.2 or higher.
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
    meta =
      prev.llmfit.meta
      // {
        changelog = "https://github.com/AlexsJones/llmfit/releases/tag/v${finalAttrs.version}";
      };
  });
}
