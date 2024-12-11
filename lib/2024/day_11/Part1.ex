defmodule AOC2024.Day11.Part1.Solution do
  @doc ~S"""
  ## Examples

      iex> AOC2024.Day11.Part1.Solution.solution(AOC2024.Day11.Input.test_input(), 6, true)
      22
      iex> AOC2024.Day11.Part1.Solution.solution(AOC2024.Day11.Input.input(), 25)
      185205
  """
  def solution(input, repeats, log \\ false) do
    input
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce({0, %{}}, fn stone, {sum, memo} ->
      calculate_stone_count(stone, repeats, memo, log)
      |> then(
        &{
          sum +
            (elem(&1, 0)
             |> tap(
               if log,
                 do: fn sum -> IO.inspect(sum, label: "total count for stone #{stone}") end,
                 else: fn _ -> nil end
             )),
          elem(&1, 1)
        }
      )
    end)
    |> elem(0)
  end

  defp calculate_stone_count(stone, repeats, memo, log) do
    case memo |> Map.get({:repeats, repeats, stone}) do
      nil ->
        process_stone_transformations(stone, repeats, memo, log)
        |> then(
          &{
            elem(&1, 0)
            |> tap(
              if log,
                do: fn sum -> IO.inspect(sum, label: "intermediate count for #{stone}") end,
                else: fn _ -> nil end
            ),
            elem(&1, 1) |> Map.put({:repeats, repeats, stone}, elem(&1, 0))
          }
        )

      count ->
        {count, memo}
    end
  end

  defp process_stone_transformations(_stone, 0, memo, _log), do: {1, memo}

  defp process_stone_transformations(stone, repeats, memo, log) do
    {transformed, new_memo} = transform_stone_with_memo(stone, memo)

    Enum.map_reduce(
      transformed,
      new_memo,
      &calculate_stone_count(&1, repeats - 1, &2, log)
    )
    |> then(
      &{
        Enum.sum(elem(&1, 0)),
        elem(&1, 1)
      }
    )
  end

  defp transform_stone_with_memo(stone, memo) do
    case memo |> Map.get({:stones, stone}) do
      nil ->
        stones = transform_stone(stone)
        {stones, memo |> Map.put({:stones, stone}, stones)}

      stones ->
        {stones, memo}
    end
  end

  defp transform_stone(0), do: [1]

  defp transform_stone(stone) do
    digits = trunc(:math.log10(stone)) + 1

    if rem(digits, 2) == 0 do
      half_digits = div(digits, 2)
      divisor = trunc(:math.pow(10, half_digits))
      [div(stone, divisor), rem(stone, divisor)]
    else
      [stone * 2024]
    end
  end
end
