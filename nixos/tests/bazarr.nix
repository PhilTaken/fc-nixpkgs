import ./make-test-python.nix ({ lib, ... }:

with lib;

let
  port = 42069;
in
{
  name = "bazarr";
  meta.maintainers = with maintainers; [ d-xo ];

  nodes.machine =
    { pkgs, ... }:
    {
      services.bazarr = {
        enable = true;
        listenPort = port;
      };
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) ["unrar"];
    };

  testScript = ''
    machine.wait_for_unit("bazarr.service")
    machine.wait_for_open_port(${toString port})
    machine.succeed("curl --fail http://localhost:${toString port}/")
  '';
})
