defmodule Benchmark1 do
  {:ok, data} = File.read("type_groupid")
  String.split(data, "\n")
    |> Enum.filter(fn line -> String.contains?(line, ",") end)
    |> Enum.each(fn line ->
      [k, v] = String.split(line, ",")
      def type_groupid(unquote(k)), do: unquote(v)
    end)

  def save_data do
    types_data = YamlElixir.read_from_file "./typeIDs.yaml"

    {:ok, file} = File.open("type_groupid", [:write])
    types_data
      |> Enum.each(fn {k, v} ->
        IO.write(file, "#{k},#{v["groupID"]}\n")
      end)

    File.close(file)
  end

  def initialize_data do
    {:ok, data} = File.read("type_groupid")
    lines = String.split(data, "\n")
      |> Enum.filter(fn line -> String.contains?(line, ",") end)

    ets_id = :ets.new(:types, [:set, :public])
    lines
      |> Enum.each(fn line ->
        [k, v] = String.split(line, ",")
        :ets.insert(ets_id, {k, v})
      end)

    types_map = lines
      |> Enum.map( fn line ->
        [k, v] = String.split(line, ",")
        {k, v}
      end)
      |> Enum.into(%{})

    type_ids = lines
      |> Enum.map( fn line ->
        [k, v] = String.split(line, ",")
        k
      end)

    {types_map, ets_id, type_ids}
  end

  def bench({map, ets, ids}) do
    ids = Enum.shuffle(ids)

    Benchee.run(%{time: 10}, %{
      "map"  => fn -> ids |> Enum.map( fn id -> Map.get(map, id) end ) end,
      "ets"  => fn -> ids |> Enum.map( fn id -> :ets.lookup(ets, id) end) end,
      "func" => fn -> ids |> Enum.map(&Benchmark1.type_groupid/1) end})
  end
end
