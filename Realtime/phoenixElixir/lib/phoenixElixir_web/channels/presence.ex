defmodule PhoenixElixirWeb.Presence do
  use Phoenix.Presence, otp_app: :phoenixElixir, pubsub_server: PhoenixElixir.PubSub
end
