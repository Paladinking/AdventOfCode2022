import Foundation

let left = UInt8(ascii : "<")
let right = UInt8(ascii : ">")
let width = 7


let contents = try! String(contentsOfFile: "../input/input17.txt")
var directions : [UInt8] = Array(contents.utf8)
if (directions[directions.count - 1]) == UInt8(ascii:"\n") {
	directions.removeLast()
}

func printRow(_ grid : Set<Int>, _ row : Int) {
	var s = ""
	for x in 0...(width - 1) {
		if (grid.contains(row * width + x)) {
			s += "#"
		} else {
			s += "."
		}
	}
	print(s)
}

func printGrid(_ grid : Set<Int>, _ cur_top : Int) {
	for i in 0...cur_top {
		printRow(grid, cur_top - i)
	}
}

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

func findNonRepeating(_ grid : Set<Int>, _ repeating_rows : Int) -> Int {
	var repeat_start = 0
	while true {
		var done = true
		for i in 0...(repeating_rows - 1) {
			if !compareRow(grid, repeat_start + i, repeat_start + repeating_rows + i) {
				done = false
				break
			}
		}
		if done {
			return repeat_start
		}
		repeat_start += 1
	}
}


func tryMove(rock : [[Bool]], newX : Int, newY : Int, grid : Set<Int>) -> Bool {
	if (newX < 0 || newX + rock[0].count > width || newY < 0) {
		return false
	}
	
	for y in 0...(rock.count - 1) {
		for x in 0...(rock[y].count - 1) {
			if (rock[y][x] && grid.contains(newX + x + width * (newY + rock.count - y - 1))) {
				return false;
			}
		}
	}
	return true
}


func addRock(rock : [[Bool]], direction_index : inout Int, cur_top : inout Int, grid : inout Set<Int>, directions : [UInt8]) {
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
			for y in 0...(rock.count - 1) {
				for x in 0...(rock[y].count - 1) {
					if (rock[y][x]) {
						grid.insert(rock_x + x + width * (rock_y + rock.count - y - 1))
					}
				}
			}
			if rock_y + rock.count - 1 > cur_top {
				cur_top = rock_y + rock.count - 1
			}
			return;
		}
		rock_y -= 1
	}
}


let rocks : [[[Bool]]] = [
	[[true, true, true, true]],  // 4x1
	[[false, true, false], [true, true, true], [false, true, false]], // +
	[[false, false, true], [false, false, true], [true, true, true]], // J
	[[true], [true], [true], [true]], // 1x4
	[[true, true], [true, true]]
]

var grid : Set<Int> = [] 

var current_rock = 0
var direction_index = 0
var cur_top = -1
var fallen = 0

let initial_iterations = directions.count * 25

while (fallen < initial_iterations) {
	addRock(rock : rocks[current_rock], direction_index: &direction_index, cur_top: &cur_top, grid : &grid, directions: directions)
	current_rock = (current_rock + 1) % rocks.count
	fallen += 1
}



var repeating_rows = 10// 2694, 1722
print("starting repeat check")


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
var repeating_blocks = 0
while (cur_top - top <= repeating_rows) {
	addRock(rock : rocks[current_rock], direction_index: &direction_index, cur_top: &cur_top, grid : &grid, directions: directions)
	current_rock = (current_rock + 1) % rocks.count
	repeating_blocks += 1
}
repeating_blocks -= 1
print(repeating_rows, repeating_blocks)
// 1561739130391
// 1561739130391
// 1561739130391
let remaining = 1000000000000 - fallen
var tail = remaining - repeating_blocks * (remaining / repeating_blocks)
print("Tail=", tail, "Remaining=", remaining, "Fallen=", fallen,"Repeating_rows=", repeating_rows)
while tail > 0 {
	addRock(rock : rocks[current_rock], direction_index: &direction_index, cur_top: &cur_top, grid : &grid, directions: directions)
	current_rock = (current_rock + 1) % rocks.count
	tail -= 1
}

print(cur_top + (remaining / repeating_blocks) * repeating_rows - repeating_rows)