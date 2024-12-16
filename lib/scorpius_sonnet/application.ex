defmodule ScorpiusSonnet.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # 清理可能存在的旧进程
    System.cmd("pkill", ["-f", "node"], stderr_to_stdout: true)

    # 在开发环境启动 Vite
    if Mix.env() == :dev do
      Port.open(
        {:spawn, "cd assets && npm run dev"},
        [:binary, :exit_status, :stderr_to_stdout]
      )
    end

    children = [
      ScorpiusSonnetWeb.Telemetry,
      ScorpiusSonnet.Repo,
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
    if Mix.env() == :dev do
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
