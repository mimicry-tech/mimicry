# Mimicry

[![Elixir CI](https://github.com/floriank/mimicry/actions/workflows/elixir.yml/badge.svg)](https://github.com/floriank/mimicry/actions/workflows/elixir.yml)

A small server for generating ad hoc mock servers based on an OpenAPIv3 specification. The plan is to provide a way to generate a set of mock server based on OpenAPIv3 specifications.

For architecture details, see [ARCHITECTURE](./ARCHITECTURE.md)

:warning: This is an idea at the moment, which I invest some free time into. Come back later, if you like :wink: - A lot of stuff is in progress or just scribbled on a napkin right now.

## Usage

If you'd like to try out how it works, add an OpenAPIv3 Specification to the [`specs`](./specs) folder (the spec will be read upon startup) or do a

```
$ curl --header "Content-Type: application/json" \ 
       --request POST \
       --data '{"spec": { /* your OpenAPIv3 Spec */ }}'' \
       http://localhost:4000/__mimicry
```

to get and ad hoc server.

Following up with a 

```
# The host you're using needs to be part of your OpenAPIv3 Specification in info.servers[]
$ curl --header "X-Mimicry-Host: https://my.production.api.info" \
       http://localhost:4000/
```

should return you the specification.

## Development

The project comes with a small [`docker-compose`](https://docs.docker.com/compose/) setup. You can use `make` to get started:

```bash
# to get the local image built
$ make setup

# to start the local development server
$ make up
``` 

You should be able to reach `mimicry` at [localhost:4000](http://localhost:4000). Have a look at [`config/dev.exs`]('./config/dev.exs') if you wish to change ports.

### Non-docker

Not recommended, but `mimicry` is just a [Phoenix](https://phoenixframework.org/) powered [Elixir](https://elixir-lang.org) [Application](https://erlang.org/doc/design_principles/applications.html) with no dependencies. So you can always run:

```bash
# copy over the config sample
$ cp ./config/dev.exs.sample ./config/dev.exs

# get the deps
$ mix deps.get

# run the server directly
$ mix phx.serve
```

Some ways to customizing your `iex` experience are included in this mode.

## Logo

The logo was designed by the most excellent [Agatha Schnips](https://www.agathaschnips.com). It's released under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/). You may use, change and alter it, as long as you attribute the original author and indicate changes made.

## List of planned capabilities

- [ ] Coverage of _most_ of the OpenAPIv3 specification, offering opinionated servers
- [ ] Allow for creating simple GraphQL endpoints based on the schemata provided
- [ ] Simple installation/running via docker container
