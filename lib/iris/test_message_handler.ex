defmodule Iris.TestMessageHandler do
  use GenServer
  require Logger

  # get config here
  
  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, []}
  end

  def handle(from, to, data) do
    GenServer.cast(__MODULE__, {:send, from, to, data})
  end

  def handle_cast({:send, from, to, data}, state) do
    do_handle(from, to, data)
    {:noreply, state}
  end

  defp do_handle(_, [], _) do
    :ok
  end
  defp do_handle(from, [to|rest], data) do
    # relay message to email address
    [_user, host] = :string.tokens(:erlang.binary_to_list(to), '@')
    Logger.debug("Message sent to #{to}")
    do_handle(from, rest, data)
  end
end

