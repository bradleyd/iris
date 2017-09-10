defmodule Iris.Listener do
  use GenServer
  require Logger

  @config Application.get_all_env(:iris)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    Process.flag(:trap_exit, true)
    server_options = @config |> Keyword.get(:listener)
    server = @config |> Keyword.get(:server)
    {:ok, pid} = :gen_smtp_server.start(server, server_options)
    ref = Process.monitor(pid)
    {:ok, ref}
  end

  def handle_info({:DOWN, _ref, :process, pid, reason}, state) do
    Logger.error("SMTP server pid #{inspect(pid)} has gone down because #{inspect(reason)}")
    {:stop, state}
  end
  def handle_info({:EXIT, pid, reason}, state) do
    Logger.error("SMTP server pid #{inspect(pid)} has exited because #{inspect(reason)}")
    {:stop, state}
  end


end
