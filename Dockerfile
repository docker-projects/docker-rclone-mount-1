FROM amd64/alpine:latest

ARG OVERLAY_VERSION="v2.0.0.1"
ARG OVERLAY_ARCH="amd64"
ARG RCLONE_ARCH="amd64"

ENV DEBUG="false" \
    AccessFolder="/mnt" \
    RemotePath="mediaefs:" \
    MountPoint="/mnt/mediaefs" \
    ConfigDir="/config" \
    ConfigName=".rclone.conf" \
    MountCommands="--allow-other --allow-non-empty" \
    UnmountCommands="-u -z"

## Alpine with utilities
RUN apk --no-cache upgrade \
    && apk add --no-cache --update fuse gnupg unzip curl ca-certificates \
    && echo "Installing S6 Overlay" \
    && curl -o /tmp/s6-overlay.tar.gz -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz" \
    && curl -o /tmp/s6-overlay.tar.gz.sig -L \
    "https://github.com/just-containers/s6-overlay/releases/download/${OVERLAY_VERSION}/s6-overlay-${OVERLAY_ARCH}.tar.gz.sig" \
    && curl https://keybase.io/justcontainers/key.asc | gpg --import \
    && gpg --verify /tmp/s6-overlay.tar.gz.sig /tmp/s6-overlay.tar.gz \
    && tar xfz /tmp/s6-overlay.tar.gz -C / \
    && echo "Download rclone" \
    && curl -o /tmp/rclone.zip -L \
    "https://downloads.rclone.org/rclone-current-linux-${RCLONE_ARCH}.zip" \
    && unzip /tmp/rclone.zip -d /tmp \
    && cp /tmp/rclone-*-linux-${RCLONE_ARCH}/rclone /usr/sbin/ \
    && apk del gnupg unzip curl \
    && rm -rf /tmp/* /var/cache/apk/* /var/lib/apk/lists/*

COPY rootfs/ /

VOLUME ["/mnt"]

ENTRYPOINT ["/init"]
#CMD ["/start.sh"]

# Use this docker Options in run
# --cap-add SYS_ADMIN --device /dev/fuse --security-opt apparmor:unconfined
# -v /path/to/config/.rclone.conf:/config/.rclone.conf
# -v /mnt/mediaefs:/mnt/mediaefs:shared
