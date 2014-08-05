defmodule Squawk.Runner do
  alias Porcelain.Process
  alias Porcelain.Result

  def spawn_nodes(:any, cmd, input, split) do
    log "Connecting nodes"
    node = Squawk.Util.connect_nodes |> pick_random
    run_list([node], cmd, input, split)
  end

  def spawn_nodes(:all, cmd, input, split) do
    log "Connecting nodes"
    Squawk.Util.connect_nodes |> run_list(cmd, input, split)
  end

  def spawn_nodes(names, cmd, input, split) when is_list(names) do
    log "Connecting nodes"
    Squawk.Util.connect_nodes(names) |> run_list(cmd, input, split)
  end

  def spawn_consecutive_nodes(node_names) do
    nodes =
      node_names
      |> Enum.map(fn {name, _cmd} -> name end)
      |> Squawk.Util.connect_nodes
      |> Enum.map(fn {name, node} ->
        {_name, cmd} = Enum.find(node_names,
                                   fn {nodename, _cmd} -> nodename == name end)
        {node, cmd}
      end)

    [{first_node, cmd}|rest] = nodes

    options = [out: :stream, err: :out, in: :receive]
    first_proc = %Process{out: stream} =
      :rpc.call(first_node, Porcelain, :spawn_shell, [cmd, options])

    out_stream = Enum.reduce(rest, stream, fn {node, cmd}, stream ->
      options = [out: :stream, err: :out, in: stream]
      %Process{out: new_stream} =
        :rpc.call(node, Porcelain, :spawn_shell, [cmd, options])
      new_stream
    end)

    input = read_input()
    send_input(first_proc, input)
    print_stream_output(out_stream)
  end

  defp run_list(list, cmd, input, split) do
    {procs, bad} = run_multi(list, cmd)
    :ok = feed_input(input, split, procs)
    print_results({procs, bad})
  end

  def run_multi(node_pairs, cmd) do
    nodes = Enum.map(node_pairs, fn {_, node} -> node end)
    log "Executing command on nodes #{inspect nodes}"
    options = [out: {:send, self()}, err: :out, in: :receive]
    # Remote call for
    #   Porcelain.spawn_shell(cmd, options)
    :rpc.multicall(nodes, Porcelain, :spawn_shell, [cmd, options])
  end

  defp pick_random(list) do
    count = Enum.count(list)
    rindex = :random.uniform(count)-1
    Enum.at(list, rindex)
  end

  defp send_input(proc, "") do
    Process.send_input(proc, "")
    proc
  end

  defp send_input(proc, input) do
    Process.send_input(proc, input)
    Process.send_input(proc, "")
    proc
  end

  defp feed_input(false, _, procs) do
    # send EOF to each processes
    Enum.each(procs, &Process.send_input(&1, ""))
  end

  defp feed_input(true, nil, procs) do
    # send the same input to all processes
    input = read_input()
    Enum.each(procs, &send_input(&1, input))
  end

  defp feed_input(true, {:line, n}, procs) do
    # split input among processes
    feed_input_lines(n, Enum.count(procs), Stream.cycle(procs))
  end

  defp feed_input_lines(n, nprocs, procs) do
    case get_lines(n) do
      :eof ->
        # send EOF to all procs
        procs
        |> Enum.take(nprocs)
        |> Enum.each(&Process.send_input(&1, ""))

      {:error, _reason}=error -> error

      lines ->
        [proc] = Enum.take(procs, 1)
        Process.send_input(proc, lines)
        feed_input_lines(n, nprocs, Stream.drop(procs, 1))
    end
  end

  defp get_lines(n) do
    do_get_lines(n, [])
  end

  defp do_get_lines(0, acc) do
    acc
  end

  defp do_get_lines(n, acc) do
    case IO.gets("") do
      :eof when acc == [] -> :eof
      :eof -> acc
      {:error, _reason}=error -> error
      data ->
        do_get_lines(n-1, [acc, data])
    end
  end

  defp read_input do
    do_read_input("")
  end

  defp do_read_input(acc) do
    case IO.gets("") do
      :eof -> acc
      {:error, reason} -> raise reason
      data -> do_read_input(acc <> data)
    end
  end

  defp print_output(%Process{pid: pid}=proc) do
    receive do
      {^pid, :data, data} ->
        IO.write data
        print_output(proc)
      {^pid, :result, %Result{status: status}} ->
        log "Finished with status #{status}"
    end
  end

  defp print_output({:badrpc, error}) do
    log "Failed to execute on some node: #{inspect error}"
  end

  defp print_error(node) do
    log "Failed to execute on node #{node}"
  end

  defp print_results({results, bad_nodes}) do
    Enum.each(results, &print_output/1)
    Enum.each(bad_nodes, &print_error/1)
  end

  defp print_stream_output(stream) do
    Enum.into(stream, IO.stream(:stdio, :line))
  end

  defp log(msg) do
    IO.write :stderr, "--> "
    IO.puts :stderr, msg
  end
end
