defmodule PhoenixElixirWeb.UserSocket do
  use Phoenix.Socket
  use Phoenix.Presence, otp_app: :phoenixElixir, pubsub_server: PhoenixElixir.PubSub

  channel "room:*", PhoenixElixirWeb.RoomChannel

  def connect(_params, socket, _connect_info) do
    # Log available topics before joining any room
    log_available_topics()

    {:ok, socket}
  end

  def id(_socket), do: nil

  defp log_available_topics do
    # Get the list of all joinable topics using Presence
    available_topics = PhoenixElixirWeb.Presence.list(self())

    # Log the available topics in the console
    IO.inspect(available_topics, label: "\n Available Joinable Topics at Connect Time \n")
  end
end
