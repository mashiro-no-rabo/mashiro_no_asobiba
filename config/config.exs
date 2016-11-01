use Mix.Config

config :mashiro, Mashiro.Modattr,
  key: "set in config."

import_config "secret.exs"
