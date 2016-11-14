defmodule EavesdropWeb.API.RootController do
  use EavesdropWeb.Web, :controller

  def index(conn, _params) do
    render conn, "index.json"
  end

  def signin(conn, %{"user_name" => user_name} = _params) do
    message = case EavesdropOTP.UserSession.present?(user_name) do
      true ->
        "Already signed in"
      _ ->
        EavesdropOTP.UserSession.signin(user_name)
        message = "signin"
    end

    EavesdropWeb.Endpoint.broadcast! "room:#{user_name}", "state_change", %{body: message}
    render conn, "play_track.json", %{message: message}
  end

  def signout(conn, %{"user_name" => user_name} = _params) do
    message = case EavesdropOTP.UserSession.present?(user_name) do
      true ->
        EavesdropOTP.UserSession.signout(user_name)
        message = "Signed out"
      _ ->
        message = "not in the system"
    end

    EavesdropWeb.Endpoint.broadcast! "room:#{user_name}", "state_change", %{body: message}
    render conn, "play_track.json", %{message: message}
  end

  def play(conn,  %{"user_name" => user_name, "track_name" => track_name} = _params)do
    message = case EavesdropOTP.UserSession.present?(user_name) do
      true ->
        {:ok, message} = EavesdropOTP.UserSession.play_track(user_name, track_name)
        message
      _ ->
        "not in the system"
    end

    EavesdropWeb.Endpoint.broadcast! "room:#{user_name}", "state_change", %{body: message}
    render conn, "play_track.json", %{message: message}
  end

  def stop(conn, %{"user_name" => user_name} = _params) do
    case EavesdropOTP.UserSession.present?(user_name) do
      true ->
        {:ok, message} = EavesdropOTP.UserSession.stop_track(user_name)
        EavesdropWeb.Endpoint.broadcast! "room:#{user_name}", "state_change", %{body: message}
      _ -> nil
    end

    render conn, "play_track.json", %{message: message}
  end
end
