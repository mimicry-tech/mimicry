FROM elixir:1.11.4-alpine as dev

COPY .build-deps /
RUN cat .build-deps | xargs apk add --no-cache

ENV ERL_AFLAGS="-kernel shell_history enabled"

WORKDIR /app

COPY mix* ./
RUN mix do \
    local.hex --force, \
    local.rebar --force

FROM dev as ci
RUN mix do \
    deps.get, \
    deps.compile

COPY . ./
