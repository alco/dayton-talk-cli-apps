defmodule GetoptDemo do
  def run() do
    run(System.argv)
  end

  @opts [
    {:host,    ?h,         'host',     {:string, 'localhost'}, 'Database server host'},
    {:port,    ?p,         'port',     :integer,               'Database server port'},
    {:dbname,  :undefined, 'dbname',   {:string, 'users'},     'Database name'},
    {:xml,     ?x,         :undefined, :undefined,             'Output data in XML'},
    {:verbose, ?v,         'verbose',  :integer,               'Verbosity level'},
    {:file,    :undefined, :undefined, :string,                'Output file'}
  ]

  def run(args) do
    IO.inspect :getopt.parse(@opts, Enum.map(args, &String.to_char_list/1))
  end

  def usage() do
    :getopt.usage(@opts, 'getopt_demo')
  end
end
