private class Line : GLib.Object {
	public int first;
	public int last;

	public Line(int first, int last) {
		this.first = first;
		this.last = last;
	}
}

private class Segment : GLib.Object {
	public int side;
	public int up;

	public int x;
	public int y;

	public Segment(int x, int y) {
		this.side = -1;
		this.up = -1;
		this.x = x;
		this.y = y;
	}
}

private interface World : GLib.Object {
	public abstract void move(int distance, string[] map, ref int dir, ref int row, ref int col);	
}

private class FlatWorld : GLib.Object, World {
	private Line[] rows;
	private Line[] cols;

	public FlatWorld(Line[] rows, Line[] cols) {
		this.rows = rows;
		this.cols = cols;
	}

	public void move(int distance, string[] map, ref int dir, ref int row, ref int col) {
		while (distance > 0) {
			distance--;
			int next_row = row;
			int next_col = col;
			switch (dir) {
				case 0: //Right
					next_col++;
					if (next_col > rows[row].last) {
						next_col = rows[row].first;
					}
					break;
				case 1: //Down
					next_row++;
					if (next_row > cols[col].last) {
						next_row = cols[col].first;
					}
					break;
				case 2: //Left
					next_col--;
					if (next_col < rows[row].first) {
						next_col = rows[row].last;
					}
					break;
				case 3: //Up
					next_row--;
					if (next_row < cols[col].first) {
						next_row = cols[col].last;
					}
					break;
			}
			if (map[next_row][next_col] == '.') {
				row = next_row;
				col = next_col;
			}
		}
	}
}

const int TOP = 0;
const int UP = 1;
const int LEFT = 2;
const int BOTTOM = 3;
const int DOWN = 4;
const int RIGHT = 5;

private static int rotate_left(int top, int up) {
	switch (top + 10 * up) {
		case TOP + 10 * UP:
			return LEFT;
		case TOP + 10 * DOWN:
			return RIGHT;
		case TOP + 10 * LEFT:
			return DOWN;
		case TOP + 10 * RIGHT:
			return UP;
		case UP + 10 * TOP:
			return RIGHT;
		case UP + 10 * BOTTOM:
			return LEFT;
		case UP + 10 * LEFT:
			return TOP;
		case UP + 10 * RIGHT:
			return BOTTOM;
		case DOWN + 10 * TOP:
			return LEFT;
		case DOWN + 10 * LEFT:
			return BOTTOM;
		case DOWN + 10 * RIGHT:
			return TOP;
		case DOWN + 10 * BOTTOM:
			return RIGHT;
		case LEFT + 10 * TOP:
			return UP;
		case LEFT + 10 * UP:
			return BOTTOM;
		case LEFT + 10 * DOWN:
			return TOP;
		case LEFT + 10 * BOTTOM:
			return DOWN;
		case RIGHT + 10 * TOP:
			return DOWN;
		case RIGHT + 10 * UP:
			return TOP;
		case RIGHT + 10 * DOWN:
			return BOTTOM;
		case RIGHT + 10 * BOTTOM:
			return UP;
		case BOTTOM + 10 * LEFT:
			return UP;
		case BOTTOM + 10 * UP:
			return RIGHT;
		case BOTTOM + 10 * DOWN:
			return LEFT;
		case BOTTOM + 10 * RIGHT:
			return DOWN;
		default:
			print("Invalid\n");
			return -1;
	}
}

private class CubeWorld : GLib.Object, World {
	private Segment[] cube;
	private Segment[,] flat_cube;
	private int cube_size;

	public CubeWorld(Segment[] cube, Segment[,] flat_cube, int cube_size) {
		this.cube = cube;
		this.flat_cube = flat_cube;
		this.cube_size = cube_size;
	}

	public void move(int distance, string[] map, ref int dir, ref int row, ref int col) {
		while (distance > 0) {
			distance--;
			int grid_col = col / cube_size;
			int grid_row = row / cube_size;
			int side = flat_cube[grid_col, grid_row].side;
			int up = flat_cube[grid_col, grid_row].up;
			int next_row = row;
			int next_col = col;
			int next_dir = dir;
			switch (dir) {
				case 0:
					next_col++;
					if (next_col >= (grid_col + 1) * cube_size) {
						int new_side = rotate_left(side, (up + 3) % 6);
						if (cube[new_side].up == up) { //RIGHT -> LEFT
							next_row = row + (cube[new_side].y - cube[side].y) * cube_size;
							next_col = cube[new_side].x * cube_size;
							next_dir = 0;
						} else if (cube[new_side].up == side) { //RIGHT -> UP
							next_row = cube[new_side].y * cube_size; // correct?
							next_col = (cube_size - 1 - row + cube[side].y * cube_size) + cube_size * cube[new_side].x;
							next_dir = 1;
						} else if (cube[new_side].up == (up + 3) % 6) { // RIGHT -> RIGHT
							next_row = (cube_size - 1 - row + cube[side].y * cube_size) + cube_size * cube[new_side].y;
							next_col = (cube[new_side].x + 1) * cube_size - 1;
							next_dir = 2;
						} else if (cube[new_side].up == (side + 3) % 6) { // RIGHT -> DOWN
							next_row = (cube[new_side].y + 1) * cube_size - 1;
							next_col = row + (cube[new_side].x - cube[side].y) * cube_size;
							next_dir = 3;
						}
					}
					break;
				case 1:
					next_row++;
					if (next_row >= (grid_row + 1) * cube_size) {
						int new_side = (up + 3) % 6;
						if (cube[new_side].up == rotate_left(side, (up + 3) % 6)) { //DOWN -> LEFT
							next_row = (cube_size - 1 - col  + cube[side].x * cube_size) + cube[side].y * cube_size;
							next_col = cube[new_side].x * cube_size;
							next_dir = 0;
						} else if (cube[new_side].up == side) { // DOWN -> UP
							next_row = cube[new_side].y * cube_size;
							next_col = col + (cube[new_side].x - cube[side].x) * cube_size;
							next_dir = 1;
						} else if (cube[new_side].up == rotate_left(side, up)) { // DOWN -> RIGHT
							next_row = col + (cube[new_side].y - cube[side].x) * cube_size;
							next_col = (cube[new_side].x + 1) * cube_size - 1;
							next_dir = 2;
						} else if (cube[new_side].up == (side + 3) % 6) { // DOWN -> DOWN
							next_row = (cube[new_side].y + 1) * cube_size - 1;
							next_col = (cube_size - col - 1 + cube[side].x * cube_size) + cube[new_side].x * cube_size;
							next_dir = 3;
						} 
					}
					break;
				case 2:
					next_col--;
					if (next_col < grid_col * cube_size) {
						int new_side = rotate_left(side, up);
						if (cube[new_side].up == (up + 3) % 6) { // LEFT -> LEFT
							next_row = (cube_size - 1 - row + cube[side].y * cube_size) + cube[new_side].y * cube_size;
							next_col = cube[new_side].x * cube_size;
							next_dir = 0;
						} else if (cube[new_side].up == side) { // LEFT -> UP
							next_row = cube[new_side].y * cube_size;
							next_col = row + (cube[new_side].x - cube[side].y) * cube_size;
							next_dir = 1;
						} else if (cube[new_side].up == up) { // LEFT -> RIGHT
							next_row = row + (cube[new_side].y - cube[side].y) * cube_size;
							next_col = (cube[new_side].x + 1) * cube_size - 1;
							next_dir = 2;
						} else if (cube[new_side].up == (side + 3) % 6) { // LEFT -> DOWN
							next_row = (cube[new_side].y + 1) * cube_size - 1;
							next_col = (cube_size - 1 - row + cube[side].y * cube_size) + cube[new_side].x * cube_size;
							next_dir = 3;
						} 
					}
					break;
				case 3:
					next_row--;
					if (next_row < grid_row * cube_size) {
						int new_side = up;
						if (cube[new_side].up == rotate_left(side, up)) { // UP -> LEFT
							next_row = col + (cube[new_side].y - cube[side].x) * cube_size;
							next_col = cube[new_side].x * cube_size;
							next_dir = 0;
						} else if (cube[new_side].up == side) { // UP -> UP
							next_row = cube[new_side].y * cube_size;
							next_col = (cube_size - 1 - col + cube[side].x * cube_size) + cube[new_side].x * cube_size;
							next_dir = 1;
						} else if (cube[new_side].up == rotate_left(side, (up + 3) % 6)) { // UP -> RIGHT
							next_row = (cube_size - 1 - col + cube[side].x * cube_size) + cube[new_side].y * cube_size;
							next_col = (cube[new_side].x + 1) * cube_size - 1;
							next_dir = 2;
						} else if (cube[new_side].up == (side + 3) % 6) { // UP -> DOWN
							next_row = (cube[new_side].y + 1) * cube_size - 1;
							next_col = col + (cube[new_side].x - cube[side].x) * cube_size;
							next_dir = 3;
						}
					}
					break;
			}
			if (map[next_row][next_col] == '.') {
				row = next_row;
				col = next_col;
				dir = next_dir;
			}
			
		}
	}
}

class Main : GLib.Object {
	private static int parse_int(string instructions, ref int index) {
		int start = index;
		while (instructions[index] >= '0' && instructions[index] <= '9') {
			index++;
		}
		return int.parse(instructions[start:index]);
	}

	private static int walk(string[] map, int start_row, int start_col, World world, string instructions) {
		int index = 0;
		int row = start_row;
		int col = start_col;
		int direction = 0;
		while (index < instructions.length) {
			if (instructions[index] >= '0' && instructions[index] <= '9') {
				int distance = parse_int(instructions, ref index);
				world.move(distance, map, ref direction, ref row, ref col);
			} else if (instructions[index] == 'L') {
				direction = direction - 1;
				if (direction < 0 ) {
					direction = 3;
				}
				index++;
			} else {
				direction = (direction + 1) % 4;
				index++;
			}
		}
		return 1000 * (row + 1) + 4 * (col + 1) + direction;
	}

	private static void fold(ref Segment[,] segments, int x, int y, int dx, int dy, int top, int up) {
		if (dx == -1) {
			top = rotate_left(top, up);
		} else if (dx == 1) {
			top = rotate_left(top, (up + 3) % 6);
		} else if (dy == -1) {
			int new_up = (top + 3) % 6;
			top = up;
			up = new_up;
		} else if (dy == 1) {
			int new_up = top;
			top = (up + 3) % 6;
			up = new_up;
		}
		segments[x, y].side = top;
		segments[x, y].up = up;
		if (x < segments.length[0] - 1 && segments[x + 1, y] != null && dx != -1) {
			fold(ref segments, x + 1, y, 1, 0, top, up);
		}
		if (x > 0 && segments[x - 1, y] != null && dx != 1) {
			fold(ref segments, x - 1,  y, -1, 0, top, up);
		}
		if (y < segments.length[1] - 1 && segments[x, y + 1] != null && dy != -1) {
			fold(ref segments, x,  y + 1, 0, 1, top, up);
		}
		if (y > 0 && segments[x, y - 1] != null && dy != 1) {
			fold(ref segments, x,  y - 1, 0, -1, top, up);
		}
	}
	
	const int SEGMENT_SIZE = 50;

	private static CubeWorld create_cube(Line[] rows, Line[] cols) {
		int segmets_y = rows.length / SEGMENT_SIZE;
		int segmets_x = cols.length / SEGMENT_SIZE;
		Segment[,] segments = new Segment[segmets_x, segmets_y];
		int base_x = -1;
		int base_y = -1;
		for (int y = 0; y < segmets_y; y++) {
			for (int x = 0; x < segmets_x; x++) {
				if (cols[x * SEGMENT_SIZE].first <= y * SEGMENT_SIZE 
					&& cols[x * SEGMENT_SIZE].last >= y * SEGMENT_SIZE
					&& rows[y * SEGMENT_SIZE].first <= x * SEGMENT_SIZE
					&& rows[y * SEGMENT_SIZE].last >= x * SEGMENT_SIZE
				) {
					if (base_x == -1) {
						base_x = x;
						base_y = y;
					}
					segments[x, y] = new Segment(x, y);
				}
			}
		}
		fold(ref segments, base_x, base_y, 0, 0, TOP, UP);
		Segment[] cube = new Segment[6];
		for (int y = 0; y < segmets_y; y++) {
			for (int x = 0; x < segmets_x; x++) {
				if (segments[x, y] == null) {
					continue;
				}
				cube[segments[x, y].side] = segments[x, y];
			}
		}
		return new CubeWorld(cube, segments, SEGMENT_SIZE);
	}

	public static int main(string[] args) {
		try {
			string content;
			FileUtils.get_contents("../input/input22.txt", out content);
			
			string[] map = content.split("\n");
			int last = map.length - 1;
			if (map[last].length == 0) {
				last--;
			}
			string instructions = map[last];
			Line[] rows = new Line[last - 1];
			
			int max_length = 0;
			for (int row = 0; row < last - 1; row++) {
				int first = 0;
				while (map[row][first] == ' ') {
					first++;
				}
				rows[row] = new Line(first, map[row].length - 1);
				if (map[row].length > max_length) {
					max_length = map[row].length;
				}
			}
			Line[] cols = new Line[max_length];
			for (int col = 0; col < max_length; col++) {
				int start = 0;
				while (map[start].length <= col || map[start][col] == ' ') {
					start++;
				}
				int end = start;
				while (map[end].length > col && map[end][col] != ' ') {
					end++;
				}
				cols[col] = new Line(start, end - 1);
			}
			FlatWorld flatWorld = new FlatWorld(rows, cols);
			int score = walk(map, 0, rows[0].first, flatWorld, instructions);
			print("%d\n", score);
			CubeWorld cube = create_cube(rows, cols);
			int score2 = walk(map, 0, rows[0].first, cube, instructions);
			print("%d\n", score2);
		} catch (GLib.FileError err) {
			GLib.error(err.message);
		}
	
		return 0;
	}
}