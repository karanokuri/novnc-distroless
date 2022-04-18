FROM debian:stable-slim AS build-env

ARG NOVNC_VERSION=v1.3.0
ARG WEBSOCKIFY_VERSION=v0.10.0

RUN apt-get update \
 && apt-get install --no-install-suggests --no-install-recommends --yes \
      ca-certificates \
      curl \
      gcc \
      libmpc-dev \
      libmpfr-dev \
      libpython3-dev \
      python3-venv \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /venv \
 && /venv/bin/pip install --upgrade pip \
 && /venv/bin/pip install --disable-pip-version-check numpy

RUN mkdir /novnc \
 && curl -sSL https://github.com/novnc/novnc/archive/refs/tags/${NOVNC_VERSION}.tar.gz \
    | tar xz --strip 1 -C /novnc \
 && mkdir /novnc/utils/websockify \
 && curl -sSL https://github.com/novnc/websockify/archive/refs/tags/${WEBSOCKIFY_VERSION}.tar.gz \
    | tar xz --strip 1 -C /novnc/utils/websockify \
 && :

FROM gcr.io/distroless/python3
COPY --from=build-env /novnc /novnc
COPY --from=build-env /venv /venv

WORKDIR /novnc/utils/websockify
ENTRYPOINT ["/venv/bin/python3","-m","websockify"]
CMD ["--web","/novnc","80","127.0.0.1:5900"]
