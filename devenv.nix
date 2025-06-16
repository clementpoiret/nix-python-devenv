{
  pkgs,
  lib,
  ...
}:
let
  buildInputs = with pkgs; [
    cudaPackages.cuda_cudart
    cudaPackages.cudatoolkit
    cudaPackages.cudnn
    stdenv.cc.cc
    libuv
    zlib
  ];
in
{
  packages = with pkgs; [
    cudaPackages.cuda_nvcc
  ];

  env = {
    LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}:/run/opengl-driver/lib:/run/opengl-driver-32/lib";
    XLA_FLAGS = "--xla_gpu_cuda_data_dir=${pkgs.cudaPackages.cudatoolkit}"; # For tensorflow with GPU support
    CUDA_PATH = pkgs.cudaPackages.cudatoolkit;
  };

  languages.python = {
    enable = true;
    uv = {
      enable = true;
      sync.enable = true;
    };
  };

  scripts.hello.exec = "uv run python hello.py";

  enterShell = ''
    . .devenv/state/venv/bin/activate
    nvcc -V
    hello
  '';
}
