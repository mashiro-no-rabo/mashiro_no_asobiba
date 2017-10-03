use Mix.Config

config :mashiro, Mashiro.Modattr,
  key: "set in config."

  config :logger, :console,
    metadata: :all

import_config "secret.exs"
