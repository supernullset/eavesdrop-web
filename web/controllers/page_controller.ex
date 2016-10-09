defmodule EavesdropWeb.PageController do
  use EavesdropWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
