# Iris

Iris is a simple SMTP server based off [gen_smtp](https://github.com/Vagabond/gen_smtp)

The goal was to make simple SMTP server that could handle incoming email messages and `relay` it depending on your toplogy.

For example, you could build a `Message Handler` module that saves email to disk or forwards it to another SMTP server.

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

