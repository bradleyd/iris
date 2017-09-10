defmodule Iris.TestMessageHandler do
  require Logger

  def handle(_, [], _) do
    :ok
  end
  def handle(from, [to|rest], data) do
    Logger.debug("Message sent to #{to}")
    handle(from, rest, data)
  end
end

