defmodule Mix.Tasks.Mytask do
  use Mix.Task

  @shortdoc "My mix task"

  @moduledoc """
  Full description of the task, arguments, etc.
  """

  def run(args) do
    IO.puts "Here are your args: #{inspect args}"
  end
end
