defmodule SubjectManager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start Telemetry
      SubjectManagerWeb.Telemetry,
      # Start the Ecto repository
      SubjectManager.Repo,
      # Start DNS cluster for clustering support
      {DNSCluster, query: Application.get_env(:subject_manager, :dns_cluster_query) || :ignore},
      # Start the PubSub system for publishing and subscribing to events
      {Phoenix.PubSub, name: SubjectManager.PubSub},
      # Start the Phoenix endpoint to handle HTTP requests
      SubjectManagerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SubjectManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SubjectManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
