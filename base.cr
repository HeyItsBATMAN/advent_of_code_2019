require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt")

# INPUT = ""
# puts INPUT

def part1
end

def part2
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }
puts Benchmark.realtime { puts "Part 2 #{part2}" }
