defmodule Mashiro.Mixfile do
  use Mix.Project

  def project do
    [app: :mashiro,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger, :redix, :cowboy, :plug, :porcelain]]
  end

  defp deps do
    [{:redix, "~> 0.4.0"},
     {:porcelain, github: "alco/porcelain"},
     {:plug, "~> 1.0"},
     {:cowboy, "~> 1.0"}]
  end
end
