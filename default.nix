{ system ? builtins.currentSystem
, pkgs ? import <nixpkgs> { inherit system; }
}:
let
  callPackage = pkgs.lib.callPackageWith (pkgs // self);

  self = rec {
    nimrod-portal-backend = callPackage ./pkgs/nimrod-portal-backend { jre = pkgs.openjdk11_headless; };

    portal-client = callPackage ./pkgs/portal-client { jre = pkgs.openjdk11_headless; };

    nimrodg-agent = callPackage ./pkgs/nimrodg-agent { };

    nimrun = callPackage ./pkgs/nimrun { };

    nimptool-legacy = callPackage ./pkgs/nimptool-legacy { };

    ims2tif = callPackage ./pkgs/ims2tif { };

    imsmeta = callPackage ./pkgs/imsmeta { };

    containers = {
      nimrod-portal-backend = callPackage ./containers/nimrod-portal-backend {};

      portal-client = callPackage ./containers/portal-client {};
    };

    hpc = rec {
      nimrod-embedded = callPackage ./hpc/nimrod-embedded {
        nimrun        = pkgsStatic.nimrun;
        installPrefix = "/sw7/RCC/NimrodG";
        modulePath    = "/sw7/Modules/RCC/local";
      };

      nimrod-embedded-usq = nimrod-embedded.override rec {
        moduleName    = "nimrodg";
        modulePath    = "/usr/local/opt/modules";
        installPrefix = "/nonexistant";
        rootDir       = "/usr/local/opt/software/${moduleName}/${nimrod-embedded.version}";
      };
    };

    ##
    # NB: Not sure if this is the best way to do this.
    #
    # Also note that static cmake is completely broken.
    ##
    pkgsStatic = rec {
      callPackage = pkgs.lib.callPackageWith (pkgs.pkgsStatic // self.pkgsStatic);

      nimrun = callPackage ./pkgs/nimrun { cmake = pkgs.cmake; };

      # No static build for this, hdf5 is being hdf5 again...
      #ims2tif = callPackage ./pkgs/ims2tif { cmake = pkgs.cmake; };

      imsmeta = callPackage ./pkgs/imsmeta { cmake = pkgs.cmake; };
    };
  };
in
self
