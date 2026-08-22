ARG BUILD_FROM
FROM ${BUILD_FROM}

# Liftie listens on this port; the Ski Resort integration talks to it here.
ENV LANG=C.UTF-8 \
    PORT=3000 \
    NODE_ENV=production

# Node.js + tooling needed to install Liftie's dependencies. python3/make/g++
# cover any dependency that compiles a native addon via node-gyp.
RUN apk add --no-cache nodejs npm git make python3 g++

# Pin Liftie to an exact commit for reproducible builds. Upstream publishes no
# release tags, so a commit SHA is the only real pin — and it must match the
# resort list embedded in config.yaml (regenerate both with scripts/update-resorts.sh).
ARG LIFTIE_COMMIT=2d0608df83d833e76e44e1aa42aedecb9cff5041
RUN mkdir -p /opt/liftie \
    && cd /opt/liftie \
    && git init -q \
    && git remote add origin https://github.com/pirxpilot/liftie \
    && git fetch -q --depth 1 origin "${LIFTIE_COMMIT}" \
    && git checkout -q FETCH_HEAD

WORKDIR /opt/liftie
RUN npm install --omit=dev --no-audit --no-fund

# Startup script: applies the optional resort allowlist, then runs Liftie.
COPY run.sh /run.sh
RUN chmod +x /run.sh

EXPOSE 3000

# Supervisor's watchdog reads this HEALTHCHECK; a failing API port -> restart.
HEALTHCHECK --interval=1m --timeout=10s --start-period=45s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:3000/ || exit 1

# The s6-overlay init from the base image runs first, then execs this.
CMD [ "/run.sh" ]
