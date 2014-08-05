defmodule Squawk.Util do
  def connect_nodes do
    read_node_list
    |> parse_node_list
    |> Enum.reduce([], &add_node/2)
  end

  def connect_nodes(names) do
    read_node_list
    |> parse_node_list
    |> Enum.filter(fn {name, _} -> Enum.member?(names, name) end)
    |> Enum.map(fn {_, node}=x -> Node.connect(node); x end)
  end

  defp read_node_list do
    File.read!("nodes.txt")
  end

  defp parse_node_list(str) do
    String.split(str, "\n")
    |> Enum.map(&String.strip/1)
    |> Enum.reject(&(&1 == ""))
    |> Enum.map(fn node_name ->
      [name, _] = String.split(node_name, "@")
      {name, String.to_atom(node_name)}
    end)
  end

  defp add_node({_, name}=node, list) do
    case Node.connect(name) do
      true -> [node|list]
      _ -> list
    end
  end
end
