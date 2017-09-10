defmodule Iris.ServerTest do
  use ExUnit.Case

  test "options get set" do
    assert {:ok, ["foobar", " ESMTP Bungadog"],
       %Iris.Server.State{options: []}} = Iris.Server.init("foobar", 0, "127.0.0.1", []) 
    
  end
  test "relay is false" do
    assert {:ok, ["foobar", " ESMTP Bungadog"],
       %Iris.Server.State{options: [relay: false]}} = Iris.Server.init("foobar", 0, "127.0.0.1", [{:relay, false}]) 
    
  end

end
