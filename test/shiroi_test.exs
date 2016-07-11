defmodule ShiroiTesuto do
  use ExUnit.Case

  setup do
    Application.put_env(:mashiro, Mashiro.Modattr, [key: "set in test!"])
  end

  test "truth" do
    Mashiro.Modattr.query()
    assert 1 + 1 == 2
  end
end
