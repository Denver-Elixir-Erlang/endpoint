defmodule Endpoint.Discovery do
  use GenServer
  require Logger

  @timer 5_000

  @paths  Application.get_env(:endpoint, :paths)
  @router Application.get_env(:endpoint, :router)

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(_state) do
    {:ok, connect}
  end

  def info do
    GenServer.call(__MODULE__, :state)
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end
  def handle_call(_message, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(_message, state) do
    {:noreply, state}
  end

  def handle_info(:register, _state) do
    {:noreply, connect}
  end
  def handle_info({:nodedown, _nd}, state) do
    Logger.warn("Router has gone down")
    :erlang.send_after(@timer, __MODULE__, :register)
    {:noreply, state}
  end
  def handle_info({:nodeup, _nd}, _state) do
    Logger.info("Router has come alive!!!")
    {:noreply, :connected}
  end
  def handle_info(_message, state) do
    {:noreply, state}
  end

  defp connect do
    Logger.info("connecting to router....")
    case Node.connect(@router) do
      false ->
        Logger.error("Cant connect to router")
        :erlang.send_after(@timer, __MODULE__, :register)
        :disconnected
      true ->
        Logger.info("Connected to router")
        send_message
        Node.monitor(@router, true)
        :connected
    end
  end

  defp send_message do
    :rpc.call(@router, Router.Registry, :add_endpoint, [{node, @paths}])
  end

end
