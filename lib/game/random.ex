defmodule Game.Random do
  @moduledoc """
  Random number generation utilities for the game.
  """

  @doc """
  Generate a random number between min and max (inclusive).

  ## Examples

      iex> Game.Random.random_range(1, 10)
      5  # Random number between 1 and 10

      iex> Game.Random.random_range(10, 10)
      10  # When min equals max, returns that number
  """
  @spec random_range(integer(), integer()) :: integer()
  def random_range(min, max) when min == max, do: min
  def random_range(min, max) when min < max do
    :rand.uniform(max - min + 1) + min - 1
  end
end
