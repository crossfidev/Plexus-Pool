ARG BASE_IMAGE=registry.gitlab.com/tezos/opam-repository
ARG BASE_IMAGE_VERSION
FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION}
# do not move the ARG below above the FROM or it gets erased
ARG GIT_SHORTREF

# RUN sudo apk --no-cache add shadow
# RUN sudo adduser -S mineplex

# RUN sudo usermod -l mineplex -m -d /home/mineplex tezos
# RUN sudo chown -R mineplex /var/run/mineplex

# USER mineplex



WORKDIR /home/tezos
RUN mkdir -p /home/tezos/mineplex/scripts
COPY --chown=tezos:nogroup Makefile mineplex
COPY --chown=tezos:nogroup active_protocol_versions mineplex
COPY --chown=tezos:nogroup scripts/version.sh mineplex/scripts/
COPY --chown=tezos:nogroup src mineplex/src
COPY --chown=tezos:nogroup vendors mineplex/vendors
ENV GIT_SHORTREF=${GIT_SHORTREF}

RUN opam exec --debug -- make -C mineplex all
