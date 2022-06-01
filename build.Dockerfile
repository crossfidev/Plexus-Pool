ARG BASE_IMAGE=registry.gitlab.com/mineplex/opam-repository
ARG BASE_IMAGE_VERSION
FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION}
# do not move the ARG below above the FROM or it gets erased
ARG GIT_SHORTREF
WORKDIR /home/mineplex
RUN mkdir -p /home/mineplex/mineplex/scripts
COPY --chown=mineplex:nogroup Makefile mineplex
COPY --chown=mineplex:nogroup active_protocol_versions mineplex
COPY --chown=mineplex:nogroup scripts/version.sh mineplex/scripts/
COPY --chown=mineplex:nogroup src mineplex/src
COPY --chown=mineplex:nogroup vendors mineplex/vendors
ENV GIT_SHORTREF=${GIT_SHORTREF}
RUN opam exec -- make -C mineplex all build-test
