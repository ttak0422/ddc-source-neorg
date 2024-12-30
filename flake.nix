{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks.url = "github:cachix/git-hooks.nix";

    neorg-overlay.url = "github:nvim-neorg/nixpkgs-neorg-overlay";
    denops-vim = {
      url = "github:vim-denops/denops.vim";
      flake = false;
    };
    ddc-vim = {
      url = "github:Shougo/ddc.vim";
      flake = false;
    };
    ddc-ui-native = {
      url = "github:Shougo/ddc-ui-native";
      flake = false;
    };
    ddc-source-around = {
      url = "github:Shougo/ddc-source-around";
      flake = false;
    };
    ddc-filter-matcher_head = {
      url = "github:Shougo/ddc-filter-matcher_head";
      flake = false;
    };
    ddc-filter-sorter_rank = {
      url = "github:Shougo/ddc-filter-sorter_rank";
      flake = false;
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (_: {
      systems = import inputs.systems;
      perSystem =
        {
          self',
          system,
          pkgs,
          lib,
          ...
        }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = with inputs; [ neorg-overlay.overlays.default ] ++ (import ./nix/overlay.nix inputs);
          };
          checks = {
            pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
              src = ./.;
              hooks = {
                nixfmt-rfc-style.enable = true;
                statix.enable = true;
                deadnix.enable = true;
                luacheck = {
                  enable = true;
                  excludes = [ "lua/ddc_source_neorg/init.lua" ];
                };
                stylua = {
                  enable = true;
                  excludes = [ "lua/ddc_source_neorg/init.lua" ];
                };
                denofmt.enable = true;
                denolint.enable = true;
                fnlfmt = {
                  enable = true;
                  name = "fnlfmt";
                  entry = "${pkgs.fnlfmt}/bin/fnlfmt";
                  files = "\\.fnl$";
                };
              };
            };
          };
          # for apps
          packages.ddc-source-neorg = pkgs.vimUtils.buildVimPlugin {
            name = "ddc-source-neorg";
            src = lib.cleanSource ./.;
            dontBuild = true;
            buildInputs = with pkgs; [ deno ];
          };
          apps = import ./nix/app.nix { inherit self' pkgs; };
          devShells.default = pkgs.mkShell {
            inherit (self'.checks.pre-commit-check) shellHook;
            packages = [ ];
          };
        };
    });
}
