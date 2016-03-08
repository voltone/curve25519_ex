defmodule Curve25519.Mixfile do
  use Mix.Project

  def project do
    [app: :curve25519,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    []
  end

  defp deps do
    []
  end

end
