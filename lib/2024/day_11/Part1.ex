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
      {count, new_memo} = count_after_transforms(stone, repeats, memo)
      {sum + count, new_memo}
    end)
    |> elem(0)
  end

  defp count_after_transforms(stone, repeats, memo) do
    case memo |> Map.get({stone, repeats}) do
      nil ->
        {count, new_memo} =
          do_count_after_transforms(stone, repeats, memo)

        {count, new_memo |> Map.put({stone, repeats}, count)}

      count ->
        {count, memo}
    end
  end

  defp do_count_after_transforms(_stone, 0, memo), do: {1, memo}

  defp do_count_after_transforms(stone, repeats, memo) do
    {transformed, new_memo} = transform_stone_memo(stone, memo)

    {counts, final_memo} =
      Enum.map_reduce(transformed, new_memo, fn s, m ->
        count_after_transforms(s, repeats - 1, m)
      end)

    {Enum.sum(counts), final_memo}
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
