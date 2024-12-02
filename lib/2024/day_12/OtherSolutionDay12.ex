# Code is made by and posted on elixirforum by https://elixirforum.com/u/lud
defmodule AdventOfCode.Solutions.Y24.OtherSolutionDay12 do

  def part_two(full_grid) do
    regions = compute_regions(full_grid)

    regions
    |> Enum.map(&cost_p2/1)
    |> Enum.sum()
  end

  defp compute_regions(grid) do
    {regions, rest} =
      Enum.reduce(grid, {[], grid}, fn {pos, tag}, {regions, rest_grid} ->
        case Map.fetch(rest_grid, pos) do
          :error ->
            {regions, rest_grid}

          {:ok, _} ->
            {region, rest_grid} = take_region(rest_grid, tag, [pos])
            {[region | regions], rest_grid}
        end
      end)

    0 = map_size(rest)

    regions
  end

  defp take_region(mut_grid, tag, open, closed \\ [])

  defp take_region(mut_grid, tag, [pos | open], closed) do
    neighs = pos |> cardinal4() |> Enum.filter(fn xy -> xy not in closed && Map.get(mut_grid, xy) == tag end)
    take_region(mut_grid, tag, neighs ++ open, [pos | closed])
  end

  defp take_region(mut_grid, tag, [], closed) do
    region = Map.new(closed, &{&1, tag})

    mut_grid = Map.drop(mut_grid, closed)
    {region, mut_grid}
  end

  defp area(region) do
    map_size(region)
  end

  defp cost_p2(region) do
    area(region) * count_sides(region)
  end

  defp count_sides(region) do
    poses = Map.keys(region)

    individual_sides =
      Enum.flat_map(poses, fn pos ->
        [
          {:up, translate(pos, :n)},
          {:down, translate(pos, :s)},
          {:left, translate(pos, :w)},
          {:right, translate(pos, :e)}
        ]
        |> Enum.filter(fn {_, xy} -> xy not in poses end)
      end)

    sides_by_direction =
      Enum.group_by(
        individual_sides,
        fn
          # group sides by their orientation and level
          {:up, {_x, y}} -> {:up, y}
          {:down, {_x, y}} -> {:down, y}
          {:right, {x, _y}} -> {:right, x}
          {:left, {x, _y}} -> {:left, x}
        end,
        fn
          # keep side value by orientation and cross direction to know if their
          # are touching
          {:up, {x, _y}} -> x
          {:down, {x, _y}} -> x
          {:right, {_x, y}} -> y
          {:left, {_x, y}} -> y
        end
      )

    Enum.reduce(sides_by_direction, 0, fn {{_direction, _level}, cross_coords}, acc ->
      distinct_sides(cross_coords) + acc
    end)
  end

  defp distinct_sides(cross_coords) do
    [h | cross_coords] = Enum.sort(cross_coords)
    distinct_sides(cross_coords, h, 0)
  end

  defp distinct_sides([h | t], prev, acc) when h == prev + 1 do
    # No need to accumulate the whole side cross coordinates, we can just keep
    # the previous nuber
    distinct_sides(t, h, acc)
  end

  defp distinct_sides([h | t], _prev, acc) do
    distinct_sides(t, h, acc + 1)
  end

  defp distinct_sides([], _prev, acc) do
    acc + 1
  end

  def cardinal4(xy) do
    [
      translate(xy, :n),
      translate(xy, :s),
      translate(xy, :w),
      translate(xy, :e)
    ]
  end

  def translate(xy, direction, n \\ 1)
  def translate({x, y}, :n, n), do: {x, y - n}
  def translate({x, y}, :s, n), do: {x, y + n}
  def translate({x, y}, :w, n), do: {x - n, y}
  def translate({x, y}, :e, n), do: {x + n, y}
end
