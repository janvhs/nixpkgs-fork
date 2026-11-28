{
  lib,
  rustPlatform,

  fetchFromGitHub,
  git,
  pkg-config,
  aws-lc,
  beamPackages,
  nodejs,
  bun,
  deno,
  versionCheckHook,
  nix-update-script,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gleam";
  version = "1.19.2";

  src = fetchFromGitHub {
    owner = "gleam-lang";
    repo = "gleam";
    tag = "v${finalAttrs.version}";
    hash = "sha256-L7M1/nGDiB4D+yX1cjQ7mqNQ7YuC1BctLXEvnNjPz7A=";
  };

  cargoPatches = [
    # Upgrade the zip crate to at least version 9.1 due to several CVEs
    ./fix-for-CVE-2026-115905.patch
    # Upgrade the Cargo lock file, because of the Nix offline builds
    ./fix-for-CVE-2026-115905-cargoDeps.patch
  ];

  cargoHash = "sha256-BPp86e7TAEZb8iEFmqewqDna3Xf3tcZooO9iTfQA9q0=";

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [ aws-lc ];

  nativeCheckInputs = [
    # used by several tests
    git

    # erlang runtime is used for integration tests
    beamPackages.erlang

    # js runtimes used for integration tests
    nodejs
    bun
    deno

    writableTmpDirAsHomeHook
  ];

  checkFlags = [
    # These tests make network requests
    "--skip=tests::output::echo_dict"
    "--skip=tests::escript_success_with_dependency"
    # checks files that would be gitignored, but we're not in a git repo
    "--skip=tests::all_files_have_copyright_notice"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Statically typed language for the Erlang VM and JavaScript";
    mainProgram = "gleam";
    homepage = "https://gleam.run/";
    changelog = "https://github.com/gleam-lang/gleam/blob/v${finalAttrs.version}/changelog/v${lib.versions.majorMinor finalAttrs.version}.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [
      philtaken
      llakala
      ginkogruen
    ];
    teams = [ lib.teams.beam ];
  };
})
