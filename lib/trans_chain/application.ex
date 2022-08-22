defmodule TransChain.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      # Start the PubSub system
      {Phoenix.PubSub, name: TransChain.PubSub}
      # Start the Endpoint (http/https)
      # Start a worker by calling: TransChain.Worker.start_link(arg)
      # {TransChain.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: TransChain.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TransChainWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
