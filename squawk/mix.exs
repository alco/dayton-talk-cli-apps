defmodule Squawk.Mixfile do
  use Mix.Project

  def project do
    [app: :squawk,
     version: "0.0.1",
     elixir: "~> 0.14.3",
     escript: [
       main_module: Squawk.CLI,
     ],
     deps: deps]
  end

  def application do
    [applications: [:porcelain, :commando],
     env: [host: "192.168.100.170"]]
  end

  defp deps do
    [{:porcelain, "~> 1.0"},
     {:commando, github: "alco/commando"}]
  end
end
