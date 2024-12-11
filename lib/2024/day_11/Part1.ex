defmodule AOC2024.Day11.Part1.Solution do
  @doc ~S"""
  ## Examples

      iex> AOC2024.Day11.Part1.Solution.transform_stone(70949)
      [143600776]
      iex> AOC2024.Day11.Part1.Solution.split_number(25645645)
      [2564, 5645]
      iex> AOC2024.Day11.Part1.Solution.solution(AOC2024.Day11.Input.test_input(), 6)
      22
      iex> AOC2024.Day11.Part1.Solution.solution(AOC2024.Day11.Input.input(), 25)
      185205
  """
  def solution(input, repeats) do
    input
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> then(fn stones ->
      Enum.reduce(1..repeats, stones, fn index, acc ->
        IO.inspect("Running pass ##{index} of #{repeats}")
        transform_stones(acc)
      end)
    end)
    |> Enum.count()
  end

  def transform_stone(stone, acc \\ [])
  def transform_stone(0, acc), do: acc ++ [1]

  def transform_stone(stone, acc) do
    if rem(count_digits(stone), 2) == 0,
      do: acc ++ split_number(stone),
      else: acc ++ [stone * 2024]
  end

  defp transform_stones(stones, acc \\ [])
  defp transform_stones([], acc), do: acc

  defp transform_stones([stone | tail], acc) do
    transform_stones(tail, transform_stone(stone, acc))
  end

  def split_number(number) when is_integer(number) do
    digits = count_digits(number)
    half_digits = div(digits, 2)
    divisor = :math.pow(10, half_digits)
    left = div(number, round(divisor))
    right = rem(number, round(divisor))
    [left, right]
  end

  def count_digits(number) when is_integer(number) do
    number
    |> :math.log10()
    |> floor()
    |> Kernel.+(1)
  end
end
