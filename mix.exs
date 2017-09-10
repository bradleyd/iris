defmodule Iris.Mixfile do
  use Mix.Project

  def project do
    [
      app: :iris,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "Iris",
      source_url: ""
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :gen_smtp],
      mod: {Iris.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_smtp, "~> 0.12.0"}
    ]
  end
  
  defp description() do
    "A simple SMTP server."
  end

  defp package() do
    [
      files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
      maintainers: ["Bradley Smith"],
      licenses: ["Apache 2.0"],
      links: %{"GitHub" => "https://github.com/bradleyd/iris"}
    ]
  end
end
