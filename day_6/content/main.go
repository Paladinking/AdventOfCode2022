package main

import (
    "bufio"
    "fmt"
    "log"
    "os"
)


func allDifferent(bytes []byte, size int, offset int) bool {
	for i := 0; i < size; i++ {
		for j := i + 1; j < size; j++ {
			if bytes[i + offset] == bytes[j + offset] {
				return false;
			}
		}
	}
	return true;
}

func findIdentifier(bytes []byte, size int) int {
	for i := 0; i < len(bytes); i++ {
		if allDifferent(bytes, size, i) {
			return i + size;
		}
	} 
	return -1;
}

func main() {
    file, err := os.Open("../input/input6.txt")
    if err != nil {
        log.Fatal(err)
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)

	scanner.Scan()
	data := scanner.Bytes()
    fmt.Println(findIdentifier(data, 4));
    fmt.Println(findIdentifier(data, 14));
}
