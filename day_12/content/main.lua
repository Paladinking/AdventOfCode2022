#!/usr/bin/lua

function heapPush(heap, elem)
	table.insert(heap, elem)

	local pos = #heap
	while pos > 1 do
		local parent = pos // 2
		if heap[pos].cost >= heap[parent].cost then
			break
		end
		heap[pos], heap[parent] = heap[parent], heap[pos]
		pos = parent
	end
end

function heapPop(heap)
	local pos = 1
	heap[pos], heap[#heap] = heap[#heap], heap[pos]
	local res = table.remove(heap)
	while pos * 2 <= #heap do
		local left_child, right_child = pos * 2, pos * 2 + 1
		local min_child = left_child
		if heap[right_child] ~= nil and heap[right_child].cost < heap[left_child].cost then
			min_child = right_child
		end
		if heap[pos].cost > heap[min_child].cost then
			heap[pos], heap[min_child] = heap[min_child], heap[pos]
		else
			return res
		end
		pos = min_child
	end
	return res
end

function countNodes(node)
	local num = 0
	while node ~= nil do
		num = num + 1
		node = node.prev
	end
	return num - 1
end

function addIfValid(grid, nodes, node, x, y)
	if grid[y] ~= nil and grid[y][x] ~= nil 
		and (not grid[y][x].visited)
		and grid[y][x].elevation - grid[node.y][node.x].elevation > - 2
		and grid[y][x].cost > node.cost + 1 
	then
		heapPush(nodes, {x = x, y = y, cost = node.cost + 1, prev = node})
		grid[y][x].cost = node.cost + 1
	end
end

function djikstras2(grid, startNode, goalNode, target)
	local nodes, res, cost = {startNode}, {}, math.huge
	while #nodes > 0 do
		local node = heapPop(nodes)
		if grid[node.y][node.x].elevation == target then
			table.insert(res, countNodes(node))
		end
		if node.x == goalNode.x and node.y == goalNode.y then
			cost = countNodes(node)
		end
		if not grid[node.y][node.x].visited then
			grid[node.y][node.x].visited = true
			addIfValid(grid, nodes, node, node.x + 1, node.y)
			addIfValid(grid, nodes, node, node.x - 1, node.y)
			addIfValid(grid, nodes, node, node.x, node.y + 1) 
			addIfValid(grid, nodes, node, node.x, node.y - 1)
		end
	end
	local smallest = math.huge
	for i = 1, #res  do
		if res[i] < smallest then
			smallest = res[i]
		end
	end
	return cost, smallest
end

local file = io.open("../input/input12.txt", "r")
io.input(file)

local grid, startNode, endNode = {}, {}, {}

local j = 1
for line in io.lines() do
	grid[j] = {}
	for i = 1, #line do
		local val = line:byte(i)
		if (val == string.byte("S")) then
			startNode = {cost = 0, prev = nil, x = i, y = j}
			val = string.byte("a")
		elseif (val == string.byte("E")) then
			endNode = {cost = 0, prev = nil, x = i, y = j}
			val = string.byte("z")
		end
		grid[j][i] = {elevation = val, visited = false, cost = math.huge}
	end
	j = j + 1
end

local to_start, to_cheapest = djikstras2(grid, endNode, startNode, string.byte("a"))
print(to_start)
print(to_cheapest)
