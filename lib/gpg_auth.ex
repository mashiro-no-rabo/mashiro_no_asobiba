defmodule Mashiro.GpgAuth do
  @moduledoc """
  Example output of `gpg2 --verify --no-comment --status-fd 1 2> /dev/null`

  ```
  [GNUPG:] PROGRESS need_entropy X 4 16
  [GNUPG:] PROGRESS need_entropy X 16 16
  [GNUPG:] NEWSIG
  [GNUPG:] KEY_CONSIDERED 1B789E5AF2B3E315CFAB41E11619209600200536 0
  [GNUPG:] SIG_ID MJeniwaF9JyGwr206KtH+/eY390 2016-07-21 1469093625
  [GNUPG:] KEY_CONSIDERED 1B789E5AF2B3E315CFAB41E11619209600200536 0
  [GNUPG:] GOODSIG 1619209600200536 Haruka Ma <haruka@tsundere.moe>
  [GNUPG:] VALIDSIG 1B789E5AF2B3E315CFAB41E11619209600200536 2016-07-21 1469093625 0 4 0 22 10 01 1B789E5AF2B3E315CFAB41E11619209600200536
  [GNUPG:] TRUST_FULLY 0 pgp
  ```
  """
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

      # Get only the lines with [GNUPG:], then remove these prefixes
      lines = result.out
        |> String.split("\n")
        |> Enum.filter_map(
          &(String.contains?(&1, "[GNUPG:]")),
          fn line ->
            line
            |> String.trim()
            |> String.replace_prefix("[GNUPG:] ", "")
          end)

      user_line = lines
        |> Enum.find( fn line -> String.contains?(line, "GOODSIG") end) # Get only the GOODSIG line, which contains Real Name and Email info
        |> String.split
        |> Enum.slice(2..-1) # Remove first two chunks, leaving user info
        |> Enum.join(" ")

      key_id = lines
        |> Enum.find( fn line -> String.contains?(line, "GOODSIG") end)
        |> String.split
        |> Enum.at(1)

      real_name = user_line
        |> String.split(~r{[\(<]}) # Split with `(` which starts the comment, or `<` which starts the email
        |> Enum.at(0)
        |> String.trim

      email = user_line
        |> String.split
        |> Enum.at(-1)

      trust_level = lines
        |> Enum.at(-1)
        |> String.split
        |> Enum.at(0)

      send_resp(conn, 200, "Welcome name: #{real_name}, email: #{email}, key_id: #{key_id} trust_level: #{trust_level}")
    else
      halt(conn)
    end
  end

  match _, do: send_resp(conn, 404, "no route.")

  def run() do
    Plug.Adapters.Cowboy.http(__MODULE__, [], port: 8080)
  end
end
