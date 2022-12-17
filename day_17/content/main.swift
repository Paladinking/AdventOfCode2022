import Foundation

let left = UInt8(ascii : "<")
let width = 7

func compareRow(_ grid : Set<Int>, _ row1 : Int, _ row2 : Int) -> Bool {
	for x in 0...(width - 1) {
		if (grid.contains(row1 * width + x)) {
			if (!grid.contains(row2 * width + x)) {
				return false
			}
		} else if (grid.contains(row2 * width + x)){
			return false
		}
	}
	return true
}

func tryMove(rock : [[Bool]], newX : Int, newY : Int, grid : Set<Int>) -> Bool {
	if (newX < 0 || newX + rock[0].count > width || newY < 0) {
		return false
	}
	
	for y in 0..<(rock.count) {
		for x in 0..<(rock[y].count) {
			if (rock[y][x] && grid.contains(newX + x + width * (newY + rock.count - y - 1))) {
				return false;
			}
		}
	}
	return true
}


func addRock(
	_ rocks : [[[Bool]]], 
	_ current_rock : inout Int,
	_ direction_index : inout Int, 
	_ cur_top : inout Int, 
	_ fallen : inout Int,
	_ grid : inout Set<Int>, 
	_ directions : [UInt8]
) {
	let rock = rocks[current_rock]
	var rock_x = 2
	var rock_y = cur_top + 4
	while rock_y >= 0 {
		if (directions[direction_index] == left) {
			if tryMove(rock : rock, newX : rock_x - 1, newY : rock_y, grid : grid) {
				rock_x -= 1;
			}
			
		} else {
			if tryMove(rock : rock, newX : rock_x + 1, newY : rock_y, grid : grid) {
				rock_x += 1;
			}
		}
		
		direction_index = (direction_index + 1) % directions.count;
		if (!tryMove(rock : rock, newX: rock_x, newY : rock_y - 1, grid : grid)) {
			for y in 0..<(rock.count) {
				for x in 0..<(rock[y].count) {
					if (rock[y][x]) {
						grid.insert(rock_x + x + width * (rock_y + rock.count - y - 1))
					}
				}
			}
			if rock_y + rock.count - 1 > cur_top {
				cur_top = rock_y + rock.count - 1
			}
			break
		}
		rock_y -= 1
	}
	current_rock = (current_rock + 1) % rocks.count
	fallen += 1
}

func adjustEdge(
	_ rocks : [[[Bool]]],
	_ direction_index : Int, 
	_ cur_top : Int, 
	_ current_rock : Int,
	_ grid : Set<Int>, 
	_ directions : [UInt8]
) -> Int {
	var fallen = 0
	var di = direction_index
	var ct = cur_top
	var new_grid = grid
	var cr = current_rock
	while ct - cur_top == 0 {
		addRock(rocks, &cr, &di, &ct, &fallen, &new_grid, directions)
	}
	return fallen - 1
}

let contents = try! String(contentsOfFile: "../input/input17.txt")
var directions : [UInt8] = Array(contents.utf8)
if (directions[directions.count - 1]) == UInt8(ascii:"\n") {
	directions.removeLast()
}

let rocks : [[[Bool]]] = [
	[[true, true, true, true]],
	[[false, true, false], [true, true, true], [false, true, false]],
	[[false, false, true], [false, false, true], [true, true, true]],
	[[true], [true], [true], [true]],
	[[true, true], [true, true]]
]

var grid : Set<Int> = [] 

var current_rock = 0
var direction_index = 0
var cur_top = -1
var fallen = 0

let target = 2022
let initial_iterations = max(directions.count * 10, target)

while (fallen < initial_iterations) {
	addRock(rocks, &current_rock, &direction_index, &cur_top, &fallen, &grid, directions)
	if (fallen == target) {
		print(cur_top + 1)
	}
}

for _ in 1..<(1 + adjustEdge(rocks, direction_index, cur_top, current_rock, grid, directions)) {
	addRock(rocks, &current_rock, &direction_index, &cur_top, &fallen, &grid, directions)
}

var repeating_rows = 1

while true  {
	var done = true
	for i in (cur_top / 2)...(cur_top - repeating_rows) {
		if (!compareRow(grid, i, i - repeating_rows)) {
			done = false
			break
		}
	}
	if done {
		break
	} else {
		repeating_rows += 1
	}
}

let top = cur_top
var repeating_blocks = fallen

while (cur_top - top <= repeating_rows) {
	addRock(rocks, &current_rock, &direction_index, &cur_top, &fallen, &grid, directions)
}
repeating_blocks = fallen - repeating_blocks - 1

let remaining = 1000000000000 - fallen
var tail = remaining - repeating_blocks * (remaining / repeating_blocks)
while tail > 0 {
	addRock(rocks, &current_rock, &direction_index, &cur_top, &fallen, &grid, directions)
	tail -= 1
}

print(1 + cur_top + (remaining / repeating_blocks) * repeating_rows)