require "benchmark"

INPUT = "137683-596253".split("-").map(&.to_i)

def has_adjacent(num, part2 = false)
  num.uniq.select { |n| part2 ? num.count(n) == 2 : num.count(n) >= 2 }.any?
end

def increasing(num)
  num.sort == num
end

def solve
  p1 = (INPUT[0]..INPUT[1]).map(&.to_s.chars)
    .select { |n| increasing(n) && has_adjacent(n) }
  p2 = p1.select { |n| has_adjacent(n, true) }
  "Part 1 #{p1.size}\tPart 2 #{p2.size}"
end

puts Benchmark.realtime { puts solve }.total_milliseconds
