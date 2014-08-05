# This is a declarative definition of our CLI
spec = [
  name: "squawk",

  help: "Execute programs on remote nodes",

  options: [
   [name: :name, default: "alco", argtype: :string,
      help: "Name of the local node"],
  ],

  commands: [
    :help,
    [name: "run", help: "Run a single command on one or more nodes",
     arguments: [
       [name: "command", help: "The command to run"],
     ], options: [
       [name: :nodelist, hidden: true, default: "@any", argtype: :string],
       [name: :any_node, store: {:const, "@any"}, target: :nodelist,
          help: "Choose a random node to run execute the command"],
       [name: :all_nodes, store: {:const, "@all"}, target: :nodelist,
          help: "Execute the command on all nodes"],
       [name: :nodes, argtype: :string, target: :nodelist,
          help: "Specify the nodes for execution"],
       [name: :split, argtype: {:choice, ["line"]},
          help: "Split input in the specified manner"],
       [name: :split_size, argtype: :integer, default: 1,
          help: "The size of a single part of the input sent to one node"],
       [name: [:input, :i], argtype: :boolean, # default: false,
          help: "Read from stdin"],
     ]
    ],
    [name: "chain", help: "Execute several consecutive commands on multiple nodes",
     arguments: [
       [name: "commands", nargs: :inf, help: "Commands to run with node names"],
     ]
    ]
  ]
]

defmodule Squawk.CLI do
  @cmdspec Commando.new(spec)

  alias Commando.Cmd

  # main() is called when the escript is invoked from the command line
  def main(args) do
    :random.seed(:erlang.now)
    Commando.exec(args, @cmdspec, actions: [
      commands: %{
        "run" => &cmd_run/2,
        "chain" => &cmd_chain/2,
      }
    ])
  end

  # Callback for the 'run' command. Do some remaining options parsing here
  def cmd_run(%Cmd{arguments: %{"command" => cmd}, options: opts}, %Cmd{options: mainopts}=_cmdb) do
    nodes = case Keyword.get(opts, :nodelist) do
      "@any" -> :any
      "@all" -> :all
      nodestr -> String.split(nodestr, ",")
    end

    input = Keyword.get(opts, :input, false)

    input_split = case Keyword.get(opts, :split) do
      "line" ->
        {:line, Keyword.get(opts, :split_size)}
      nil -> nil
    end

    start_node(Keyword.get(mainopts, :name))
    Squawk.Runner.spawn_nodes(nodes, cmd, input, input_split)
  end

  # Callback for the 'chain' command
  def cmd_chain(%Cmd{arguments: %{"commands" => commands}}, %Cmd{options: mainopts}=_cmdb) do
    nodes = Enum.map(commands, fn cmd ->
      [node, command] = String.split(cmd, ":", parts: 2)
      {node, command}
    end)

    start_node(Keyword.get(mainopts, :name))
    Squawk.Runner.spawn_consecutive_nodes(nodes)
  end

  defp start_node(name) do
    host = Application.get_env(:squawk, :host)
    {:ok, _} = Node.start(String.to_atom("#{name}@#{host}"))
  end
end
