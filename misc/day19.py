import heapq

def get_int(line, index):
    end = index + 1
    while line[end] in '0123456789':
        end += 1
    return int(line[index:end])

def to_blueprint(line):
    parts = line.split('.')[:-1]
    return (
        (get_int(parts[0], 34), 0, 0), 
        (get_int(parts[1], 23), 0, 0),
        (get_int(parts[2], 27), get_int(parts[2], 37), 0),
        (get_int(parts[3], 24), 0, get_int(parts[3], 34))
    )
    
    
def affords(robot, resources):
    return robot[0] <= resources[0] and robot[1] <= resources[1] and robot[2] <= resources[2]
    
# end : time == 0
# Form : (-(geodes + geodes_robots * time_remaing), (robots,), (resources,), geodes, time)
def is_worse(best, node):
    return best[1][0] >= node[1][0] and best[1][1] >= node[1][1] and best[1][2] >= node[1][2] and best[1][3] >= node[1][3] and best[2][0] >= node[2][0] and best[2][1] >= node[2][1] and best[2][2] >= node[2][2] and best[3] >= node[3]

def find_best(blueprint, total_time):
    to_visit = [(0, (1, 0, 0, 0), (0, 0, 0), 0, total_time)]
    best = 0
    
    exspensive = (0, 0, 0)
    for robot in blueprint:
        for i in range(3):
            if robot[i] > exspensive[i]:
                exspensive = exspensive[0:i] + robot[i:i+1] + exspensive[i+1:3]
    while len(to_visit) > 0:
        top = to_visit.pop()
        geodes = top[3] + top[1][3] 
        time = top[4] - 1
        if (time == 0):
            if geodes > best:
                best = geodes
            continue
        if ((time)**2) // 2 < best - geodes - top[1][3] * time:
            continue
        resources = (top[2][0] + top[1][0], top[2][1] + top[1][1], top[2][2] + top[1][2])
        if affords(blueprint[3], top[2]): 
            next_robots = (top[1][0], top[1][1], top[1][2], top[1][3] + 1)
            next_resources = (resources[0] - blueprint[3][0], resources[1] - blueprint[3][1], resources[2] - blueprint[3][2])
            cost = - (geodes + next_robots[3] * time)
            to_visit.append((cost, next_robots, next_resources, geodes, time))  
        if top[1][0] < exspensive[0] and affords(blueprint[0], top[2]):
            next_robots = (top[1][0] + 1, top[1][1], top[1][2], top[1][3])
            next_resources = (resources[0] - blueprint[0][0], resources[1] - blueprint[0][1], resources[2] - blueprint[0][2])
            cost = - (geodes + next_robots[3] * time)
            to_visit.append((cost, next_robots, next_resources, geodes, time))
        if top[1][1] < exspensive[1] and affords(blueprint[1], top[2]):
            next_robots = (top[1][0], top[1][1] + 1, top[1][2], top[1][3])
            next_resources = (resources[0] - blueprint[1][0], resources[1] - blueprint[1][1], resources[2] - blueprint[1][2])
            cost = - (geodes + next_robots[3] * time)
            to_visit.append((cost, next_robots, next_resources, geodes, time))
        if top[1][2] < exspensive[2] and affords(blueprint[2], top[2]): 
            next_robots = (top[1][0], top[1][1], top[1][2] + 1, top[1][3])
            next_resources = (resources[0] - blueprint[2][0], resources[1] - blueprint[2][1], resources[2] - blueprint[2][2])
            cost = - (geodes + next_robots[3] * time)
            to_visit.append((cost, next_robots, next_resources, geodes, time))
        
        cost = - (geodes + top[1][3] * time)
        if top[2][0] < exspensive[0]:
            to_visit.append((cost, top[1], resources, geodes, time))
    return best
            

def main():
    with open("../input/input19.txt", "r") as file:
        data = file.readlines()
        blueprints = list(map(lambda line : to_blueprint(line.strip()), data))
        score = 0
        for i, blueprint in enumerate(blueprints):
            score += (i + 1) * find_best(blueprint, 24)
            #return
        print(score)
        res = find_best(blueprints[0], 32) * find_best(blueprints[1], 32) * find_best(blueprints[2], 32)
        print(res)    


if __name__ == "__main__":
    main()