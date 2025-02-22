ARG TARGETARCH
ARG KOPIA_VERSION="0.19.0"


FROM kopia/kopia:${KOPIA_VERSION} AS kopia
FROM rclone/rclone:sha-0ccf650 AS rclone
FROM scratch AS rootfs

COPY ["./rootfs/", "/"]
COPY --from=kopia ["/bin/kopia", "/usr/local/bin/kopia"]
COPY --from=rclone ["/usr/local/bin/rclone", "/usr/local/bin/rclone"]



FROM lscr.io/linuxserver/baseimage-alpine:3.21

RUN set -eux \
    && apk add --no-cache ca-certificates curl fuse3 tzdata

COPY --from=rootfs ["/", "/"]

ARG TARGETARCH
ARG KOPIA_VERSION
LABEL maintainer="Aleksandar Puharic <aleksandar@puharic.com>" \
      org.opencontainers.image.source="https://github.com/N0rthernL1ghts/kopia-server" \
      org.opencontainers.image.description="Kopia Server ${KOPIA_VERSION} - Alpine Build ${TARGETARCH}" \
      org.opencontainers.image.licenses="Apache 2.0" \
      org.opencontainers.image.version="${KOPIA_VERSION}"

ENV S6_KEEP_ENV=1 \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=1 \
    TERM="xterm-256color" \
    LC_ALL="C.UTF-8" \
    RCLONE_CONFIG=/app/rclone/rclone.conf \
    KOPIA_VERSION=${KOPIA_VERSION} \
	KOPIA_CONFIG_PATH=/app/config/repository.config \
	KOPIA_LOG_DIR=/app/logs \
	KOPIA_CACHE_DIRECTORY=/app/cache \
	KOPIA_PERSIST_CREDENTIALS_ON_CONNECT=false \
	KOPIA_CHECK_FOR_UPDATES=false

WORKDIR "/app/"

EXPOSE 51515/TCP