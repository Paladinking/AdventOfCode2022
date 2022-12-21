interface Filesystem {
	readFile: (path : string, encoding : string, callback : (err : string, data : string) => void) => void;
}

declare function require(name:string) : Filesystem;
const fs = require('fs');

function update(numbers : [number, number][], index : number) : number {
	let len : number = numbers.length;
	let pair : [number, number] = numbers.splice(index, 1)[0];
	let num : number = pair[0];
	if (num >= len) {
		num = num % (len - 1);
	}
	if (num <= -len) {
		num = -((-num) % (len - 1));
	}
	let new_pos = index + num;
	if (new_pos == len - 1 && num > 0) {
		new_pos = 0;
	}
	if (new_pos >= len) {
		new_pos -= len - 1;
	}
	if (new_pos == 0 && num < 0) {
		new_pos = new_pos + len;
	}
	numbers.splice(new_pos, 0, pair);
	if (numbers[index] != pair) {
		index--;
	}
	return index;
}

function mix(numbers : [number, number][]) {
	for(let i : number = 0; i < numbers.length; i++){
		for (let j = 0; j < numbers.length; j++) {
			if (numbers[j][1] == i) {
				update(numbers, j);
				break;
			}
		}
	}

}

function findCoords(numbers : [number, number][]) {
	let nums : number[] = numbers.map((pair : [number, number]) => pair[0]);
	let zero : number = nums.indexOf(0);
	return nums[(1000 + zero) % nums.length] + nums[(2000 + zero) % nums.length] + nums[(3000 + zero) % nums.length];
}
fs.readFile('../input/input20.txt', 'utf8', (err : string, data : string) => {
	let numbers : [number, number][] = data.split('\n').filter((line : string) => line).map((line : string) => [Number(line), 0]);
	for (let i = 0; i < numbers.length; i++) {
		numbers[i][1] = i;
	}
	let enc_numbers : [number, number][] = numbers.map((pair : [number, number]) => [pair[0] * 811589153, pair[1]]);
	mix(numbers);
	
	console.log('\x1b[37m%s\x1b[0m', findCoords(numbers));
	for (let i = 0; i < 10; i++) {
		mix(enc_numbers);
	}
	console.log('\x1b[37m%s\x1b[0m', findCoords(enc_numbers));
});