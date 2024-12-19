defmodule ScorpiusSonnet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # 只在开发环境清理进程
    if Application.get_env(:scorpius_sonnet, :env) == :dev do
      System.cmd("pkill", ["-f", "node"], stderr_to_stdout: true)
    end

    # 只在开发环境启动 Vite
    if Application.get_env(:scorpius_sonnet, :env) == :dev do
      require Logger
      Logger.info("Starting Vite development server...")

      port =
        Port.open(
          {:spawn, "cd assets && npm run dev"},
          [:binary, :exit_status, :stderr_to_stdout]
        )

      Logger.info("Vite server started with port: #{inspect(port)}")
    end

    children = [
      ScorpiusSonnetWeb.Telemetry,
      # 暂时注释掉 Repo
      # ScorpiusSonnet.Repo,
      {DNSCluster, query: Application.get_env(:scorpius_sonnet, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ScorpiusSonnet.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: ScorpiusSonnet.Finch},
      # Start to serve requests, typically the last entry
      ScorpiusSonnetWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ScorpiusSonnet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def stop(_state) do
    if Application.get_env(:scorpius_sonnet, :env) == :dev do
      System.cmd("pkill", ["-f", "node"], stderr_to_stdout: true)
    end

    :ok
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ScorpiusSonnetWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
