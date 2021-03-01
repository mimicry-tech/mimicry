defmodule Mimicry.MixProject do
  use Mix.Project

  def project do
    [
      app: :mimicry,
      version: "0.0.0",
      elixir: "~> 1.10",
      description: description(),
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      docs: [
        main: "Mimicry"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

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
