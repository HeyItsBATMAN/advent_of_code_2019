require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt")
  .map(&.gsub("<", "").gsub(">", "").split(","))
  .map(&.map(&.split("=")[1].to_i))

class Moon
  getter pos : Array(Int32)
  getter vel : Array(Int32)
  @orig : Array(Int32)

  def initialize(pos : Array(Int32))
    @pos, @vel = pos.dup, [0, 0, 0]
    @orig = pos.dup
  end

  def is_orig(axis)
    @pos[axis] == @orig[axis] && @vel[axis] == 0
  end
end

def part1
  moons = INPUT.dup.map { |moon| Moon.new(moon) }
  (1..1000).each do |_|
    moons.combinations(2).each { |pair| (0..2).each { |axis|
      next if pair[0].pos[axis] == pair[1].pos[axis]
      if pair[0].pos[axis] < pair[1].pos[axis]
        pair[0].vel[axis] += 1
        pair[1].vel[axis] -= 1
      else
        pair[0].vel[axis] -= 1
        pair[1].vel[axis] += 1
      end
    } }

    moons.each { |moon| (0..2).each { |axis|
      moon.pos[axis] += moon.vel[axis]
    } }
  end

  moons
    .sum { |moon| moon.pos.map(&.abs).sum * moon.vel.map(&.abs).sum }
end

def part2
  moons = INPUT.dup.map { |moon| Moon.new(moon) }
  origs = [0, 0, 0]
  (0..UInt64::MAX).each do |step|
    if step != 0
      (0..2).each { |axis|
        next if origs[axis] != 0
        if moons.map { |moon| moon.is_orig(axis) }.select { |n| !n }.empty?
          origs[axis] = step
        end
      }
      break if origs.count(0) == 0
    end

    moons.combinations(2).each { |pair| (0..2).each { |axis|
      next if pair[0].pos[axis] == pair[1].pos[axis]
      if pair[0].pos[axis] < pair[1].pos[axis]
        pair[0].vel[axis] += 1
        pair[1].vel[axis] -= 1
      else
        pair[0].vel[axis] -= 1
        pair[1].vel[axis] += 1
      end
    } }

    moons.each { |moon| (0..2).each { |axis|
      moon.pos[axis] += moon.vel[axis]
    } }
  end
  origs = origs.map(&.to_u64)
  origs[0].lcm(origs[1].lcm(origs[2]))
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }.total_milliseconds
puts Benchmark.realtime { puts "Part 2 #{part2}" }.total_milliseconds
