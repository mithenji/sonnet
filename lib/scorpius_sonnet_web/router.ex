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

  # 简化布局 pipeline
  pipeline :with_admin_layout do
    plug :put_layout, html: {ScorpiusSonnetWeb.Layouts, :admin}
  end

  pipeline :with_demos_layout do
    plug :put_layout, html: {ScorpiusSonnetWeb.Layouts, :demos}
  end

  # 主应用路由
  scope "/", ScorpiusSonnetWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Admin 路由
  scope "/admin", ScorpiusSonnetWeb.Admin do
    pipe_through [:browser, :with_admin_layout]
    get "/", DashboardController, :index
  end

  # Demos 路由
  scope "/demos", ScorpiusSonnetWeb.Demos do
    pipe_through :browser

    get "/", DemoController, :index
    get "/about", DemoController, :about

    # Demo 项目
    get "/christmas", Christmas.PageController, :index
    get "/christmas-meta", ChristmasMeta.PageController, :index
    get "/counter", Counter.PageController, :index
    get "/react-demo", ReactDemo.PageController, :index
  end

  # API 路由
  scope "/api", ScorpiusSonnetWeb.API do
    pipe_through :api

    get "/version", VersionController, :show
    resources "/demos", DemoController, only: [:index, :show]
  end

  # Enable LiveDashboard in development
  if Application.compile_env(:scorpius_sonnet, :dev_routes) do
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ScorpiusSonnetWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
