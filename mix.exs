defmodule Mimicry.MixProject do
  use Mix.Project

  def project do
    [
      app: :mimicry,
      version: "0.0.0",
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Docs
      name: "Mimicry",
      source_url: "https://github.com/floriank/mimicry",
      # TODO: Someone make a website plz.
      homepage_url: "https://mimicry.tech",
      docs: [
        main: "Mimicry",
        logo: "assets/mimicry-chest-mini-dark.png"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Mimicry.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.0"},
      {:phoenix, "~> 1.5"},
      {:plug_cowboy, "~> 2.4"},
      {:yaml_elixir, "~> 2.6"},

      # dev
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:dogma, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0.0-rc.7", only: [:dev], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def aliases, do: []

  defp description do
    """
    A small server to generate on demand mock servers based on a specification
    """
  end

  defp package do
    [
      name: :mimicry,
      files: [
        "lib/",
        "mix.exs",
        "README*",
        "LICENSE*"
      ],
      maintainers: [
        "Florian Kraft"
      ],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/floriank/mimicry"
      }
    ]
  end
end
