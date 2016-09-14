defmodule Endpoint do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # connect on startup
    router = Application.get_env(:endpoint, :router)
    # TODO retry logic ?
    case Node.connect(router) do
      false -> raise "Router node down"
      true -> IO.puts "connected to router"
    end

    # Define workers and child supervisors to be supervised
    children = [
      worker(Endpoint.Discovery, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Endpoint.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
