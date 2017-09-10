defmodule Iris.Listener do
  use GenServer

  @config Application.get_all_env(:iris)

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    server_options = @config |> Keyword.get(:listener)
    server = @config |> Keyword.get(:server)
    {:ok, pid} = :gen_smtp_server.start(server, server_options)
    ref = Process.monitor(pid)
    {:ok, ref}
  end

end
