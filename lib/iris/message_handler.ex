defmodule Iris.MessageHandler do
  require Logger

  def handle(_, [], _) do
    :ok
  end
  def handle(from, [to|rest], data) do
    # relay message to email address
    [_user, host] = :string.tokens(:erlang.binary_to_list(to), '@')
    Logger.debug "host: #{inspect(host)}"
    results = :gen_smtp_client.send({from, [to], :erlang.binary_to_list(data)}, [{:relay, "127.0.0.1"}, {:port, 25}])
    Logger.debug("Sending mail results: #{inspect(results)}")
    handle(from, rest, data)
  end
 
end
