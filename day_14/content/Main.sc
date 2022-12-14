import scala.io.Source 

object Main extends App {

	def getSpot(tiles : Set[(Int, Int)], sx : Int, sy : Int) : Option[(Int, Int)] = {
		if (!tiles(sx, sy + 1)) {
			return Some((sx, sy + 1))
		}		
		if (!tiles(sx - 1, sy + 1)) {
			return Some((sx - 1, sy + 1))
		}		
		if (!tiles(sx + 1, sy + 1)) {
			return Some((sx + 1, sy + 1))
		}
		return None
		
	}

	@scala.annotation.tailrec
	def placeSand(tiles : Set[(Int, Int)], sand : (Int, Int), maxY : Int) : (Int, Int) = {
		val (sx, sy) = sand
		if (sy > maxY) {
			return sand
		}
		getSpot(tiles, sx, sy) match {
			case None => sand
			case Some(pos) => placeSand(tiles, pos, maxY)
		}
	}

	def addSand(tiles : Set[(Int, Int)]) : Int = {
		@scala.annotation.tailrec
		def inner(tiles : Set[(Int, Int)], sum : Int) : Int = {
			val maxY = tiles.foldLeft(0) {(max, v) => max.max(v._2)}
			val pos = placeSand(tiles, (500, 0), maxY)
			if (pos._2 > maxY) {
				return sum
			}
			inner(tiles + pos, sum + 1)
		}
		inner(tiles, 0)
	}

	def addSandWithFloor(tiles : Set[(Int, Int)]) : Int = {
		val maxY = tiles.foldLeft(0) {(max, v) => max.max(v._2)}
		@scala.annotation.tailrec
		def inner(tiles : Set[(Int, Int)], sum : Int) : Int = {
			val pos = placeSand(tiles, (500, 0), maxY)
			if (pos == (500, 0)) {
				return sum + 1
			}
			inner(tiles + pos, sum + 1)
		}
		inner(tiles, 0)
	}

	val tiles = Source.fromFile("../input/input14.txt")
		.getLines().foldLeft(scala.collection.mutable.Set[(Int, Int)]()) { (m, s) => 
			val corners : Array[(Int, Int)] = s.split(" -> ").map { (str) => 
				val values = str.split(",")
				(values(0).toInt, values(1).toInt)
			}
			m ++= Range(0, corners.length - 1, 1) flatMap {(i) => 
				if (corners(i)._1 == corners(i + 1)._1) {
					Range(corners(i)._2, corners(i + 1)._2, (corners(i + 1)._2 - corners(i)._2).signum).inclusive.map((y) => {
						(corners(i)._1, y)
					})
				} else {
					Range(corners(i)._1, corners(i + 1)._1, (corners(i + 1)._1 - corners(i)._1).signum).inclusive.map((x) => {
						(x, corners(i)._2)
					})
				}
			}
		}.toSet
	println(addSand(tiles))
	println(addSandWithFloor(tiles))
}