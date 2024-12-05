defmodule AoCH.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AoCHWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:aoch, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: AoCH.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: AoCH.Finch},
      {ConCache,
       name: :cache, ttl_check_interval: :timer.seconds(10), global_ttl: :timer.seconds(900)},
      # Start a worker by calling: AoCH.Worker.start_link(arg)
      # {AoCH.Worker, arg},
      # Start to serve requests, typically the last entry
      AoCHWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AoCH.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    AoCHWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
