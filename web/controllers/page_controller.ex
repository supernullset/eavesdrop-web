defmodule EavesdropWeb.PageController do
  use EavesdropWeb.Web, :controller

  @everyone "everyone"

  def index(conn, _params) do
    conn
    |> put_session(:listening_to, @everyone)
    |> render "index.html", user_name: @everyone
  end

  def user_stream(conn, %{"user_name" => user_name} = params) do
    conn
    |> put_session(:listening_to, user_name)
    |> render "user_stream.html", user_name: user_name
  end
end
