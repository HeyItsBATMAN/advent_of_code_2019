require "benchmark"

DAY    = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT  = File.read_lines("#{DAY}.txt").join.chars.map(&.to_i)
OFFSET = INPUT.first(7).join.to_i
BASE   = [0, 1, 0, -1]
PHASES = 100

def part1
  input = INPUT.dup
  patterns = input.map_with_index { |_, i|
    BASE.in_groups_of(1, 0).map { |n| n * (i + 1) }.flatten.rotate(1)
  }
  PHASES.times do
    input = input.map_with_index { |_, pi|
      input.map_with_index { |n, ii|
        n * patterns[pi][ii % patterns[pi].size]
      }.sum.to_s.chars.last.to_i
    }
  end
  input.first(8).join.to_i
end

def part2
  input = (INPUT.dup * 10000).skip(OFFSET)
  length = input.size
  PHASES.times do
    index = length - 2
    until index == -1
      input[index] += input[index + 1]
      input[index] %= 10
      index -= 1
    end
  end
  input.first(8).join.to_i
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }.total_milliseconds
puts Benchmark.realtime { puts "Part 2 #{part2}" }.total_milliseconds
