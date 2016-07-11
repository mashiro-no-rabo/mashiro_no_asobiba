defmodule Mashiro.Modattr do
  @url Application.get_env(:mashiro, __MODULE__)[:key]

  def query() do
    IO.puts "Module attribute is: #{@url}"
    IO.puts "Env is: #{Application.get_env(:mashiro, __MODULE__)[:key]}"
  end
end
