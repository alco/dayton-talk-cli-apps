defmodule CommandoDemo do
  def run() do
    run(System.argv)
  end

  @cmdspec Commando.new [
    name: "commando_demo",
    help: "This is a demo of Commando",
    help_option: :top_cmd,
    options: [
      [name: [:H, :host], default: "localhost", help: "Database server host"],
      [name: [:p, :port], argtype: :integer,    help: "Database server port"],
      [name: :dbname, default: "users",         help: "Database name"],
      [name: [:x, :xml], argtype: :boolean,     help: "Output data in XML"],
      [name: [:v, :verbose], argtype: :integer, help: "Verbosity level"],
    ],
    arguments: [
      [name: "file", help: "Output file"],
      [name: "dummy", nargs: :inf, help: "Some arguments"],
    ],
  ]

  def run(args) do
    IO.inspect Commando.exec(args, @cmdspec)
  end

  def usage() do
    IO.puts Commando.help(@cmdspec)
  end
end
