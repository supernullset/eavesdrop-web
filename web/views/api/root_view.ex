defmodule EavesdropWeb.API.RootView do
  use EavesdropWeb.Web, :view

  def render("index.json", _) do
    %{
      meta: %{},
      data: %{ msg: "Welcome to Eavesdrop" }
    }
  end
end
