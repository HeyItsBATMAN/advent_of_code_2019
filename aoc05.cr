require "benchmark"

DAY = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
# INPUT = File.read_lines("#{DAY}.txt").join("").split(",").map(&.to_i)
INPUT = "3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99".split(",").map(&.to_i)

puts "START"

def get_val(arr, mode, pos)
  return arr[pos] if mode == 1
  return arr[arr[pos]]
end

def solve(id)
  i, arr = 0, INPUT.dup
  skip = [0, 4, 4, 2, 2, 0, 0, 5, 5]

  until arr[i] == 99
    chars = "0000#{arr[i]}".chars.last(5)
    puts "#{chars.join}\t#{arr[i, 4]}"
    op = chars.pop(2).reject { |n| n == 0 }.join.to_i
    chars = chars.reverse.map(&.to_i)

    if op == 1 || op == 2
      val0 = get_val(arr, chars[0], i + 1)
      val1 = get_val(arr, chars[1], i + 2)
      arr[arr[i + 3]] = op == 1 ? (val0 + val1) : (val0 * val1)
    elsif op == 3
      arr[arr[i + 1]] = id
    elsif op == 4
      val = get_val(arr, chars[0], i + 1)
      puts val
      return if val != 0
    elsif op == 5
      if chars[0] != 0
        i = get_val(arr, chars[1], i + 2)
      end
      next
    elsif op == 6
      if chars[0] == 0
        i = get_val(arr, chars[1], i + 2)
      end
      next
    elsif op == 7
      val1 = get_val(arr, chars[0], i + 1)
      val2 = get_val(arr, chars[1], i + 2)
      if val1 < val2
        arr[arr[i + 3]] = 1
      else
        arr[arr[i + 3]] = 0
      end
    elsif op == 8
      val1 = get_val(arr, chars[0], i + 1)
      val2 = get_val(arr, chars[1], i + 2)
      if val1 == val2
        arr[arr[i + 3]] = 1
      else
        arr[arr[i + 3]] = 0
      end
    else
      puts "op #{op}"
      return
    end
    i += skip[op]
  end
end

# solve(1)
solve(5)

def part1
end

def part2
end

# puts Benchmark.realtime { puts "Part 1 #{part1}" }
# puts Benchmark.realtime { puts "Part 2 #{part2}" }
