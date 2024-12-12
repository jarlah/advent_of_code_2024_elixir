defmodule AOC2024.Day12.Part1.Solution do
  @doc ~S"""
  ## Examples

      iex> AOC2024.Day12.Part1.Solution.solution(AOC2024.Day12.Input.test_input_1())
      140
      iex> AOC2024.Day12.Part1.Solution.solution(AOC2024.Day12.Input.test_input_2())
      772
      iex> AOC2024.Day12.Part1.Solution.solution(AOC2024.Day12.Input.test_input())
      1930
      iex> AOC2024.Day12.Part1.Solution.solution(AOC2024.Day12.Input.input())
      1421958

  """
  def solution(input) do
    map =
      input
      |> Enum.with_index()
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        line
        |> String.to_charlist()
        |> Enum.map(&<<&1>>)
        |> Enum.with_index()
        |> Enum.reduce(acc, fn {guarden, x}, acc ->
          acc
          |> Map.put({:position, {x, y}}, guarden)
          |> Map.update({:guarden, guarden}, [{x, y}], &(&1 ++ [{x, y}]))
        end)
      end)

    map
    |> Map.filter(fn {{type, _}, _} -> type == :guarden end)
    |> Enum.map(fn {{_, guarden}, _} -> guarden end)
    |> Enum.uniq()
    |> Enum.reduce(0, fn guarden, acc ->
      map
      |> Map.get({:guarden, guarden})
      |> get_connected_positions()
      |> Enum.reduce(acc, fn area, acc ->
        area_total = length(area)

        perimeter_total =
          get_perimeter(guarden, area, fn pos -> Map.get(map, {:position, pos}) end)

        cost = area_total * perimeter_total
        acc + cost
      end)
    end)
  end

  defp get_connected_positions(positions) do
    positions
    |> Enum.reduce([], fn pos, areas ->
      {connected, unconnected} = Enum.split_with(areas, &connected_to_area?(pos, &1))

      case connected do
        [] -> [MapSet.new([pos]) | areas]
        _ -> [Enum.reduce(connected, MapSet.new([pos]), &MapSet.union/2) | unconnected]
      end
    end)
    |> Enum.map(&MapSet.to_list/1)
  end

  defp connected_to_area?(pos, area) do
    Enum.any?(area, &adjacent?(pos, &1))
  end

  defp adjacent?({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2) == 1
  end

  defp get_perimeter(guarden, area_positions, get_guarden_at_position) do
    Enum.reduce(area_positions, 0, fn {x, y}, acc ->
      acc +
        Enum.count([{0, -1}, {0, 1}, {-1, 0}, {1, 0}], fn {dx, dy} ->
          neighbor_pos = {x + dx, y + dy}

          case get_guarden_at_position.(neighbor_pos) do
            nil -> true
            ^guarden -> false
            _ -> true
          end
        end)
    end)
  end
end
