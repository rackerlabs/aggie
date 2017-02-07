defmodule Aggie.Mixfile do
  use Mix.Project

  def project do
    [app: :aggie,
    version: "0.1.0",
    elixir: "~> 1.4",
    build_embedded: Mix.env == :prod,
    start_permanent: Mix.env == :prod,
    deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger, :httpoison]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:timex, "~> 3.0"},
      {:ex_doc, "~> 0.13", only: :dev},
      {:distillery, "~> 1.0"},
      {:uuid, "~> 1.1"},
      {:poison, "~> 3.0"},
      {:httpoison, "~> 0.10.0"},
      {:apex, "~> 0.7.0"},
      {:credo, "~> 0.5", only: [:dev, :test]}
    ]
  end
end
