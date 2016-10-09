defmodule EavesdropWeb.API.RootController do
  use EavesdropWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.json"
  end
end
