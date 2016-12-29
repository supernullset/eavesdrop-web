defmodule EavesdropWeb.MusicChannel do
  use Phoenix.Channel

  def join("user:" <> _user_stream, _msg, socket) do
    # TODO: add signin here (based on source permissions?)
    {:ok, socket}
  end

  def handle_out("state_change", payload, socket) do
    push socket, "state_change", payload
    {:noreply, socket}
  end

end
