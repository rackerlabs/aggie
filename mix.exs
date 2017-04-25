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

  def application do
    [extra_applications: [:logger, :httpoison, :timex]]
  end

  defp deps do
    [
      {:distillery, "~> 1.2.2"},
      {:ex_doc, "~> 0.13", only: :dev},
      {:hackney, "~> 1.8.0"},
      {:httpoison, "~> 0.11.2"},
      {:poison, "~> 3.0"},
      {:timex, "~> 3.0"},
      {:tzdata, "== 0.1.8", override: true}
    ]
  end
end
