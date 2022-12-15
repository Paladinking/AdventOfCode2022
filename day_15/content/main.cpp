#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <climits>


struct Point {
	Point() : x(0), y(0) {}
	Point(int x, int y) : x(x), y(y) {}

	int x, y;
};

bool canHaveBeacon(int x, int y, std::vector<std::pair<Point, Point>>& beacons) {
	for (const std::pair<Point, Point>& b : beacons) {
		if (std::abs(b.first.x - x) + std::abs(b.first.y - y) <= std::abs(b.first.x - b.second.x) + std::abs(b.first.y - b.second.y) ){
			return false;
		}
	}
	return true;
}

bool canHaveBeacon(int x, int y, std::vector<std::pair<Point, Point>>& beacons, int min, int max) {
	if (x < min || x > max || y < min || y > max) return false;
	return canHaveBeacon(x, y, beacons);
}

long getFrequency(std::vector<std::pair<Point, Point>>& beacons, int min, int max) {
	for (const std::pair<Point, Point>& b : beacons) {
		int dist = std::abs(b.first.x - b.second.x) + std::abs(b.first.y - b.second.y);
		for (int x = dist + 1, y = 0; y <= dist + 1; x--, y++) {
			int x1 = x + b.first.x, y1 = y + b.first.y;
			int x2 = -x + b.first.x, y2 = y + b.first.y;
			int x3 = x + b.first.x, y3 = -y + b.first.y;
			int x4 = -x + b.first.x, y4 = -y + b.first.y;
			if (canHaveBeacon(x1, y1, beacons, min, max)) {
				return x1 * 4000000l + y1;
			}			
			if (canHaveBeacon(x2, y2, beacons, min, max)) {
				return x2 * 4000000l + y2;
			}			
			if (canHaveBeacon(x3, y3, beacons, min, max)) {
				return x3 * 4000000l + y3;
			}			
			if (canHaveBeacon(x4, y4, beacons, min, max)) {
				return x4 * 40000001 + y4;
			}
		}
	}
	return -1;
}

int main() {
	std::ifstream in("../input/input15.txt");


	std::vector<std::pair<Point, Point>> beacons;
	while(!in.eof()) {
		std::string line;
		std::getline(in, line);
		if (line.size() > 0) {
			size_t pos, offset = 12;
			int x1 = std::stoi(line.substr(offset), &pos);
			offset += pos + 4;
			int y1 = std::stoi(line.substr(offset), &pos);
			offset += pos + 25;
			int x2 = std::stoi(line.substr(offset), &pos);
			offset += pos + 4;
			int y2 = std::stoi(line.substr(offset), &pos);
			beacons.emplace_back(Point(x1, y1), Point(x2, y2));
		}
	}

	int targetY = 2000000, minX = INT_MAX, maxX = INT_MIN;
	for (const std::pair<Point, Point>& b : beacons) {
		int bMinX = b.first.x - std::abs(b.first.x - b.second.x);
		int bMaxX = b.first.x + std::abs(b.first.x - b.second.x);
		minX = std::min(minX, bMinX);
		maxX = std::max(maxX, bMaxX);
	}

	int count = 0;
	for (int x = minX; x <= maxX; ++x) {
		if (!canHaveBeacon(x, targetY, beacons)) {
			for (const std::pair<Point, Point>& bec : beacons) {
				if (bec.second.x == x && bec.second.y == targetY) {
					--count;
					break;
				}
			}
			++count;
		}
	}
	std::cout << count << std::endl;
	std::cout << getFrequency(beacons, 0, 4000000) << std::endl;
}