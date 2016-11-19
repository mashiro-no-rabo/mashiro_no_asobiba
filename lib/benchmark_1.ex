defmodule Benchmark1 do
  def initialize_data do
    types_data = YamlElixir.read_from_file "./typeIDs.yaml"

    types_map = types_data
      |> Enum.map( fn {k, v} ->
        {k, v["name"]["en"]}
      end)
      |> Enum.into(%{})

    ets_id = :ets.new(:types, [:set, :public])
    types_data
      |> Enum.each(fn {k, v} -> :ets.insert(ets_id, {k, v["name"]["en"]}) end)

    type_ids = types_data
      |> Enum.map( fn {k, _} -> k end)

    {types_map, ets_id, type_ids}
  end

  def bench({map, ets, ids}) do
    ids = Enum.shuffle(ids)

    Benchee.run(%{time: 10}, %{
      "map"    => fn -> ids |> Enum.map( fn id -> Map.get(map, id) end ) end,
      "ets" => fn -> ids |> Enum.map( fn id -> :ets.lookup(ets, id) end) end})
  end
end
