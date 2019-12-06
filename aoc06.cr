require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt").map(&.split(")"))

OBJECTS   = INPUT.map(&.[1])
RELATIONS = INPUT.map(&.reverse).to_h

def traverse(node)
  path = [] of String
  while node = RELATIONS[node]?
    path << node
  end
  path
end

def part1
  OBJECTS.sum { |object| traverse(object).size }
end

def part2
  paths = ["YOU", "SAN"].map { |node| traverse(node) }
  (paths[0] - paths[1]).size + (paths[1] - paths[0]).size
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }.total_milliseconds
puts Benchmark.realtime { puts "Part 2 #{part2}" }.total_milliseconds
