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
    # 设置根布局为demos，避免使用默认的root布局
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :demos}
    # 设置子布局为app
    plug :put_layout, html: {ScorpiusSonnetWeb.Layouts, :app}
  end

  # 为各个子项目创建独立的布局pipeline
  pipeline :with_christmas_layout do
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :christmas}
  end

  pipeline :with_christmas_meta_layout do
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :christmas_meta}
  end

  pipeline :with_counter_layout do
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :counter}
  end

  pipeline :with_react_demo_layout do
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :react_demo}
  end

  pipeline :with_vue_demo_layout do
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :vue_demo}
  end

  pipeline :with_svelte_demo_layout do
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :svelte_demo}
  end

  pipeline :with_solid_demo_layout do
    plug :put_root_layout, html: {ScorpiusSonnetWeb.Layouts, :solid_demo}
  end

  # 主应用路由
  scope "/", ScorpiusSonnetWeb do
    pipe_through :browser

    get "/", MainHTML.MainController, :home
  end

  # Admin 路由
  scope "/admin", ScorpiusSonnetWeb.Admin do
    pipe_through [:browser, :with_admin_layout]
    get "/", DashboardController, :index
  end

  # Demos 索引路由
  scope "/demos", ScorpiusSonnetWeb.Demos do
    pipe_through [:browser, :with_demos_layout]

    get "/", IndexHTML.IndexController, :index
    get "/about", IndexHTML.IndexController, :about
  end

  # 各个Demo项目的独立路由
  scope "/demos", ScorpiusSonnetWeb.Demos do
    pipe_through [:browser]

    # Christmas项目
    scope "/christmas" do
      pipe_through [:with_christmas_layout]
      get "/", Christmas.PageController, :index
    end

    # Christmas Meta项目
    scope "/christmas-meta" do
      pipe_through [:with_christmas_meta_layout]
      get "/", ChristmasMeta.PageController, :index
    end

    # Counter项目
    scope "/counter" do
      pipe_through [:with_counter_layout]
      get "/", Counter.PageController, :index
    end

    # React Demo项目
    scope "/react-demo" do
      pipe_through [:with_react_demo_layout]
      get "/", ReactDemo.PageController, :index
    end

    # Vue Demo项目 (如果存在)
    scope "/vue-demo" do
      pipe_through [:with_vue_demo_layout]
      get "/", VueDemo.PageController, :index
    end

    # Svelte Demo项目 (如果存在)
    scope "/svelte-demo" do
      pipe_through [:with_svelte_demo_layout]
      get "/", SvelteDemo.PageController, :index
    end

    # Solid Demo项目 (如果存在)
    scope "/solid-demo" do
      pipe_through [:with_solid_demo_layout]
      get "/", SolidDemo.PageController, :index
    end
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
