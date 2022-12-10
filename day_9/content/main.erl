-module(main). 
-export([start/0]). 

sign(N) when N < 0 -> -1;
sign(N) when N > 0 -> 1;
sign(N) when N == 0 -> 0.
	
moveRope({_, Amount}, Acc) when Amount == 0 -> Acc;
moveRope({Dir, Amount}, {Visited, Rope}) -> 
	{NewRope, _} = lists:mapfoldl(fun({X, Y}, Prev) ->
			case Prev of
			first -> 
				Head = case Dir of 
					$R -> {X + 1, Y};
					$L -> {X - 1, Y};
					$U -> {X, Y + 1};
					$D -> {X, Y - 1}
				end,
				{Head, Head};
			{Px, Py} -> 
				DeltaX = Px - X,
				DeltaY = Py - Y,
				Pos = if 
					(abs(DeltaX) == 2) or (abs(DeltaY) == 2) ->  
						{X + sign(DeltaX), Y + sign(DeltaY)};
					true ->
						{X, Y}
				end, 
				{Pos, Pos}
			end
		end,
		first, Rope
	),
	moveRope({Dir, Amount - 1}, {sets:add_element(lists:last(NewRope), Visited), NewRope}).

start() -> 
	case file:read_file("../input/input9.txt") of
		{ok, Input} -> 
			Lines = lists:map(fun(Line) -> 
					{
						lists:nth(1, Line), 
						element(1, string:to_integer(lists:sublist(Line, 3, length(Line))))
					}
				end, 
				[binary_to_list(Line) || Line <- binary:split(Input, [<<"\n">>], [global]), Line /= <<>>]
			),
			{Short, _} = lists:foldl(
				fun moveRope/2,
				{sets:add_element({0, 0}, sets:new()), lists:duplicate(2, {0, 0})}, 
				Lines
			), 
			{Long, _} = lists:foldl(
				fun moveRope/2,
				{sets:add_element({0, 0}, sets:new()), lists:duplicate(10, {0, 0})}, 
				Lines
			), 
			
			io:fwrite("~w~n", [sets:size(Short)]),
			io:fwrite("~w~n", [sets:size(Long)]);
		{error, Reason} -> io:fwrite("~w~n", [Reason])
	end.