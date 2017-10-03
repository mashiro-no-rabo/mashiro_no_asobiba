defmodule PrivTest do
  def x, do: y(&z/0)

  defp y(fnc), do: fnc.()
  defp z, do: 1
end
