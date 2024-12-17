defmodule ScorpiusSonnetWeb.Router do
  use ScorpiusSonnetWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin do
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :admin}
  end

  pipeline :demos do
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :demos}
  end

  # 主应用路由
  scope "/", ScorpiusSonnetWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Admin 路由
  scope "/admin", ScorpiusSonnetWeb.Admin do
    pipe_through [:browser, :admin]

    get "/", DashboardController, :index
  end

  # Demos 路由
  scope "/demos", ScorpiusSonnetWeb.Demos do
    pipe_through [:browser, :demos]

    get "/", DemoIndexController, :index
  end

  # Christmas Demo 路由
  scope "/demos/christmas", ScorpiusSonnetWeb.Demos.Christmas do
    pipe_through [:browser, :demos]

    get "/", PageController, :index
  end

  # Counter Demo 路由
  scope "/demos/counter", ScorpiusSonnetWeb.Demos.Counter do
    pipe_through [:browser, :demos]

    get "/", PageController, :index
  end

  # React Demo 路由
  scope "/demos/react-demo", ScorpiusSonnetWeb.Demos.ReactDemo do
    pipe_through [:browser, :demos]

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ScorpiusSonnetWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:scorpius_sonnet, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ScorpiusSonnetWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
