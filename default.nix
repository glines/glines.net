{ stdenv, autoreconfHook, fetchgit, pandoc, rsync, texlive }:

stdenv.mkDerivation rec {
  name = "glines.net-${version}";
  version = "0.0.3";

  buildInputs = [
    autoreconfHook
    pandoc
    rsync
    texlive.combined.scheme-full
  ];

  src = fetchgit {
    url = "file:///home/auntieneo/code/website/";
    rev = "refs/tags/master";
    sha256 = "0bir87dg4sd0gni9za8j4yma5qxp4cvip3kfzaqgic5scmhl6bsp";
    fetchSubmodules = true;
  };

  installPhase = ''
    mkdir -p "$out"
    cp -R glines.net-${version}/* "$out"
  '';
}
