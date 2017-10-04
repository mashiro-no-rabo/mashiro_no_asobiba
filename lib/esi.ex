defmodule ESI.Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://esi.tech.ccp.is/latest/universe"
  plug Tesla.Middleware.Headers, %{
    "User-Agent" => "eve_gamedesign",
  }
  plug Tesla.Middleware.JSON

  adapter Tesla.Adapter.Hackney

  def get_systems do
    get("/systems/")
    |> Map.get(:body)
  end

  def get_system(system_id) do
    ss = get("/systems/#{system_id}/")
    |> Map.get(:body)
    |> Map.get("security_status")

    {system_id, ss}
  end
end

defmodule ESI do
  def get_things do
    systems = ESI.Client.get_systems()
    stream = Task.async_stream(systems, fn sid -> ESI.Client.get_system(sid) end)
    stream
    |> Enum.map(fn {:ok, v} -> v end)
    |> Enum.into(%{})
  end
end
