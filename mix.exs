defmodule Adventofcode.MixProject do
  use Mix.Project

  def project do
    [
      app: :adventofcode,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        output: "docs"
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {AdventOfCode, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev},
      {:matrex, "~> 0.6"},
      {:libgraph, "~> 0.16"},
      {:flow, "~> 0.14"},
      {:memoize, "~> 1.2"},
      {:jason, "~> 1.4"},
      {:file_system, "~> 0.2"},
      {:combine, "~> 0.10.0"},
      {:color_utils, "0.2.0"},
      {:debounce, "~> 0.1.0"},
      {:comb, git: "https://github.com/tallakt/comb.git"}
    ]
  end
end
