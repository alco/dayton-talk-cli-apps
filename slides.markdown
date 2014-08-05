









                              >> Command-line applications with Elixir <<



                                             Alexei Sholik



                                 Dayton Elixir Hangout - August 5, 2014

















                             ## About me

                               - living in Kyiv, Ukraine

                               - background in game development and iOS
                                 ([Objective-]C[++], Python)

                               - familiar with Clojure, Go, Lua, JavaScript

                               - got captivated by Elixir in 2012

















                             ## Agenda

                               1. Motivation

                               2. Types of CLI apps in Elixir

                               3. Toolset for writing a CLI app

                               4. Demo


















                             ## Command-line apps

                             >> Motivation
























                             ## Command-line apps: Motivation

                             >> What is a command-line app?

                               - it parses arguments passed to it on launch

                               - often reads from stdin

                               - writes to stdout and/or stderr

                               - interacts with the OS and other programs
















                             ## Command-line apps: Motivation

                             >> Why bother?

                               - established standard

                               - useful when interacting with existing tools
                                 (shell pipelines, startup daemons)

                               - convenient to use, including non-programmers

















                             ## Command-line apps: Motivation

                             >> Why Elixir?

                               - single platform to depend on (see also npm, gems)

                               - a functional, concurrent language with solid core library

                               - simple error handling model

                               - run external programs in a distributed fashion!
















                             ## Command-line apps in Elixir

                             >> Types
























                             ## Command-line apps in Elixir: Types

                               - mix task

                               - archive

                               - escript

                               - release


















                             ## Command-line apps in Elixir: Types

                             >> Mix task 1/2

                               Mostly used in development: `mix docs`, `mix release`, etc.

                               defmodule Mix.Tasks.Mytask do
                                 use Mix.Task

                                 @shortdoc "My mix task"

                                 @moduledoc "Full description of the task, arguments, etc."

                                 def run(args) do
                                   IO.puts "Here are your args: #{inspect args}"
                                 end
                               end










                             ## Command-line apps in Elixir: Types

                             >> Mix task 2/2

                               $ mix help
                               ...
                               mix mytask            # My mix task
                               ...

                               $ mix mytask 1 2 3
                               Here are your args: ["1", "2", "3"]
















                             ## Command-line apps in Elixir: Types

                             >> Archive

                               Used to make a bunch of .beam files available anywhere
                               on the file system (for the current user and Elixir version).

                               Does not package dependencies.

                               Example: `mix hex`.

                               $ mix archive.build
                               $ mix archive.install

                               # or

                               $ mix archive.install <url>










                             ## Command-line apps in Elixir: Types

                             >> Escript 1/2

                               Escripts are suitable for general-purpose tools.
                               Can have Elixir bundled in.

                               defmodule MyProject.Mixfile do
                                 use Mix.Project

                                 def project do
                                   [app: :myproject,
                                    escript: [
                                     main_module: MyProject.CLI,
                                     emu_args: "-setcookie secret"
                                    ]]
                                 end
                               end









                             ## Command-line apps in Elixir: Types

                             >> Escript 2/2

                               $ mix escript.build

                               # will be supported in the future
                               # (see https://groups.google.com/d/msg/elixir-lang-core/LEr5Vjd1gys/A8WTbC1vmhwJ)
                               # $ mix escript.install <url>


















                             ## Command-line apps in Elixir: Types

                             >> Release

                               Releases produce completely stand-alone apps.

                               They suit GUI apps rather well. For CLI there are issues
                               of size and startup time.

                               (NOTE: support for "CLI releases" is an ongoing experiment in exrm)

                               $ mix release
                               $ rel/bin/myapp --opt val














                             ## Command-line apps in Elixir: Types

                             >> Recap

                               - mix task: used in development, often limited to a single project

                               - archive: basic utility with no dependencies

                               - escript: stand-alone tool that depends on Erlang

                               - release: self-contained bundle with an executable
















                             ## Command-line apps in Elixir

                             >> Toolbox
























                             ## Command-line apps in Elixir: Toolbox

                             1. Building a CLI

                               - OptionParser     (builtin)
                               - getopt           (github.com/jcomellas/getopt)
                               - Commando         (github.com/alco/commando)

                             2. Interfacing with existing programs

                               - Erlang ports     (builtin)
                               - sh               (github.com/devinus/sh)
                               - erlexec          (github.com/saleyn/erlexec)
                               - Porcelain        (github.com/alco/porcelain)













                             ## Command-line apps in Elixir: Toolbox

                             >> OptionParser

                               opts = [strict: [opt_a: :integer, flag1: :boolean, flag2: :boolean],
                                      aliases: [f: :flag1]]

                               args = "--opt-a hi -f --no-flag2" |> String.split
                               OptionParser.parse(args, opts)
                               #=>
                               { [flag1: true, flag2: false],  [],  [{"--opt-a", "hi"}] }
















                             ## Command-line apps in Elixir: Toolbox

                             >> getopt

                               opts = [
                                 {:dbname,  :undefined, 'dbname',   {:string, 'users'}, 'Database name'},
                                 {:xml,     ?x,         :undefined, :undefined,         'Output data in XML'},
                                 {:verbose, ?v,         'verbose',  :integer,           'Verbosity level'},
                                 {:file,    :undefined, :undefined, :string,            'Output file'}
                               ]

                               args = ['-x', 'myfile.txt', '-vvv', 'dummy1', 'dummy2']
                               :getopt.parse(opts, args)
                               #=>
                               { :ok, {[:xml, {:file, 'myfile.txt'}, {:verbose, 3}, {:dbname, 'users'}],
                                       ['dummy1','dummy2']} }









                             ## Command-line apps in Elixir: Toolbox

                             >> Commando

                               cmdspec = Commando.new [
                                 name: "commando_demo", options: [
                                   [name: :dbname, default: "users",         help: "Database name"],
                                   [name: [:x, :xml], argtype: :boolean,     help: "Output data in XML"],
                                   [name: [:v, :verbose], argtype: :integer, help: "Verbosity level"],
                                 ], arguments: [
                                   [name: "file", help: "Output file"],
                                   [name: "dummy", nargs: :inf, help: "Some arguments"],
                                 ],
                               ]

                               args = "-x myfile.txt --verbose 3 dummy1 dummy2" |> String.split
                               Commando.exec(args, cmdspec)
                               #=>
                               {:ok, %Commando.Cmd{arguments: %{...}, options: [...], subcmd: ...}}










                             ## Command-line apps in Elixir

                             >> Demo
























                             ## Command-line apps in Elixir: Demo

                             >> Problem statement

                               A command-line tool for running tasks in an improvised computational
                               cluster.



















                             ## Command-line apps in Elixir: Demo

                             >> Examples

                               # run `sort` on a remote node feeding input from a local file
                               $ squawk run --any-node sort < input.txt

                               # run a few `grep` instances on multiple nodes
                               $ squawk run --nodes=a grep red < input.txt
                               $ squawk run --nodes=b 'grep blue | cut 1-4' < input.txt

                               # fork/join
                               $ squawk run --split=line --nodes=a,b grep -v foo < input.txt

                               # chain
                               $ squawk chain 'grep -v fizz' 'grep -v buzz' < input.txt

                               # see which processes are running
                               $ squawk ps










                             ## Command-line apps in Elixir: Demo

                             >> Components

                               1. CLI parser (Commando).

                               2. Node communication (builtin).

                               3. Spawning OS processes (Porcelain).

                               4. Keeping a local server daemon (builtin).
                                  (left as an exercise for the viewer)















                             ## Command-line apps in Elixir: Demo

                             >> Code walk

                               1. Parse command-line arguments

                               2. Connect to nodes

                               3. Spawn external processes

                               4. Send input

                               5. Collect output














                             ## Command-line apps in Elixir

                             >> Conclusions
























                             ## Command-line apps in Elixir: Conclusions

                               - outlined the landscape of CLI-related tools

                               - used Elixir for fast prototyping

                               - used Elixir in an unusual way (and achieved practical results!)

                               - hopefully inspired you to experiment with Elixir
                                 and build something awesome with it















                              >> Command-line applications with Elixir <<

                           ________                __                        __
                          /_  __/ /_  ____ _____  / /__   __  ______  __  __/ /
                           / / / __ \/ __ `/ __ \/ //_/  / / / / __ \/ / / / /
                          / / / / / / /_/ / / / / ,<    / /_/ / /_/ / /_/ /_/
                         /_/ /_/ /_/\__,_/_/ /_/_/|_|   \__, /\____/\__,_(_)
                                                       /____/

                                              Questions?


                                            Alexei Sholik

                                             @true_droid

                                           github.com/alco
