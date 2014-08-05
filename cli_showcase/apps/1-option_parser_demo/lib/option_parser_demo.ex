defmodule OptionParserDemo do
  def run() do
    run(System.argv)
  end

  def run(args) do
    opts = [strict: [opt_a: :integer, flag1: :boolean, flag2: :boolean],
           aliases: [f: :flag1]]

    IO.inspect OptionParser.parse(args, opts)
  end
end
