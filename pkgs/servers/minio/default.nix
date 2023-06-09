{ lib, buildGoModule, fetchFromGitHub, nixosTests, fetchpatch }:

let
  # The web client verifies, that the server version is a valid datetime string:
  # https://github.com/minio/minio/blob/3a0e7347cad25c60b2e51ff3194588b34d9e424c/browser/app/js/web.js#L51-L53
  #
  # Example:
  #   versionToTimestamp "2021-04-22T15-44-28Z"
  #   => "2021-04-22T15:44:28Z"
  versionToTimestamp = version:
    let
      splitTS = builtins.elemAt (builtins.split "(.*)(T.*)" version) 1;
    in
    builtins.concatStringsSep "" [ (builtins.elemAt splitTS 0) (builtins.replaceStrings [ "-" ] [ ":" ] (builtins.elemAt splitTS 1)) ];
in
buildGoModule rec {
  pname = "minio";
  version = "2022-10-24T18-35-07Z";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "minio";
    rev = "RELEASE.${version}";
    sha256 = "sha256-sABNzhyfBNU5pWyE/VWHUzuSyKsx0glj01ectJPakV8=";
  };

  patches = [
    (fetchpatch {
      name = "CVE-2023-25812.patch";
      url = "https://github.com/minio/minio/commit/a7188bc9d0f0a5ae05aaf1b8126bcd3cb3fdc485.patch";
      sha256 = "sha256-9y7cua6r2hp+cK+rn2b4FMbHbmVXudFTt8ZffUEpkMQ=";
    })
    (fetchpatch {
      name = "CVE-2023-28432.patch";
      url = "https://github.com/minio/minio/commit/3b5dbf90468b874e99253d241d16d175c2454077.patch";
      sha256 = "sha256-tYMMyv8fi1Nu8uSVZV2GT8m74FX2DN+7Ljg6GQK2VXY=";
    })
    (fetchpatch {
      name = "CVE-2023-28434.patch";
      url = "https://github.com/minio/minio/commit/67f4ba154a27a1b06e48bfabda38355a010dfca5.patch";
      sha256 = "sha256-7XQ4jIUldhIqhN4fV8qhf6NVKh+oC0Rxc98T7GlonmE=";
    })
  ];

  vendorSha256 = "sha256-wB3UiuptT6D0CIUlHC1d5k0rjIxNeh5yAWOmYpyLGmA=";

  doCheck = false;

  subPackages = [ "." ];

  CGO_ENABLED = 0;

  tags = [ "kqueue" ];

  ldflags = let t = "github.com/minio/minio/cmd"; in [
    "-s" "-w" "-X ${t}.Version=${versionToTimestamp version}" "-X ${t}.ReleaseTag=RELEASE.${version}" "-X ${t}.CommitID=${src.rev}"
  ];

  passthru.tests.minio = nixosTests.minio;

  meta = with lib; {
    homepage = "https://www.minio.io/";
    description = "An S3-compatible object storage server";
    changelog = "https://github.com/minio/minio/releases/tag/RELEASE.${version}";
    maintainers = with maintainers; [ eelco bachp ];
    platforms = platforms.unix;
    license = licenses.agpl3Plus;
  };
}
