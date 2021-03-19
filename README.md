# Mimicry

A small server for generating ad hoc mock servers based on a specification.

For architecture details, see [ARCHITECTURE](./ARCHITECTURE.md)

:warning: This is an idea at the moment, which I invest some free time into. Come back later, if you like :wink:

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

