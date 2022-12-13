{ lib, self, ... }:
let
  inherit (builtins) tofile readfile;
  inherit (lib) fileContents mkForce;
in
{
  age.secrets.root.file = "${self}/secrets/root.age";
  users.users.root.passwordFile = "/persist/agenix/root";
}
