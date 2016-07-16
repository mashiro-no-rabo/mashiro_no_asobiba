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
    [applications: [:logger, :redix]]
  end

  defp deps do
    [{:redix, "~> 0.4.0"}]
  end
end
