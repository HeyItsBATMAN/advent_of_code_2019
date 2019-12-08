require "benchmark"
require "colorize"

WIDTH  = 25
HEIGHT =  6
DAY    = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT  = File.read_lines("#{DAY}.txt").join.chars
  .map(&.to_i).in_groups_of(WIDTH * HEIGHT).map(&.in_groups_of(WIDTH))

def part1
  fewest_zero = INPUT.min_by { |layer|
    layer.flatten.count(0)
  }.flatten
  fewest_zero.count(1) * fewest_zero.count(2)
end

def part2
  image = INPUT.last

  INPUT.reverse.each { |layer|
    (0...layer.size).each { |y| (0...layer[y].size).each { |x|
      color = layer[y][x]
      next if color == 2
      image[y][x] = color.not_nil!
    } }
  }

  image
end

colors = [:light_red, :light_green, :light_yellow, :light_blue, :light_magenta, :light_cyan]

puts Benchmark.realtime { puts "Part 1 #{part1}" }.total_milliseconds
puts Benchmark.realtime {
  puts "Part 2"
  part2.map_with_index { |line, i|
    puts line.join.gsub("0", " ").gsub("1", "█").colorize(colors[i])
  }
}.total_milliseconds
