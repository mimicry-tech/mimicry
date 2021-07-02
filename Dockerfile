FROM hexpm/elixir:1.11.4-erlang-24.0-alpine-3.13.3 as base

RUN addgroup -g 1000 -S devgroup && adduser -u 1000 -S devuser -G devgroup
USER devuser

COPY .build-deps /
RUN cat .build-deps | xargs apk add --no-cache

WORKDIR /app

COPY mix* ./
RUN mix do \
    local.hex --force, \
    local.rebar --force

RUN mix deps.get

# Development image
FROM base as dev
ENV ERL_AFLAGS="-kernel shell_history enabled"
ENV MIX_ENV=dev
COPY . ./

# Release image
FROM base as release

# we release in  production mode, see config/prod.exs for details
ENV MIX_ENV=prod
COPY lib lib
COPY config config
COPY README.md README.md
RUN mix do compile, release

# bind to 0.0.0.0
ENV MIMICRY_IP 0.0.0.0

# internally bound port
ENV MIMICRY_PORT 8080

# copy over the built release
RUN cp -r /app/_build/prod/rel/mimicry/* /app
RUN find /app -executable -type f -exec chmod +x {} +

# create the entry folder for specifications on startup
RUN mkdir /specifications

CMD [ "/app/bin/mimicry", "start" ]

