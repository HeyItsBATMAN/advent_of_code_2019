require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt").map(&.to_i)

def part1
  INPUT.sum { |mass| reduce(mass) }
end

def part2
  INPUT.sum { |mass|
    res = 0
    while mass > 0
      mass = reduce(mass)
      res += mass
    end
    res
  }
end

def reduce(mass)
  Math.max(0, ((mass / 3).floor - 2).to_i)
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }
puts Benchmark.realtime { puts "Part 2 #{part2}" }
