require "benchmark"

DAY    = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT  = File.read_lines("#{DAY}.txt").join.split(",").map(&.to_i)
OUTPUT = 19690720 # Output for part 2

def solve(noun, verb)
  arr = INPUT.dup # For bruteforce re-use in part 2
  i, arr[1], arr[2] = 0, noun, verb
  until arr[i] == 99
    case arr[i]
    when 1 then arr[arr[i + 3]] = arr[arr[i + 1]] + arr[arr[i + 2]]
    when 2 then arr[arr[i + 3]] = arr[arr[i + 1]] * arr[arr[i + 2]]
    end
    i += 4
  end
  arr[0]
end

def part2
  # Could be reversed instead of brute forced
  (0..99).each { |noun| (0..99).each { |verb|
    return "#{noun}#{verb}" if solve(noun, verb) == OUTPUT
  } }
end

puts Benchmark.realtime { puts "Part 1 #{solve(12, 2)}" }.total_milliseconds
puts Benchmark.realtime { puts "Part 2 #{part2}" }.total_milliseconds
