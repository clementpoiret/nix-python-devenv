# Nix Python Devenv

Simple template to setup [devenv](https://devenv.sh), with CUDA support,
and a python venv managed by [uv](https://docs.astral.sh/uv/)

## Installation

**Step 1**: Install [Nix](https://nixos.org/download/):
`sh <(curl -L https://nixos.org/nix/install) --daemon`

**Step 2**: Enter development environment: `nix develop --impure`

That's it :)

If you want something even easier, install [direnv](https://direnv.net/) and
allow it to automatically activate the current env (`direnv allow`).
