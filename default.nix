{ stdenv, autoreconfHook, fetchgit, git, pandoc, texlive }:

stdenv.mkDerivation rec {
  name = "glines.net-${version}";
  version = "0.0.3";

  buildInputs = [
    autoreconfHook
    git
    pandoc
    texlive.combined.scheme-full
  ];

  src = fetchgit {
    url = "file:///home/auntieneo/code/website/";
    rev = "refs/tags/${version}";
    sha256 = "1ygyw3sph11i0yqhir4hw588vw7rq9f8ygy60csy78awp7chdlrf";
  };
}
