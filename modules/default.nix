{
  self,
  config,
  lib,
  mkJupyterlab,
  system,
  ...
}: let
  types = lib.types;
in {
  options = {
    # jupyterlabEnvArgs ? {},
    # kernels ? k: [], # k: [ (k.python {}) k.bash ],
    # # extensions ? e: [], # e: [ e.jupy-ext ]

    jupyterlab = {
      runtimePackages = lib.mkOption {
        type = types.listOf types.package;
        description = "A list of runtime packages available to all binaries";
        default = [];
      };
    };

    # flakes ? [], # flakes where to detect custom kernels/extensions

    build = lib.mkOption {
      type = types.package;
      internal = true;
    };

    nixpkgs = import ./types/nixpkgs.nix {inherit lib self system;};
  };

  imports = [
    ./../modules/kernels/bash/module.nix
    ./../modules/kernels/c/module.nix
    ./../modules/kernels/elm/module.nix
    ./../modules/kernels/go/module.nix
    ./../modules/kernels/haskell/module.nix
    ./../modules/kernels/javascript/module.nix
    ./../modules/kernels/julia/module.nix
    ./../modules/kernels/nix/module.nix
    ./../modules/kernels/ocaml/module.nix
    ./../modules/kernels/postgres/module.nix
    ./../modules/kernels/python/module.nix
    ./../modules/kernels/r/module.nix
    ./../modules/kernels/rust/module.nix
    ./../modules/kernels/scala/module.nix
    ./../modules/kernels/typescript/module.nix
    ./../modules/kernels/zsh/module.nix
  ];
  # TODO: add kernels
  #++ map (name: ./. + "/../modules/kernels/${name}/module.nix") (builtins.attrNames (builtins.readDir ./../modules/kernels));

  config = {
    build = mkJupyterlab {
      #jupyterlabEnvArgs = config.jupyterlabEnvArgs;
      kernels = availableKernels:
        lib.flatten
        (
          builtins.map
          (
            kernelTypeName:
              builtins.map
              (
                kernelName:
                  availableKernels.${kernelTypeName}
                  config.kernel.${kernelTypeName}.${kernelName}.kernelArgs
              )
              (builtins.attrNames config.kernel.${kernelTypeName})
          )
          (builtins.attrNames config.kernel)
        );
      runtimePackages = config.jupyterlab.runtimePackages;
      #flakes = config.flakes;
    };
    _module.args.pkgs = config.nixpkgs;
  };
}
