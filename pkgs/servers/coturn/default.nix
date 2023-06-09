{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, openssl
, libevent
, pkg-config
, libprom
, libpromhttp
, libmicrohttpd
, sqlite
, nixosTests
}:

stdenv.mkDerivation rec {
  pname = "coturn";
  version = "4.6.0";

  src = fetchFromGitHub {
    owner = "coturn";
    repo = "coturn";
    rev = version;
    sha256 = "sha256-QXApGJme/uteeKS8oiVLPOYUKzxTKdSC4WMlKS0VW5Q=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [
    openssl
    (libevent.override { inherit openssl; })
    libprom
    libpromhttp
    libmicrohttpd
    sqlite.dev
  ];

  patches = [
    ./pure-configure.patch

    # fix build against openssl 3.x
    (fetchpatch {
      url = "https://github.com/coturn/coturn/commit/4ce784a8781ab086c150e2b9f5641b1a37fd9b31.patch";
      hash = "sha256-Jx8XNXrgq0ockm1zjwRzfvSS3fVrVyVvQY1l0CpcR3Q=";
    })
  ];

  # Workaround build failure on -fno-common toolchains like upstream
  # gcc-10. Otherwise build fails as:
  #   ld: ...-libprom-0.1.1/include/prom_collector_registry.h:37: multiple definition of
  #     `PROM_COLLECTOR_REGISTRY_DEFAULT'; ...-libprom-0.1.1/include/prom_collector_registry.h:37: first defined here
  # Should be fixed in libprom-1.2.0 and later: https://github.com/digitalocean/prometheus-client-c/pull/25
  NIX_CFLAGS_COMPILE = "-fcommon";

  passthru.tests.coturn = nixosTests.coturn;

  meta = with lib; {
    homepage = "https://coturn.net/";
    license = with licenses; [ bsd3 ];
    description = "A TURN server";
    platforms = platforms.all;
    broken = stdenv.isDarwin; # 2018-10-21
    maintainers = with maintainers; [ ralith _0x4A6F ];
  };
}
