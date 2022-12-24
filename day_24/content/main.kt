import java.awt.Point
import java.io.File
import java.util.*
import kotlin.Comparator
import kotlin.collections.HashSet
import kotlin.experimental.and
import kotlin.experimental.or

const val EMPTY : Byte = 0.toByte()
const val RIGHT : Byte = 1.toByte()
const val DOWN : Byte = 2.toByte()
const val LEFT : Byte = 4.toByte()
const val UP : Byte = 8.toByte()
const val WALL : Byte = 16.toByte()

fun advanceMap(map: Array<ByteArray>): Array<ByteArray> {
   return Array(map.size) {
        y -> ByteArray(map[y].size) {
            x ->
                if (x == 0 || y == 0 || x == map[y].size - 1 || y == map.size - 1) {
                    map[y][x]
                } else {
                    (map[y][(x - 2).mod(map[y].size - 2) + 1] and RIGHT) or
                            (map[(y - 2).mod(map.size - 2) + 1][x] and DOWN) or
                            (map[y][x.mod(map[y].size - 2) + 1] and LEFT) or
                            (map[y.mod(map.size - 2) + 1][x] and UP)
                }
        }
    }
}

class Node(val x: Int, val y : Int, val iteration : Int, val prev : Node?)

val neighborsX : IntArray = intArrayOf(0, -1, 1, 0, 0)
val neighborsY : IntArray = intArrayOf(0, 0, 0, -1, 1)

fun explore(map: Array<ByteArray>, start : Point, goal : Point) : Pair<List<Node>, Array<ByteArray>> {
    val maps: MutableList<Array<ByteArray>> = mutableListOf(map)
    val visited : Array<Array<HashSet<Int>>> = Array(map.size) {
        Array(map[0].size) { HashSet()}
    }
    val queue : PriorityQueue<Node> = PriorityQueue(Comparator.comparing { n -> n.iteration })

    queue.add(Node(start.x, start.y,1,null))
    while (queue.size > 0) {
        val top : Node = queue.remove()
        if (visited[top.y][top.x].contains(top.iteration)) continue
        visited[top.y][top.x].add(top.iteration )

        if (top.x == goal.x && top.y == goal.y) {
            val list : MutableList<Node> = mutableListOf(top)
            var node = top.prev
            while (node != null) {
                list.add(node)
                node = node.prev
            }
            return Pair(list.reversed(), maps[top.iteration - 1])
        }
        if (top.iteration == maps.size) {
            maps.add(advanceMap(maps[maps.size - 1]))
        }

        for (i in neighborsX.indices) {
            val x = neighborsX[i]
            val y = neighborsY[i]
            if (top.y + y < 0 || top.x + x < 0 || top.y + y >= map.size || top.x + x >= map[0].size) continue
            if (maps[top.iteration][top.y + y][top.x + x] == EMPTY) {
                queue.add(Node(top.x + x, top.y + y, top.iteration + 1, top))
            }
        }
    }
    return Pair(emptyList(), map)
}

fun main() {
    val lines: List<String> = File("../input/input24.txt").bufferedReader().readLines()

    val map: Array<ByteArray> = Array(lines.size) { i ->
        ByteArray(lines[i].length) { j ->
            when (lines[i][j]) {
                '#' -> WALL
                '.' -> EMPTY
                '>' -> RIGHT
                'v' -> DOWN
                '<' -> LEFT
                '^' -> UP
                else -> WALL
            }
        }
    }
    val start = Point(1, 0)
    val goal = Point(map[0].size - 2, map.size - 1)
    val (path1, map1) = explore(map, start, goal)
    println(path1.size - 1)
    val (path2, map2) = explore(map1, goal, start)
    val (path3, _) = explore(map2, start, goal)
    println(path1.size + path2.size + path3.size - 3)
}