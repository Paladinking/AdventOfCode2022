#!/usr/bin/elixir

defmodule Monkey do
	defstruct id: 0, items: {}, newWorry: {:plus, 0}, test: 1, onTrue: 0 , onFalse: 0
end

defmodule Main do
	def traceItem(_, _, _, _, _, inspects, n) when n == 0 do
		inspects
	end

	def traceItem(monkeys, val, pos, divider, mod, inspects, n) do
		monkey = elem(monkeys, pos)
		worry = case monkey.newWorry do
				{ :times, x} -> val * x
				{ :plus, x} -> val + x
				:square -> val * val
				:double -> val + val
			end |> div(divider) |> rem(mod)
		nextMonkey = cond do
			rem(worry, monkey.test) == 0 -> monkey.onTrue
			true -> monkey.onFalse
		end
		n = cond do
			nextMonkey > pos -> n
			nextMonkey < pos -> n - 1
		end
		traceItem(monkeys, worry, nextMonkey, divider, mod, Map.put(inspects, pos, Map.get(inspects, pos, 0) + 1), n)
	end
	
	def traceItems(monkeys, items, divider, n) do
		mod = Enum.reduce(monkeys, 1, fn monkey, prod -> prod * monkey.test end)
		monkeys = List.to_tuple(monkeys)
		Enum.reduce(items, %{}, fn {pos, val}, inspects -> 
			traceItem(monkeys, val, pos, divider, mod, inspects, n)
			end
		)
	end
	
	def topTwo(map) do
		Enum.reduce(map, {0, 0}, fn {_, value}, {first, second} -> 
				cond do
					second >= value -> {first, second}
					value > first -> {value, first}
					true -> {first, value}
				end
			end
		)
	end
	
	
	def start() do
		indata = File.read!("../input/input11.txt")
		monkeys = String.split(indata, "\n\n") 
			|> Enum.map(fn(line) ->
					parts = List.to_tuple(String.split(line, "\n"))
					%Monkey{
						id: elem(parts, 0) |> String.slice(7..-2) |> String.to_integer,
						items: elem(parts, 1) |> String.slice(18..-1) |> String.split(", ") |> Enum.map(&String.to_integer/1),
						newWorry: 
							case String.slice(elem(parts, 2), 23..-1) |> String.split(" ", parts: 2) do
								["*", "old"] -> :square
								["+", "old"] -> :double
								["*", x] -> { :times, String.to_integer(x)}
								["+", x] -> { :plus, String.to_integer(x)}
							end,
						test: elem(parts, 3) |> String.slice(21..-1) |> String.to_integer,
						onTrue: elem(parts, 4) |> String.slice(29..-1) |> String.to_integer,
						onFalse: elem(parts, 5) |> String.slice(30..-1) |> String.to_integer
					}
				end
			)
		items = Enum.reduce(monkeys, [], fn monkey, list -> 
				list ++ Enum.map(monkey.items, fn x -> {monkey.id, x} end)
			end
		)

		{first, second} = traceItems(monkeys, items, 3, 20) |> topTwo
		IO.puts(first * second)
		{first, second} = traceItems(monkeys, items, 1, 10000) |> topTwo
		IO.puts(first * second)
	end
end

Main.start()