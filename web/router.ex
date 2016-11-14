defmodule EavesdropWeb.Router do
  use EavesdropWeb.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", EavesdropWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/:user_name", PageController, :user_stream
  end

  scope "/api", EavesdropWeb do
    pipe_through :api

    get "/", API.RootController, :index
    post "/play", API.RootController, :play
    post "/stop", API.RootController, :stop
    post "/signin", API.RootController, :signin
  end
end
