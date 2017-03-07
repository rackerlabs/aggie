defmodule Elk.Mixfile do
  use Mix.Project

  def project do
    [app: :elk,
     version: "0.1.0",
     build_path: "../../_build",
     config_path: "../../config/config.exs",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
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
    [extra_applications: [:logger, :httpoison, :timex]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # To depend on another app inside the umbrella:
  #
  #   {:my_app, in_umbrella: true}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:apex, "~> 0.7.0"},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:distillery, "~> 1.2.2"},
      {:ex_doc, "~> 0.13", only: :dev},
      {:httpoison, "~> 0.10.0"},
      {:poison, "~> 3.0"},
      {:timex, "~> 3.0"},
      {:tzdata, "== 0.1.8", override: true},
      {:uuid, "~> 1.1"},
      {:yaml_elixir, "~> 1.3.0"}
    ]
  end
end
