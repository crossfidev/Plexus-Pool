ARG BASE_IMAGE
ARG BASE_IMAGE_VERSION
ARG BASE_IMAGE_VERSION_NON_MIN
ARG BUILD_IMAGE
ARG BUILD_IMAGE_VERSION

FROM ${BUILD_IMAGE}:${BUILD_IMAGE_VERSION} as builder


FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION} as intermediate
# Pull in built binaries
COPY --chown=mineplex:nogroup --from=builder /home/mineplex/mineplex/mineplex-baker-* /home/mineplex/bin/
COPY --chown=mineplex:nogroup --from=builder /home/mineplex/mineplex/mineplex-endorser-* /home/mineplex/bin/
COPY --chown=mineplex:nogroup --from=builder /home/mineplex/mineplex/mineplex-accuser-* /home/mineplex/bin/
COPY --chown=mineplex:nogroup --from=builder /home/mineplex/mineplex/mineplex-client /home/mineplex/bin/
COPY --chown=mineplex:nogroup --from=builder /home/mineplex/mineplex/mineplex-admin-client /home/mineplex/bin/
COPY --chown=mineplex:nogroup --from=builder /home/mineplex/mineplex/mineplex-node /home/mineplex/bin/
COPY --chown=mineplex:nogroup --from=builder /home/mineplex/mineplex/mineplex-signer /home/mineplex/bin/
# Add entrypoint scripts
COPY --chown=mineplex:nogroup scripts/docker/entrypoint.* /home/mineplex/bin/
# Add scripts
COPY --chown=mineplex:nogroup scripts/alphanet_version scripts/mineplex-docker-manager.sh src/bin_client/bash-completion.sh active_protocol_versions /home/mineplex/scripts/

# Although alphanet.sh has been replaced by mineplex-docker-manager.sh,
# the built-in auto-update mechanism expects an alphanet.sh script to exist.
# So we keep it for a while as a symbolic link.
CMD ln -s mineplex-docker-manager.sh /home/mineplex/scripts/alphanet.sh

FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION} as debug
ARG BUILD_IMAGE
ARG BUILD_IMAGE_VERSION
ARG COMMIT_SHORT_SHA
LABEL maintainer="contact@nomadic-labs.com" \
      org.label-schema.name="mineplex" \
      org.label-schema.docker.schema-version="1.0" \
      org.label-schema.description="mineplex node" \
      org.label-schema.url="https://www.nomadic-labs.com" \
      org.label-schema.vcs-url="https://gitlab.com/mineplex/mineplex" \
      org.label-schema.vcs-ref="${COMMIT_SHORT_SHA}" \
      org.label-schema.build-image="${BUILD_IMAGE}:${BUILD_IMAGE_VERSION}"

RUN sudo apk --no-cache add vim
ENV EDITOR=/usr/bin/vi
COPY --chown=mineplex:nogroup --from=intermediate /home/mineplex/bin/ /usr/local/bin/
COPY --chown=mineplex:nogroup --from=intermediate /home/mineplex/scripts/ /usr/local/share/mineplex/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]


FROM ${BASE_IMAGE}:${BASE_IMAGE_VERSION_NON_MIN} as stripper
COPY --chown=mineplex:nogroup --from=intermediate /home/mineplex/bin/mineplex-* /home/mineplex/bin/
RUN strip /home/mineplex/bin/mineplex*


FROM  ${BASE_IMAGE}:${BASE_IMAGE_VERSION} as bare
ARG BUILD_IMAGE
ARG BUILD_IMAGE_VERSION
ARG COMMIT_SHORT_SHA
LABEL maintainer="contact@nomadic-labs.com" \
      org.label-schema.name="mineplex" \
      org.label-schema.docker.schema-version="1.0" \
      org.label-schema.description="mineplex node" \
      org.label-schema.url="https://www.nomadic-labs.com" \
      org.label-schema.vcs-url="https://gitlab.com/mineplex/mineplex" \
      org.label-schema.vcs-ref="${COMMIT_SHORT_SHA}" \
      org.label-schema.build-image="${BUILD_IMAGE}:${BUILD_IMAGE_VERSION}"
COPY --chown=mineplex:nogroup --from=stripper /home/mineplex/bin/ /usr/local/bin/
COPY --chown=mineplex:nogroup --from=intermediate /home/mineplex/scripts/ /usr/local/share/mineplex


FROM  ${BASE_IMAGE}:${BASE_IMAGE_VERSION} as minimal
ARG BUILD_IMAGE
ARG BUILD_IMAGE_VERSION
ARG COMMIT_SHORT_SHA
LABEL maintainer="contact@nomadic-labs.com" \
      org.label-schema.name="mineplex" \
      org.label-schema.docker.schema-version="1.0" \
      org.label-schema.description="mineplex node" \
      org.label-schema.url="https://www.nomadic-labs.com" \
      org.label-schema.vcs-url="https://gitlab.com/mineplex/mineplex" \
      org.label-schema.vcs-ref="${COMMIT_SHORT_SHA}" \
      org.label-schema.build-image="${BUILD_IMAGE}:${BUILD_IMAGE_VERSION}"

COPY --chown=mineplex:nogroup --from=stripper /home/mineplex/bin/ /usr/local/bin/
COPY --chown=mineplex:nogroup --from=intermediate /home/mineplex/bin/entrypoint.* /usr/local/bin/
COPY --chown=mineplex:nogroup --from=intermediate /home/mineplex/scripts/ /usr/local/share/mineplex
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
