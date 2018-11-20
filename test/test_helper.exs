ExUnit.start()

defmodule TestA do
  def write, do: :nothing
end

:meck.new(TestA)
