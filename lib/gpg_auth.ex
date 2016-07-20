defmodule Mashiro.GpgAuth do
  use Plug.Router

  plug :match
  plug :dispatch

  post "/auth" do
    {:ok, signed_msg, conn} = read_body(conn)

    result =
     Porcelain.shell("gpg2 --verify --status-fd 1",
      in: signed_msg,
      err: nil)

    if result.status == 0 do

      user = result.out
      |> String.split("\n") # Split all lines
      |> Enum.find( fn line -> String.contains?(line, "GOODSIG") end) # Get only the GOODSIG line, which contains Real Name and Email info
      |> String.split # Split by space
      |> Enum.slice(3..-1) # Remove first three text parts, leaving user info
      |> Enum.join(" ") # Re-join to get a user string

      # TODO: hanlde user with comment, seems the format is `Name (comment) <email>`

      send_resp(conn, 200, "Welcome #{user}")
    else
      halt(conn)
    end
  end

  match _, do: send_resp(conn, 404, "no route.")

  def run() do
    Plug.Adapters.Cowboy.http(__MODULE__, [], port: 8080)
  end
end
