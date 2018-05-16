defmodule ESI.Client do
  use Tesla

  plug Tesla.Middleware.BaseUrl, "https://esi.evetech.net/latest"
  plug Tesla.Middleware.Headers, %{"User-Agent" => "mashiro-no-asobiba"}
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.Retry, delay: 2000, max_retries: 20

  adapter Tesla.Adapter.Hackney

  def get_systems do
    get("/universe/systems/")
    |> Map.get(:body)
  end

  def get_system(system_id) do
    name = get("/universe/systems/#{system_id}/")
    |> Map.get(:body)
    |> Map.get("name")

    {system_id, name}
  end

  def get_market_page(region_id, page) do
    get("/markets/#{region_id}/orders/?page=#{page}")
  end

  def get_orders(region_id, page) do
    get_market_page(region_id, page)
    |> Map.get(:body)
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

  def test_orders do
    first_page = ESI.Client.get_market_page(10000002, 1)

    pages = String.to_integer(first_page.headers["x-pages"])
    stream = Task.async_stream(2..pages, fn page -> ESI.Client.get_market_page(10000002, page) end)

    stream
    |> Enum.map(fn {:ok, resp} ->
      String.equivalent?(resp.headers["expires"], first_page.headers["expires"])
      _ -> :expired
    end)
  end
end
