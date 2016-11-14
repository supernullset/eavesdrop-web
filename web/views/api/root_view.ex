defmodule EavesdropWeb.API.RootView do
  use EavesdropWeb.Web, :view

  def render("index.json", _) do
    %{
      meta: %{},
      data: %{ msg: "Welcome to Eavesdrop" }
    }
  end

  def render("play_track.json", %{message: message}) do
    %{
      meta: %{},
      data: %{ msg: message }
    }
  end
end
