defmodule Supreme.Mixfile do
  use Mix.Project

  def project do
    [app: :supreme,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: true,
     deps: deps()]
  end

  def application do
    [
      mod: {Supreme, []},
      applications: [
        :discord_ex,
        :tentacat,
        :logger
      ]
    ]
  end

  defp deps do
    [
      {:discord_ex, "~> 1.1.8"},
      {:tentacat, "~> 0.5"}
    ]
  end
end
