defmodule AOC2024.Day11.Part1.Solution do
  @doc ~S"""
  ## Examples

      iex> AOC2024.Day11.Part1.Solution.solution(AOC2024.Day11.Input.test_input(), 6)
      22
      iex> AOC2024.Day11.Part1.Solution.solution(AOC2024.Day11.Input.input(), 25)
      185205
  """
  def solution(input, repeats) do
    input
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> Enum.reduce({0, %{}}, fn stone, {sum, memo} ->
      calculate_stone_count(stone, repeats, memo)
      |> then(
        &{
          sum + elem(&1, 0),
          elem(&1, 1)
        }
      )
    end)
    |> elem(0)
  end

  defp calculate_stone_count(stone, repeats, memo) do
    case memo |> Map.get({stone, repeats}) do
      nil ->
        process_stone_transformations(stone, repeats, memo)
        |> then(
          &{
            elem(&1, 0),
            elem(&1, 1) |> Map.put({stone, repeats}, elem(&1, 0))
          }
        )

      count ->
        {count, memo}
    end
  end

  defp process_stone_transformations(_stone, 0, memo), do: {1, memo}

  defp process_stone_transformations(stone, repeats, memo) do
    {transformed, new_memo} = transform_stone_memo(stone, memo)

    Enum.map_reduce(transformed, new_memo, fn s, m ->
      calculate_stone_count(s, repeats - 1, m)
    end)
    |> then(
      &{
        Enum.sum(elem(&1, 0)),
        elem(&1, 1)
      }
    )
  end

  defp transform_stone_memo(stone, memo) do
    case memo |> Map.get({:transform, stone}) do
      nil ->
        result = transform_stone(stone)
        {result, memo |> Map.put({:transform, stone}, result)}

      result ->
        {result, memo}
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
