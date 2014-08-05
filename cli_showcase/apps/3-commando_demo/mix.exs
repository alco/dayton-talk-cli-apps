defmodule CommandoDemo.Mixfile do
  use Mix.Project

  def project do
    [app: :commando_demo,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 0.14.2",
     deps: deps]
  end

  defp deps do
    [{:commando, github: "alco/commando"}]
  end
end
