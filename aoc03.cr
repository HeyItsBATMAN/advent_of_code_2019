require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt").map { |line|
  line.split(",").map { |op| op[0].to_s * op.chars.skip(1).join.to_i }.join
}

POINTS = [] of Array(Array(Int32))

def part1
  INPUT.each { |line|
    x, y = 0, 0
    POINTS << line.chars.map { |c|
      case c
      when 'R' then x += 1
      when 'L' then x -= 1
      when 'D' then y += 1
      when 'U' then y -= 1
      end
      [x, y]
    }
  }
  (POINTS[0] & POINTS[1]).map { |arr| (arr[0] - 0).abs + (arr[1] - 0).abs }.min
end

def part2
  (POINTS[0] & POINTS[1]).map { |arr|
    2 + POINTS[0].index(arr).not_nil! + POINTS[1].index(arr).not_nil!
  }.min
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }.total_milliseconds
puts Benchmark.realtime { puts "Part 2 #{part2}" }.total_milliseconds
