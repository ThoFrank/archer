{ pkgs, lib, config, inputs, ... }:

{
  # https://devenv.sh/basics/
  env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = with pkgs;[
    libyaml
    sqlite
    inputs.nixpkgs-elm.legacyPackages.${pkgs.stdenv.hostPlatform.system}.elmPackages.elm
  ]
  ++ (with pkgs.elmPackages; [
    elm-language-server
    elm-format
    elm-test
  ])
  ++ lib.optionals pkgs.stdenv.isDarwin [ pkgs.libllvm ];

  # https://devenv.sh/languages/
  languages.ruby.enable = true;
  languages.ruby.versionFile = ./.ruby-version;
  languages.ruby.bundler.enable = true;
  languages.ruby.lsp.enable = true;

  # Ruby 3.3.6 headers trigger a Clang warning that makes Nokogiri's -Werror
  # checks reject the Gumbo include path on Darwin.
  # https://github.com/sparklemotion/nokogiri/pull/3653
  overlays = [(final: prev: lib.optionalAttrs prev.stdenv.hostPlatform.isDarwin {
    defaultGemConfig = prev.defaultGemConfig // {
      nokogiri = attrs:
        let original = prev.defaultGemConfig.nokogiri attrs;
        in original // {
          buildFlags = (original.buildFlags or []) ++ [
            "--with-cppflags=-Wno-default-const-init-field-unsafe"
          ];
        };
    };
  })];

  # https://devenv.sh/processes/
  # processes.cargo-watch.exec = "cargo-watch";

  # https://devenv.sh/services/
  # services.postgres.enable = true;

  # https://devenv.sh/scripts/
  # scripts.hello.exec = ''
  #   echo hello from $GREET
  # '';

  enterShell = ''
    bundle
  '';

  # https://devenv.sh/tasks/
  # tasks = {
  #   "myproj:setup".exec = "mytool build";
  #   "devenv:enterShell".after = [ "myproj:setup" ];
  # };

  # https://devenv.sh/tests/
  enterTest = ''
    echo "Running tests"
    git --version | grep --color=auto "${pkgs.git.version}"
  '';

  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # See full reference at https://devenv.sh/reference/options/
}
