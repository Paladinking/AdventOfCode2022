defmodule Monkey do
	defstruct id: 0, items: [], newWorry: {:plus, 0}, test: 1, onTrue: 0 , onFalse: 0, inspects: 0
end

defmodule Main do
	require Logger
	
	def doRounds(monkeys, n) when n == 0, do: monkeys

	def doRounds(monkeys, n) do
		{monkeys, added} = Enum.map_reduce(monkeys, %{}, fn monkey, added -> 
				{added, i} = Stream.concat(monkey.items, Map.get(added, monkey.id, []))
				|> Enum.reduce({Map.delete(added, monkey.id), monkey.inspects}, fn val, {added, i} ->
					worry = case monkey.newWorry do
						{:times, x} -> val * x
						{:plus, x} -> val + x
						:square -> val * val
						:double -> val + val
					end |> div(3)
					nextMonkey = cond do
						rem(worry, monkey.test) == 0 -> monkey.onTrue
						true -> monkey.onFalse
					end
					{Map.put(added, nextMonkey, Map.get(added, nextMonkey, []) ++ [worry]), i + 1}
				end)
				{%{monkey | items: [], inspects: i}, added}
			end
		)
		{monkeys, _} = Enum.map_reduce(monkeys, added, fn monkey, added -> 
				{%{monkey | items: Map.get(added, monkey.id, [])}, Map.delete(added, monkey.id)}
			end)
		doRounds(monkeys, n - 1)
	end
	
	def start() do
		indata = File.read!("../input/input_test.txt")
		monkeys = String.split(indata, "\n\n") 
			|> Stream.map(fn(line) ->
					parts = List.to_tuple(String.split(line, "\n"))
					%Monkey{
						id: elem(parts, 0) |> String.slice(7..-2) |> String.to_integer,
						items: elem(parts, 1) |> String.slice(18..-1) |> String.split(", ") |> Enum.map(&String.to_integer/1),
						newWorry: 
							case String.slice(elem(parts, 2), 23..-1) |> String.split(" ", parts: 2) do
								["*", "old"] -> :square
								["+", "old"] -> :double
								["*", x] -> {:times, String.to_integer(x)}
								["+", x] -> {:plus, String.to_integer(x)}
							end,
						test: elem(parts, 3) |> String.slice(21..-1) |> String.to_integer,
						onTrue: elem(parts, 4) |> String.slice(29..-1) |> String.to_integer,
						onFalse: elem(parts, 5) |> String.slice(30..-1) |> String.to_integer
					}
				end
			)

		{first, second} = doRounds(monkeys, 20) |> Enum.reduce({0, 0}, fn monkey, {first, second} -> 
				cond do
					second >= monkey.inspects -> {first, second}
					monkey.inspects > first -> {monkey.inspects, first}
					true -> {first, monkey.inspects}
				end
			end
		)
		IO.puts(first * second)
	end
end

Main.start()