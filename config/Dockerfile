FROM elixir:1.10.4-alpine as dev

COPY .build-deps /
RUN cat .build-deps | xargs apk add --no-cache

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
