defmodule PhoenixElixirWeb.RoomChannel do
  use PhoenixElixirWeb, :channel
  alias Phoenix.PubSub
  alias PhoenixElixirWeb.Presence

  def join("room:lobby", %{"user_id" => user_id}, socket) do
    socket = assign(socket, :user_id, user_id)

    Presence.track(self(), "room:lobby", socket.assigns.user_id, %{
      online_at: :os.system_time(:seconds)
    })

    send(self(), :after_join)

    {:ok, socket}
  end

  def join("room:lobby", _params, socket) do
    {:error, %{reason: "missing user_id"}}
  end

  def handle_in(
        "new_msg",
        %{"body" => body, "user_id" => user_id},
        socket
      ) do
    broadcast!(socket, "new_msg", %{
      body: body,
      user_id: user_id
    })

    {:noreply, socket}
  end

  def handle_in("typing", %{"user_id" => user_id}, socket) do
    broadcast!(socket, "typing", %{
      user_id: user_id
    })

    {:noreply, socket}
  end

  def handle_in("time_now", _params, socket) do
    push(socket, "time_now", %{
      time: :os.system_time(:seconds)
    })

    {:noreply, socket}
  end
end
