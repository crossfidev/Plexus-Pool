#! /bin/sh

## `ocaml-version` should be in sync with `README.rst` and
## `lib.protocol-compiler/mineplex-protocol-compiler.opam`

ocaml_version=4.09.1
opam_version=2.1

## Please update `.gitlab-ci.yml` accordingly
## full_opam_repository is a commit hash of the public OPAM repository, i.e.
## https://github.com/ocaml/opam-repository
full_opam_repository_tag=ab47b82abdc03e43c67b45b714806ca4d43d7091

## opam_repository is an additional, mineplex-specific opam repository.
opam_repository_tag=3718dd48d5e502c0fe8fc64ed4bf6b0c8040fadc
opam_repository_url=https://gitlab.com/mineplex/opam-repository.git
opam_repository=$opam_repository_url\#$opam_repository_tag

## Other variables, used both in Makefile and scripts
COVERAGE_OUTPUT=_coverage_output
