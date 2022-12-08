<?php

$is_visible = function(int $row, int $col, array $trees): bool {
	if ($row == 0 || $col == 0 || $row == count($trees) - 1 || $col == count($trees[0]) - 1) {
		return true;
	}
	$visible = true;
	for ($r = 0; $r < $row; $r++) {
		if ($trees[$r][$col] >= $trees[$row][$col]) {
			$visible = false;
		}
	}
	if ($visible) return true;
	$visible = true;
	for ($r = $row + 1; $r < count($trees); $r++) {
		if ($trees[$r][$col] >= $trees[$row][$col]) {
			$visible = false;
		}
	}
	if ($visible) return true;
	$visible = true;
	for ($c = 0; $c < $col; $c++) {
		if ($trees[$row][$c] >= $trees[$row][$col]) {
			$visible = false;
		}
	}
	if ($visible) return true;
	for ($c = $col + 1; $c < count($trees[$row]); $c++) {
		if ($trees[$row][$c] >= $trees[$row][$col]) {
			return false;
		}
	}
	return true;
};

$scenic_score = function(int $row, int $col, array $trees) : int {
	$left = 0;
	$right = 0;
	$up = 0;
	$down = 0;
	for ($r = $row - 1; $r >= 0; $r--) {
		$up++;
		if ($trees[$r][$col] >= $trees[$row][$col]) {
			break;
		}
	}
	for ($r = $row + 1; $r < count($trees); $r++) {
		$down++;
		if ($trees[$r][$col] >= $trees[$row][$col]) {
			break;
		}
	}
	for ($c = $col - 1; $c >= 0; $c--) {
		$left++;
		if ($trees[$row][$c] >= $trees[$row][$col]) {
			break;
		}
	}
	for ($c = $col + 1; $c < count($trees[0]); $c++) {
		$right++;
		if ($trees[$row][$c] >= $trees[$row][$col]) {
			break;
		}
	}
	return $up * $down * $left * $right;
};

$lines = file('../input/input8.txt', FILE_IGNORE_NEW_LINES);

$trees = array_map(fn($line): array => array_map(fn($char) : int => ord($char) - ord('0'), str_split($line)), $lines);

$visible = 0;
$most_scenic = 0;

for ($row = 0; $row < count($trees); $row++) {
	for ($col = 0; $col < count($trees[$row]); $col++) {
		if ($is_visible($row, $col, $trees)) {
			$visible++;
		}
		$s = $scenic_score($row, $col, $trees);
		if ($s > $most_scenic) {
			$most_scenic = $s;
		}
	}
}
echo $visible, "\n";
echo $most_scenic, "\n";

?>