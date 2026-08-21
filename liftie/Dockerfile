ARG BUILD_FROM
FROM ${BUILD_FROM}

# Liftie listens on this port; the Ski Resort integration talks to it here.
ENV LANG=C.UTF-8 \
    PORT=3000 \
    NODE_ENV=production

# Node.js + tooling needed to install Liftie's dependencies. python3/make/g++
# cover any dependency that compiles a native addon via node-gyp.
RUN apk add --no-cache nodejs npm git make python3 g++

# Pin Liftie to a known-good release; fall back to the default branch if the
# tag naming ever changes upstream.
ARG LIFTIE_VERSION=4.4.0
RUN git clone --depth 1 --branch "v${LIFTIE_VERSION}" \
        https://github.com/pirxpilot/liftie /opt/liftie \
    || git clone --depth 1 https://github.com/pirxpilot/liftie /opt/liftie

WORKDIR /opt/liftie
RUN npm install --omit=dev --no-audit --no-fund

# Startup script: applies the optional resort allowlist, then runs Liftie.
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3000

# The s6-overlay init from the base image runs first, then execs this.
CMD [ "/run.sh" ]
