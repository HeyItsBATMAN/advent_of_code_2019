require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File
  .read("#{DAY}.txt")
  .split("\n")
  .reject(&.empty?)

# .map(&.to_i)
# .map{|i| i }

class Solution
  def solve
    # puts INPUT
    puts Benchmark.realtime { puts "Part 1 #{part1}" }
    puts Benchmark.realtime { puts "Part 2 #{part2}" }
  end

  def part1
  end

  def part2
  end
end

Solution.new.solve
