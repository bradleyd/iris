defmodule Iris.MessageHandlerTest do
  use ExUnit.Case

  test "message gets handled" do
    assert :ok = Iris.TestMessageHandler.handle("bob@bungadog.com", "me@bungadog.com", "Subject: foo\r\n hi\r\n") 
  end
end
