{ lib, rustPlatform, sources }:

rustPlatform.buildRustPackage rec {
  inherit (sources.kickoff) pname version src;

  #cargoSha256 = lib.fakeSha256;
  cargoHash = "sha256-OiAChKE6hwfUtAKlzZZEC/3jcLn2nb251lGJIKnVDvw=";

  #  nativeBuildInputs = [ pkg-config ];

  #  buildInputs = [ openssl ] ++ lib.optionals stdenv.isDarwin [ Security libiconv ];

  #  checkType = "debug";

  #  passthru.updateScript = ./update.sh;

  # checkFlags = [
  #   "--skip commands::upgrade::upgrade_tests"
  #   "--skip allowed_hosts::tests::creating_a_new_host_store"
  #   "--skip allowed_hosts::tests::getting_the_domain_root"
  #   "--skip allowed_hosts::tests::requests_to_allowed_hosts"
  #   "--skip allowed_hosts::tests::requests_to_unknown_hosts"
  # ];

  meta = with lib; {
    description = "Wayland launcher";
    longDescription = ''
      Wayland Launcher
    '';
    homepage = "https://github.com/j0ry/kickoff";
    license = licenses.gpl3;
    maintainers = [ maintainers.tgunnoe ];
    platforms = platforms.all;
  };
}
