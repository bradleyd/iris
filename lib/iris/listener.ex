defmodule Iris.Listener do
  use GenServer

  @config Application.get_env(:iris, :listener)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    {:ok, pid} = :gen_smtp_server.start(Iris.Server, @config)
    ref = Process.monitor(pid)
    {:ok, ref}
  end

end
