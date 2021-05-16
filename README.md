<h1 align="center"><img src="https://github.com/floriank/mimicry/raw/main/.github/assets/logo.png" alt="Livebook" width="200"></h1>

[![Elixir CI](https://github.com/floriank/mimicry/actions/workflows/elixir.yml/badge.svg)](https://github.com/floriank/mimicry/actions/workflows/elixir.yml)

A small server for generating ad hoc mock servers based on an OpenAPIv3 specification.

For architecture details, see [ARCHITECTURE](./ARCHITECTURE.md)

:warning: This is an idea at the moment, which I invest some free time into. Come back later, if you like :wink: - A lot of stuff is in progress or just scribbled on a napkin right now.

## Usage

### Docker

To try it out quickly:

```
$ docker pull floriank/mimicry
```

and a

```
$ docker run -p 8080:8080 floriank/mimicry
```

### Inspecting running mimic servers

By default, servers are available under the special `__mimicry` path:

```
$ curl --header "Content-Type: application/json" \ 
       http://localhost:4000/__mimicry
```

### Creating a new mimic server

If you'd like to try out how it works, post a _valid_ OpenAPIv3 to create a mock server:

```
$ curl --header "Content-Type: application/json" \ 
       --request POST \
       --data '{"spec": { /* your OpenAPIv3 Spec */ }}'' \
       http://localhost:4000/__mimicry
```

Following up with a 

```
# The host you're using needs to be part of your OpenAPIv3 Specification in info.servers[]
$ curl --header "X-Mimicry-Host: https://my.production.api.info" \
       http://localhost:4000/
```

should return you the specification.

:exclamation: __NOTE__: Mimicry uses the `title` and `version` fields to generate an id for your particular spec. the URL passed to `X-Mimicry-Host` is one of the server URLs defined in your specification.

### Preloading a specification

You can add a set of specifications upon startup:

```
$ docker run -v `pwd`/my-specs:/specifications -p 8080:8080 floriank/mimicry
```

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
