# Advent of Code 2022
Solving the advent of code programming challenge with a new language every day!
https://adventofcode.com/

Day 1: Ruby  
Day 2: Ada  
Day 3: Perl  
Day 4: Haskell  
Day 5: Cobol  
Day 6: Go  
Day 7: Lisp  
Day 8: PHP  
Day 9: Erlang  
Day 10: Basic  
Day 11: Elixir  
Day 12: Lua  
Day 13: Java  
Day 14: Scala  
Day 15: C++  
Day 16: Python  
Day 17: Swift  
Day 18: Zig  
Day 19: C  
Day 20: Typescript  
Day 21: Carbon  
Day 22: Vala  
Day 23: C#  
Day 24: Kotlin  
Day 25: Rust  


# To run
docker run --rm -it -v %cd%\day_x\content:/aoc/content -v %cd%\input\:/aoc/input aoc_dayx

# To build
docker build day_x -t aoc_dayx

# To clean
docker container prune

docker container rm X

docker image prune

docker image rm X

docker builder prune