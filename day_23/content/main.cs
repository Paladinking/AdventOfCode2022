using System;
using System.Collections.Generic;

public class CsMain {

	public static bool HasNeighbors(Dictionary<(int, int), int> elves, (int x, int y) pos) {
		return elves.ContainsKey((pos.x - 1, pos.y - 1)) || elves.ContainsKey((pos.x - 1, pos.y))
			|| elves.ContainsKey((pos.x - 1, pos.y + 1)) || elves.ContainsKey((pos.x, pos.y - 1))
			|| elves.ContainsKey((pos.x, pos.y + 1)) || elves.ContainsKey((pos.x + 1, pos.y - 1))
			|| elves.ContainsKey((pos.x + 1, pos.y)) || elves.ContainsKey((pos.x + 1, pos.y + 1));
	}

	public static void RunRounds(Dictionary<(int, int), int> elves, List<(int x, int y)> next_pos, int n) {
		(int x, int y)[] directions = {(0, -1), (0, 1), (-1, 0), (1, 0)};
		int directions_index = 0;
		int rounds = 0;
		while (true) {
			if (n == rounds) {
				int min_x = Int32.MaxValue;
				int max_x = Int32.MinValue;
				int min_y = Int32.MaxValue;
				int max_y = Int32.MinValue;
				foreach(KeyValuePair<(int x, int y), int> kvp in elves) {
					if (kvp.Key.x < min_x) min_x = kvp.Key.x;
					if (kvp.Key.x > max_x) max_x = kvp.Key.x;
					if (kvp.Key.y < min_y) min_y = kvp.Key.y;
					if (kvp.Key.y > max_y) max_y = kvp.Key.y;
				}
				int size = (1 + max_x - min_x) * (1+ 	max_y - min_y);
				Console.WriteLine("{0}", size - elves.Count);
			}
			rounds++;
			Dictionary<(int, int), int> proposals = new Dictionary<(int, int), int>();
			foreach(KeyValuePair<(int, int), int> kvp in elves){
				(int x, int y) pos = kvp.Key;
				next_pos[kvp.Value] = pos;
				if (!HasNeighbors(elves, pos)) {
					continue;
				}

				for (int i = 0; i < 4; i++) {
					(int x, int y) point = directions[(i + directions_index) % 4];
					int px = point.x + pos.x;
					int py = point.y + pos.y;

					if (point.x == 0) {
						if (!elves.ContainsKey((px - 1, py)) && !elves.ContainsKey((px, py)) && !elves.ContainsKey((px + 1, py))) {
							int val;
							if (proposals.TryGetValue((px, py), out val)) {
								proposals[(px, py)] += 1;
							} else {
								proposals[(px, py)] = 1;
							}
							next_pos[kvp.Value] = (px, py);
							break;
						}
					} else {
						if (!elves.ContainsKey((px, py - 1)) && !elves.ContainsKey((px, py)) && !elves.ContainsKey((px, py + 1))) {
							int val;
							if (proposals.TryGetValue((px, py), out val)) {
								proposals[(px, py)] += 1;
							} else {
								proposals[(px, py)] = 1;
							}
							next_pos[kvp.Value] = (px, py);
							break;
						}
					}
				}
			}
			if (proposals.Count == 0) break;

			directions_index = (directions_index + 1) % 4;
			Dictionary<(int, int), int> new_elves = new Dictionary<(int, int), int>();
			foreach(KeyValuePair<(int, int), int> kvp in elves) {
				int count;
				if (proposals.TryGetValue(next_pos[kvp.Value], out count) && count == 1) {
					new_elves.Add(next_pos[kvp.Value], kvp.Value);
				} else {
					new_elves.Add(kvp.Key, kvp.Value);
				}
			}
			elves = new_elves;
		}
		Console.WriteLine("{0}", rounds);
	}

	public static void Main() {
		Dictionary<(int, int), int> elves = new Dictionary<(int, int), int>();
		List<(int, int)> proposals = new List<(int, int)>();
		string[] lines = System.IO.File.ReadAllLines("../input/input23.txt");
		int count = 0;
		for (int i = 0; i < lines.Length; i++) {
			for (int j = 0; j < lines[i].Length; j++) {
				if (lines[i][j] == '#') {
					elves.Add((j, i), count++);
					proposals.Add((0, 0));
				}
			}
		}
		RunRounds(elves, proposals, 10);
	}
}