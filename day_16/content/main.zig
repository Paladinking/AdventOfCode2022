const std = @import("std");


const Valve = struct {
	name : [2]u8,
	flow : isize,
	open : bool,
	tunnels : [][2] u8,
	costs : std.StringHashMap(isize)
};

pub fn openValves(valves : *std.StringHashMap(Valve), time : isize, pos : [2]u8) isize {
	var valve = valves.getPtr(&pos).?;
	if (time < 0 or valve.open) {
		return 0;
	}
	var max : isize = 0;
	valve.open = true;
	var iter = valves.iterator();
	while (iter.next()) |v| {
		if (v.value_ptr.flow != 0) {
			var delta = valve.costs.get(&v.value_ptr.name).? + 1;
			var res = openValves(valves, time - delta, v.value_ptr.name);
			if (res > max) {
				max = res;
			}
		}
	}
	valve.open = false;
	return max + time * valve.flow;
}

pub fn openValvesElephant(valves : *std.StringHashMap(Valve), time1 : isize, time2 : isize, pos1 : [2]u8, pos2 : [2]u8) isize {
	var valve1 = valves.getPtr(&pos1).?;
	var valve2 = valves.getPtr(&pos2).?;
	if (time1 < 0 or valve1.open) {
		return openValves(valves, time2, pos2);
	} else if (time2 < 0 or valve2.open) {
		return openValves(valves, time1, pos1);
	}
	
	
	var max : isize = 0;
	valve1.open = true;
	valve2.open = true;
	var iter1 = valves.iterator();
	while (iter1.next()) |v1| {
		var iter2 = valves.iterator();
		while (iter2.next()) |v2| {
			if (v1.value_ptr.flow != 0 and v2.value_ptr.flow != 0 and v1.value_ptr != v2.value_ptr) {
				var delta1 = valve1.costs.get(&v1.value_ptr.name).? + 1;
				var delta2 = valve2.costs.get(&v2.value_ptr.name).? + 1;
				var res = openValvesElephant(valves, time1 - delta1, time2 - delta2, v1.value_ptr.name, v2.value_ptr.name);
				if (res > max) {
					max = res;
				}
			}
		}
	}
	valve1.open = false;
	valve2.open = false;
	return max + time1 * valve1.flow + time2 * valve2.flow;
}

fn visit(valves: *std.StringHashMap(Valve), pos : [2]u8, dest : [2]u8) ?isize {
	if (pos[0] == dest[0] and pos[1] == dest[1]) {
		return 0;
	}
	var cur = valves.getPtr(&pos).?;
	if (cur.open) {
		return null;
	}
	cur.open = true;
	var min : ?isize = null;
	for (cur.tunnels) |v| {
		var res = visit(valves, v, dest);
		if (res) |*r| {
			if (min) |*m| {
				if (r.* < m.*) {
					min = res;
				}
			} else {
				min = res;
			}
		}
	}
	cur.open = false;
	if (min) |*m| {
		return m.* + 1;
	}
	return null;
}

pub fn updateCosts(valves : *std.StringHashMap(Valve)) anyerror ! void {
	var it1 = valves.iterator();
	while(it1.next()) |valve| {
		var it2 = valves.iterator();
		var pos = valve.value_ptr.name;
		while (it2.next()) |v| {
			var cost = visit(valves, pos, v.value_ptr.name).?;
			try valves.getPtr(&pos).?.costs.put(&v.value_ptr.name, cost);
		}
	}
}


pub fn main() anyerror ! void {
	var gp = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
	defer _ = gp.deinit();
	const allocator = gp.allocator();
	
	
    var file = try std.fs.cwd().openFile("../input/input16.txt", .{});
	defer file.close();
	const file_buffer = try file.readToEndAlloc(allocator, 10000);
	defer allocator.free(file_buffer);
	
	var iter = std.mem.tokenize(u8, file_buffer, "\n");
	
	var valves = std.StringHashMap(Valve).init(allocator);
	defer {
		var itr = valves.iterator();
		while (itr.next()) |valve| {
			allocator.free(valve.value_ptr.tunnels);
			valve.value_ptr.costs.deinit();
		}
		valves.deinit();
	}

	while (iter.next()) |line| {
		var valve = line[6..8];
		var num_bytes = std.mem.sliceTo(line[23..], ';');

		var val : isize = 0;
		for (num_bytes) |c| {
			val *= 10;
			val += c - '0';
		}
		var tunnel_bytes : []const u8 = undefined;
		if (line[31 + num_bytes.len] == 's') {
			tunnel_bytes = line[(47 + num_bytes.len)..];
		} else {
			tunnel_bytes = line[(46 + num_bytes.len)..];
		}
		
		
		var tunnels = std.ArrayList([2]u8).init(allocator);
		var itr = std.mem.tokenize(u8, tunnel_bytes, ",");
		while (itr.next()) |tunnel| {
			try tunnels.append(tunnel[1..3].*);
		}
		
		try valves.put(valve, Valve {
			.name = valve.*, 
			.flow = val, 
			.open = false, 
			.tunnels = try tunnels.toOwnedSlice(),
			.costs = std.StringHashMap(isize).init(allocator)
		});
    }
	
	
	try updateCosts(&valves);
	std.debug.print("{?}\n", .{openValves(&valves, 30, "AA".*)});
	std.debug.print("{?}\n", .{openValvesElephant(&valves, 26, 26, "AA".*, "AA".*)});
   
}