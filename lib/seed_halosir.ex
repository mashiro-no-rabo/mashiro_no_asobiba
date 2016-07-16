defmodule Mix.Tasks.SeedHalosir do
  use Mix.Task

  alias HaloSir.Rules

  @shortdoc "Migrate cached result from old halowrod-server to DETS for halosir"

  def run(_args) do
    IO.puts "Removing old data"
    File.rm("data/webster.dets")
    File.rm("data/youdao.dets")

    IO.puts "Migrating Webster Store"
    {:ok, webster_store} = Redix.start_link("redis://localhost:6379")
    {migrated_count, total} = migrate_keys(:webster, webster_store)
    IO.puts "Total: #{total} keys"
    IO.puts "Migrated: #{migrated_count} keys"

    IO.puts "Migrating Youdao Store"
    {:ok, youdao_store} = Redix.start_link("redis://localhost:6379/1")
    {migrated_count, total} = migrate_keys(:youdao, youdao_store)
    IO.puts "Total: #{total} keys"
    IO.puts "Migrated: #{migrated_count} keys"

    Redix.stop(webster_store)
    Redix.stop(youdao_store)
  end

  defp migrate_keys(table, db) do
    filename = Atom.to_string(table) <> ".dets"
    file_path = Path.join(["data", filename])
    {:ok, ref} = :dets.open_file(table, file: file_path)

    keys = Redix.command!(db, ~w(KEYS *))
    count =
      Enum.reduce(keys, 0, fn key, count ->
        if not String.ends_with?(key, ":count") and Rules.should_cache_word?(key) do
          :dets.insert(ref, {key, get_val(db, key), get_count(db, key)})
          count + 1
        else
          count
        end
      end)

    :dets.close(ref)

    {count, length(keys)}
  end

  defp get_val(db, key) do
    case Redix.command(db, ["GET", key]) do
      {:ok, key} -> key
      {:error, _reason} -> raise "wrong key: #{key}"
    end
  end

  defp get_count(db, key) do
    case Redix.command(db, ["GET", "#{key}:count"]) do
      {:ok, nil} -> 0
      {:ok, count} -> String.to_integer(count)
      {:error, _reason} -> raise "wrong key with count: #{key}"
    end
  end
end
