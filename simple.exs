defmodule Chain do
  def start do
    serv1 = spawn(__MODULE__, :serv1, [])
    serv2 = spawn(__MODULE__, :serv2, [])
    serv3 = spawn(__MODULE__, :serv3, [0])
    
    Process.link(serv1)
    Process.link(serv2)
    Process.link(serv3)
    
    Process.register(serv2, :serv2)
    Process.register(serv3, :serv3)
    
    loop(serv1, serv2, serv3)
  end

  def start_hot1(serv2, serv3) do
    serv1_hot = spawn(__MODULE__, :serv1_hot, [])
    
    Process.unlink(serv2)
    Process.unlink(serv3)
    Process.unregister(:serv2)
    Process.unregister(:serv3)

    Process.link(serv1_hot)
    Process.link(serv2)
    Process.link(serv3)
    
    Process.register(serv2, :serv2)
    Process.register(serv3, :serv3)
    
    loop(serv1_hot, serv2, serv3)
  end

  def start_hot2(serv1, serv3) do
    serv2_hot = spawn(__MODULE__, :serv2_hot, [])

    Process.unlink(serv1)
    Process.unlink(serv3)
    Process.unregister(:serv2)
    Process.unregister(:serv3)

    Process.link(serv1)
    Process.link(serv2_hot)
    Process.link(serv3)

    Process.register(serv2_hot, :serv2)
    Process.register(serv3, :serv3)

    loop(serv1, serv2_hot, serv3)
  end

  def start_hot3(serv1, serv2) do
    serv3_hot = spawn(__MODULE__, :serv3_hot, [0])

    Process.unlink(serv1)
    Process.unlink(serv2)
    Process.unregister(:serv2)
    Process.unregister(:serv3)

    Process.link(serv1)
    Process.link(serv2)
    Process.link(serv3_hot)

    Process.register(serv2, :serv2)
    Process.register(serv3_hot, :serv3)

    loop(serv1, serv2, serv3_hot)
  end

  # Define the loop and other functions (serv1, serv2, serv3, etc.) here

  defmodule MyServer do
  def loop(serv1, serv2, serv3) do
    IO.puts("Enter message (or 'all_done' to quit):")
    input = IO.gets("") |> String.trim()

    case input do
      "all_done" ->
        send(serv1, :halt)

      "update1" ->
        IO.puts("Hot swapping to new version of server 1")
        start_hot1(serv2, serv3)

      "update2" ->
        IO.puts("Hot swapping to new version of server 2")
        start_hot2(serv1, serv3)

      "update3" ->
        IO.puts("Hot swapping to new version of server 3")
        start_hot3(serv1, serv2)

      _ ->
        send(serv1, input)
        loop(serv1, serv2, serv3)
    end
  end

  def serv1() do
    receive do
      :halt ->
        IO.puts("(serv1) Halting")
        send(whereis(:serv2), :halt)

      {:add, a, b} when is_number(a) and is_number(b) ->
        result = a + b
        IO.puts("(serv1) #{a} + #{b} = #{result}")
        serv1()

      {:sub, a, b} when is_number(a) and is_number(b) ->
        result = a - b
        IO.puts("(serv1) #{a} - #{b} = #{result}")
        serv1()

      {:mult, a, b} when is_number(a) and is_number(b) ->
        result = a * b
        IO.puts("(serv1) #{a} * #{b} = #{result}")
        serv1()

      {:divv, a, b} when is_number(a) and is_number(b) and b != 0 ->
        result = a / b
        IO.puts("(serv1) #{a} / #{b} = #{result}")
        serv1()

      {:neg, a} when is_number(a) ->
        result = -a
        IO.puts("(serv1) neg #{a} = #{result}")
        serv1()

      {:sqrt, a} when is_number(a) and a >= 0 ->
        result = :math.sqrt(a)
        IO.puts("(serv1) sqrt(#{a}) = #{result}")
        serv1()

      other ->
        IO.puts("(serv1) Forwarding unrecognized input: #{inspect(other)} to serv2")
        send(whereis(:serv2), other)
        serv1()
    end
  end
end

defmodule Serv1 do
  def hot() do
    receive do
      :halt ->
        IO.puts("(serv1_hot) Halting")
        send(Process.whereis(Serv2), :halt)  # Send halt to serv2

      {:add, a, b} when is_number(a) and is_number(b) ->
        result = a + b
        IO.puts("(serv1_hot) #{a} + #{b} = #{result}")
        hot()

      {:sub, a, b} when is_number(a) and is_number(b) ->
        result = a - b
        IO.puts("(serv1_hot) #{a} - #{b} = #{result}")
        hot()

      {:mult, a, b} when is_number(a) and is_number(b) ->
        result = a * b
        IO.puts("(serv1_hot) #{a} * #{b} = #{result}")
        hot()

      {:divv, a, b} when is_number(a) and is_number(b) and b != 0 ->
        result = a / b
        IO.puts("(serv1_hot) #{a} / #{b} = #{result}")
        hot()

      {:neg, a} when is_number(a) ->
        result = -a
        IO.puts("(serv1_hot) neg #{a} = #{result}")
        hot()

      {:sqrt, a} when is_number(a) and a >= 0 ->
        result = :math.sqrt(a)
        IO.puts("(serv1_hot) sqrt(#{a}) = #{result}")
        hot()

      other ->
        IO.puts("(serv1_hot) Forwarding unrecognized input: #{inspect(other)} to serv2")
        send(Process.whereis(Serv2), other)
        hot()
    end
  end
end

defmodule Serv2 do
  def hot() do
    receive do
      :halt ->
        IO.puts("(serv2) Halting")
        send(Process.whereis(Serv3), :halt)

      input when is_list(input) ->
        if is_all_integers(input) do
          sum = Enum.sum(input)
          IO.puts("(serv2) Sum of list elements = #{sum}")
          hot()
        else
          if is_all_floats(input) do
            product = Enum.reduce(input, 1, &(&1 * &2))
            IO.puts("(serv2) Product of list elements = #{product}")
            hot()
          else
            IO.puts("(serv2) Forwarding unrecognized input: #{inspect(input)} to serv3")
            send(Process.whereis(Serv3), input)
            hot()
          end
        end

      other ->
        IO.puts("(serv2) Forwarding unrecognized input: #{inspect(other)} to serv3")
        send(Process.whereis(Serv3), other)
        hot()
    end
  end

  defp is_all_integers(list) do
    Enum.all?(list, &is_integer/1)
  end

  defp is_all_floats(list) do
    Enum.all?(list, &is_float/1)
  end
end

defmodule MyModule do
  import Enum

  # Helper function to check if all elements in a list are integers
  def is_all_integers(list) do
    Enum.all?(list, &is_integer/1)
  end

  # Helper function to check if all elements in a list are floats
  def is_all_floats(list) do
    Enum.all?(list, &is_float/1)
  end

  def is_likely_string(list) do
    Enum.all?(list, fn x -> is_integer(x) and x >= 32 and x <= 126 end)
  end

  def serv2_hot() do
    receive do
      :halt ->
        IO.puts("(serv2_hot) Halting")
        send(whereis(:serv3), :halt)

      # Handle a list of integers (ensure all elements are integers)
      input when is_list(input) ->
        cond do
          is_all_integers(input) ->
            sum = Enum.sum(input)
            IO.puts("(serv2_hot) Sum of list elements = #{inspect(sum)}")
            serv2_hot()

          is_all_floats(input) ->
            product = Enum.reduce(input, 1, &(&1 * &2))
            IO.puts("(serv2_hot) Product of list elements = #{inspect(product)}")
            serv2_hot()

          is_likely_string(input) ->
            IO.puts("(serv2_hot) Forwarding unrecognized string input: #{inspect(input)} to serv3")
            send(whereis(:serv3), input)
            serv2_hot()

          true ->
            IO.puts("(serv2_hot) Forwarding unrecognized input: #{inspect(input)} to serv3")
            send(whereis(:serv3), input)
            serv2_hot()
        end

      # Any other message is forwarded to serv3
      other ->
        IO.puts("(serv2_hot) Forwarding unrecognized input: #{inspect(other)} to serv3")
        send(whereis(:serv3), other)
        serv2_hot()
    end
  end

  def serv3(count) do
    receive do
      :halt ->
        IO.puts("(serv3) Halting. Unhandled message count: #{inspect(count)}")

      {:error, message} ->
        IO.puts("(serv3) Error: #{inspect(message)}")
        serv3(count)

      other ->
        IO.puts("(serv3) Not handled: #{inspect(other)}")
        serv3(count + 1)
    end
  end

  def serv3_hot(count) do
    receive do
      :halt ->
        IO.puts("(serv3_hot) Halting. Unhandled message count: #{inspect(count)}")

      {:error, message} ->
        IO.puts("(serv3_hot) Error: #{inspect(message)}")
        serv3_hot(count)

      other ->
        IO.puts("(serv3_hot) Not handled: #{inspect(other)}")
        serv3_hot(count + 1)
    end
  end
end



end

