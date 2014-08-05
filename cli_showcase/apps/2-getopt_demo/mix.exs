defmodule GetoptDemo.Mixfile do
  use Mix.Project

  def project do
    [app: :getopt_demo,
     version: "0.0.1",
     deps_path: "../../deps",
     lockfile: "../../mix.lock",
     elixir: "~> 0.14.2",
     deps: deps]
  end

  defp deps do
    [{:getopt, github: "jcomellas/getopt", tag: "v0.8.2"}]
  end
end
