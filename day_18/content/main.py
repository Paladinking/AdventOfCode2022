#!/usr/bin/python3
from functools import reduce
    
def create_outer(values, max_pos, min_pos):
    outer = set()
    visited = set()
    to_visit = [(max_pos[0] - 1, max_pos[1] - 1, max_pos[2] - 1)]
    
    while len(to_visit) > 0:
        pos = to_visit[-1]
        to_visit.pop()
        if pos in outer or pos in values:
            continue
        outer.add(pos)
        if (pos[0] >= max_pos[0] or pos[1] >= max_pos[1] or pos[2] >= max_pos[2]) or (pos[0] <= min_pos[0] or pos[1] <= min_pos[1] or pos[2] <= min_pos[2]):
            continue

        for side in {(0, 0, -1), (0, 0, 1), (0, -1, 0), (0, 1, 0), (-1, 0, 0), (1, 0, 0)}:
            neighbor = (pos[0] + side[0], pos[1] + side[1], pos[2] + side[2])
            to_visit.append(neighbor)
    
    return outer

def main():
    with open("../input/input18.txt", "r") as file:
        data = map(lambda line : tuple(map(lambda v : int(v),line.strip().split(','))), file.readlines())
        values = set(data)
        free_sides = 0
        fully_free_sides = 0
        
        max_pos = reduce(lambda v, e : (max(v[0], e[0]), max(v[1], e[1]), max(v[2], e[2])), values)
        min_pos = reduce(lambda v, e : (min(v[0], e[0]), min(v[1], e[1]), min(v[2], e[2])), values)
        max_pos = (max_pos[0] + 2, max_pos[1] + 2, max_pos[2] + 2)
        min_pos = (min_pos[0] - 2, min_pos[1] - 2, min_pos[2] - 2)

        outer = create_outer(values, max_pos, min_pos)
        
        for point in values:
            for side in {(0, 0, -1), (0, 0, 1), (0, -1, 0), (0, 1, 0), (-1, 0, 0), (1, 0, 0)}:
                neighbor = (point[0] + side[0], point[1] + side[1], point[2] + side[2])
                if not neighbor in values:
                    free_sides += 1
                if neighbor in outer:
                    fully_free_sides += 1
                
        print(free_sides)
        print(fully_free_sides)

if __name__ == "__main__":
    main()

