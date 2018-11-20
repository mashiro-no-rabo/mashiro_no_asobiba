defmodule Mashiro.Mixfile do
  use Mix.Project

  def project do
    [app: :mashiro, version: "0.1.0", elixir: "~> 1.7", deps: deps()]
  end

  defp deps do
    [{:forms, github: "efcasado/forms"}]
  end
end
