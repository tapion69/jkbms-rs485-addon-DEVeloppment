ARG BUILD_FROM=ghcr.io/hassio-addons/base:stable
FROM ${BUILD_FROM}

COPY package.json /opt/

WORKDIR /opt

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apk update \
    && apk add --no-cache --upgrade \
        musl \
        musl-utils \
        musl-dev \
    && apk add --no-cache --virtual .build-dependencies \
        build-base \
        linux-headers \
        py3-pip \
        python3-dev \
    && apk add --no-cache \
        git \
        icu-data-full \
        nginx \
        nodejs \
        npm \
        openssh-client \
        patch \
        can-utils \
        iproute2 \
        bash \
        mosquitto-clients \
        bluez \
        dbus \
        python3 \
        py3-virtualenv \
    && python3 -m venv /opt/ble-venv \
    && /opt/ble-venv/bin/pip install --no-cache-dir \
        bleak \
        paho-mqtt \
    && npm config set fetch-timeout 300000 \
    && npm config set fetch-retry-mintimeout 20000 \
    && npm config set fetch-retry-maxtimeout 120000 \
    && npm config set fetch-retries 5 \
    && npm config set registry https://registry.npmjs.org/ \
    && npm install \
        --no-audit \
        --no-fund \
        --no-update-notifier \
        --omit=dev \
        --unsafe-perm \
        --fetch-timeout=300000 \
        --fetch-retry-mintimeout=20000 \
        --fetch-retry-maxtimeout=120000 \
    && npm rebuild --build-from-source @serialport/bindings-cpp \
    && npm cache clear --force \
    && echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    && apk del --no-cache --purge .build-dependencies \
    && rm -rf \
        /etc/nginx \
        /root/.cache \
        /root/.npm \
        /root/.nrpmrc \
        /tmp/*

COPY rootfs /

RUN chmod +x \
    /etc/s6-overlay/s6-rc.d/init-customizations/run \
    /etc/s6-overlay/s6-rc.d/init-customizations/up \
    /etc/s6-overlay/s6-rc.d/init-customizations/type \
    /etc/s6-overlay/s6-rc.d/jkbms-ble/run \
    /usr/local/bin/jkbms_ble_reader.py

HEALTHCHECK --start-period=10m \
    CMD curl --fail http://127.0.0.1:1891 || exit 1

ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

ENV VERSION=${BUILD_VERSION}

LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Add-ons" \
    org.opencontainers.image.authors="Franck Nijhof <frenck@addons.community>" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
