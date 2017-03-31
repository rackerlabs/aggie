defmodule Aggie.Mixfile do
  use Mix.Project

  def project do
    [apps_path: "apps",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options.
  #
  # Dependencies listed here are available only for this project
  # and cannot be accessed from applications inside the apps folder
  defp deps do
    [
      {:apex, "~> 0.7.0", only: [:dev, :test]},
      {:credo, "~> 0.5", only: [:dev, :test]},
      {:distillery, "~> 1.2.2"},
      {:ex_doc, "~> 0.13", only: :dev},
      {:httpoison, "~> 0.10.0"},
      {:benchfella, "~> 0.3.0"},
      {:poison, "~> 3.0"},
      {:timex, "~> 3.0"},
      {:tzdata, "== 0.1.8", override: true}
    ]
  end
end
