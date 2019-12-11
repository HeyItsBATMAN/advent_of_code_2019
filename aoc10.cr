require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt").map(&.chars.map { |e| e == '#' })

def part1
  count = 0
  point = {x: 0, y: 0}
  INPUT.size.times { |y| INPUT[0].size.times { |x|
    next if !INPUT[y][x]
    angle = Set(Float64).new
    INPUT.size.times { |y2| INPUT[0].size.times { |x2|
      next if !INPUT[y2][x2]
      angle << Math.atan2((y2 - y), (x2 - x))
    } }
    if angle.size > count
      count = angle.size
      point = {x: x, y: y}
    end
  } }
  {count, point}
end

def part2
  laser = part1[1]
  x, y = laser[:x], laser[:y]

  dist = ->(point : Array(Int32)) {
    (x - point[0]).abs + (y - point[1]).abs
  }

  hash = Hash(Float64, Array(Array(Int32))).new
  INPUT.size.times { |y2| INPUT[0].size.times { |x2|
    next if !INPUT[y2][x2]
    next if x == x2 && y == y2
    angle = -1 * Math.atan2((y2 - y), (x2 - x))
    hash[angle] = [] of Array(Int32) if !hash.has_key?(angle)
    hash[angle] << [x2, y2]
  } }

  # Clockwise from start_idx
  angles = hash.keys.sort.reverse

  # Sort by distance, furthest to closest
  hash.keys.each { |key|
    hash[key] = hash[key].sort { |a, b| dist.call(a) <=> dist.call(b) }
  }

  destroyed = 0
  start_idx = angles.index(Math::PI / 2).not_nil!
  angles.rotate(start_idx).cycle { |angle|
    # Get closest for current angle
    if astr = hash[angle].shift?
      destroyed += 1
      if destroyed == 200
        return astr[0] * 100 + astr[1]
      end
    end
  }
end

puts Benchmark.realtime { puts "Part 1 #{part1[0]}" }
puts Benchmark.realtime { puts "Part 2 #{part2}" }
