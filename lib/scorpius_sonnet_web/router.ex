defmodule ScorpiusSonnetWeb.Router do
  use ScorpiusSonnetWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
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
    plug :put_root_layout, {ScorpiusSonnetWeb.Layouts, :demos}
  end

  pipeline :put_demo_layouts do
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :root}
    plug :put_layout, html: {ScorpiusSonnetWeb.Demos.ChristmasMeta.PageHTML, :app}
    plug :assign_demo_layout
  end

  # 主应用路由
  scope "/", ScorpiusSonnetWeb do
    pipe_through [:browser]

    get "/", PageController, :home
  end

  # Admin 路由
  scope "/admin", ScorpiusSonnetWeb.Admin do
    pipe_through [:browser, :admin]

    get "/", DashboardController, :index
  end

  # Demos 路由
  scope "/demos", ScorpiusSonnetWeb.Demos do
    pipe_through :browser

    get "/", DemoIndexController, :index

    scope "/christmas-meta" do
      pipe_through [:put_demo_layouts]
      get "/", ChristmasMeta.PageController, :index
    end

    scope "/christmas", Christmas do
      get "/", PageController, :index
    end

    scope "/counter", Counter do
      get "/", PageController, :index
    end

    scope "/react-demo", ReactDemo do
      get "/", PageController, :index
    end
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

  scope "/json", ScorpiusSonnetWeb do
    pipe_through :api

    get "/version", VersionController, :index
    get "/list", VersionController, :list
  end

  def assign_demo_layout(conn, _opts) do
    assign(conn, :skip_app_js, true)
  end
end
