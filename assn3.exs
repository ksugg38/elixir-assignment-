defmodule Program1 do
  @moduledoc false

  def get_num_data do
    IO.write("Enter a number: ")
    input = String.trim(IO.gets(""))  # Get input as a string

    case Integer.parse(input) do
      {0, _} ->
        IO.puts("Stopping the loop. Goodbye!")  # Base case: stop on 0

      {num, _} ->
        compute(num)
        get_num_data()  # Tail recursion: call itself again

      :error ->
        IO.puts("Not an integer. Please try again.")
        get_num_data()  # Tail recursion: call itself again on error
    end
  end

  # Perform computation based on the number
  def compute(num) when num < 0 do
    abs_value = abs(num)
    result = :math.pow(abs_value, 7)
    IO.puts("Absolute value raised to the 7th power: #{result}")
  end

  def compute(0) do
    IO.puts("Input is 0")
  end

  def compute(num) when num > 0 do
    case rem(num, 7) do
      0 ->
        root5 = :math.pow(num, 1 / 5)
        IO.puts("The 5th root of the number: #{root5}")

      _ ->
        factorial = factorial(num)
        IO.puts("The factorial of the number: #{factorial}")
    end
  end

  # Factorial supporting function
  defp factorial(0), do: 1
  defp factorial(n), do: n * factorial(n - 1)
end
