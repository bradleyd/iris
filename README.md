# Iris

Iris is a simple SMTP server based off [gen_smtp](https://github.com/Vagabond/gen_smtp)

The goal was to make simple SMTP server that could handle incoming email messages and `handle` it depending on your toplogy.

For example, you could build a `Message Handler` module that saves email to disk or forwards it to another SMTP server.

## Setup

Default port is 2525.  See above link for more details.  Adjust `listener` config options to change these.  For example, to accept SSL on port 1465

```elixir
config :iris, 
  listener: [[{:protocol, :ssl}, {:port, 1465},{:sessionoptions, [{:callbackoptions, [{:relay, false},{:parse, true}]}]}]],
  server: Iris.Server,
  message_handler: Iris.MessageHandler
```

### Use your own Message handler

```elixir
config :iris, 
  listener: [[{:sessionoptions, [{:callbackoptions, [{:relay, false},{:parse, true}]}]}]],
  server: Iris.Server,
  message_handler: MyApplicaiton.SpecialMessageHandler
```

### Change Server implementation

* The default server is based off the example provided by `gen_smtp`.  Once again, switch the configuration to your wishes.

```elixir
config :iris, 
  listener: [[{:sessionoptions, [{:callbackoptions, [{:relay, false},{:parse, true}]}]}]],
  server: MyApplicaiton.SMTPServer,
  message_handler: MyApplicaiton.SpecialMessageHandler
```

I use this to accept incoming email that is stored into a DB.


Still tons to do:

* More tests

* Refactor the default server



## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `iris` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:iris, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/iris](https://hexdocs.pm/iris).

