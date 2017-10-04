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
    [applications: [:logger, :redix, :cowboy, :plug, :yaml_elixir, :tesla, :hackney, :poison]]
  end

  defp deps do
    [{:redix, "~> 0.4.0"},
     {:plug, "~> 1.0"},
     {:cowboy, "~> 1.0"},
     {:yaml_elixir, "~> 1.2"},
     {:benchee, "~> 0.5"},
     {:meck, "~> 0.8"},
     {:tesla, "~> 0.7.1"},
     {:hackney, "~> 1.8"},
     {:poison, "~> 3.1"},
   ]
  end
end
