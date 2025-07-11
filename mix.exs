defmodule GenDOM.MixProject do
  use Mix.Project

  def project do
    [
      app: :gen_dom,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package(),
      description: description(),
      source_url: "https://github.com/liveview-native/gen_dom"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {GenDOM.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp description do
    """
    A powerful Elixir library for creating, manipulating, and querying DOM structures 
    with a comprehensive implementation of the DOM specification including proper inheritance, 
    CSS selector support, and process-based node management.
    """
  end

  defp package do
    [
      name: "gen_dom",
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE.md logo.png),
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/liveview-native/gen_dom",
        "DockYard" => "https://dockyard.com"
      },
      maintainers: ["DockYard, Inc."]
    ]
  end

  # Run "mix docs" to generate documentation.
  defp docs do
    [
      main: "GenDOM",
      source_url: "https://github.com/liveview-native/gen_dom",
      logo: "logo.png",
      extras: ["README.md", "LICENSE.md"],
      groups_for_modules: [
        "Core": [GenDOM, GenDOM.Node, GenDOM.Element, GenDOM.Document],
        "Elements": [GenDOM.Element.Form, GenDOM.Element.Button, GenDOM.Element.Input],
        "Utilities": [GenDOM.Parser, GenDOM.QuerySelector, GenDOM.Matcher]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:benchee, "~> 1.4"},
      {:live_view_native, github: "liveview-native/live_view_native"},
      {:selector, github: "liveview-native/selector"},
      {:floki, "~> 0.38"},
      {:ex_doc, "~> 0.34", only: :dev, runtime: false},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
