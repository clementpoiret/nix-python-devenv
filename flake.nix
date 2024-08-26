{
  description = "Template of a Python project managed by uv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs-python.url = "github:cachix/nixpkgs-python";
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ inputs.devenv.flakeModule ];
      flake = {
        nixConfig = {
          extra-substituters = [
            "https://nixpkgs-python.cachix.org"
            "https://cuda-maintainers.cachix.org"
            "https://devenv.cachix.org"
          ];
          extra-trusted-public-keys = [
            "nixpkgs-python.cachix.org-1:hxjI7pFxTyuTHn2NkvWCrAUcNZLNS3ZAvfYNuYifcEU="
            "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
            "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
          ];
        };
      };
      systems = [ "x86_64-linux" ];
      perSystem = { config, self', inputs', pkgs, lib, system, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          # overlays = [
          #   inputs.poetry2nix.overlays.default
          #   (final: prev: { inherit (inputs.nixpkgs-stable) skopeo; })
          # ];
          config = {
            allowUnfree = true;
            cudaSupport = true;
          };
        };
        devenv.shells.default = let
          buildInputs = with pkgs; [
            cudaPackages.cudatoolkit
            cudaPackages.cudnn
            cudaPackages.cuda_cudart
            pythonManylinuxPackages.manylinux2014Package
            stdenv.cc.cc
            zlib
          ];
        in {
          containers.default = {
            name = "jimmy";
            startupCommand = "bash";
            copyToRoot = null;
          };
          env = {
            LD_LIBRARY_PATH = "${
                with pkgs;
                lib.makeLibraryPath buildInputs
              }:/run/opengl-driver/lib:/run/opengl-driver-32/lib";
            XLA_FLAGS =
              "--xla_gpu_cuda_data_dir=${pkgs.cudaPackages.cudatoolkit}"; # For tensorflow with GPU support
          };
          packages = with pkgs; [ bashInteractive uv ];

          enterShell = ''
            uv sync --extra cuda12
            . .venv/bin/activate
          '';

          languages.python = {
            enable = true;
            manylinux.enable = false;
            package = pkgs.python312;
            uv = { enable = true; };
          };
        };
      };
    };
}
