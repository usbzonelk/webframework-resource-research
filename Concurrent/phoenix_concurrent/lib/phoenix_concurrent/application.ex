defmodule PhoenixConcurrent.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PhoenixConcurrentWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:phoenix_concurrent, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PhoenixConcurrent.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: PhoenixConcurrent.Finch},
      # Start a worker by calling: PhoenixConcurrent.Worker.start_link(arg)
      # {PhoenixConcurrent.Worker, arg},
      # Start to serve requests, typically the last entry
      PhoenixConcurrentWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PhoenixConcurrent.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PhoenixConcurrentWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
