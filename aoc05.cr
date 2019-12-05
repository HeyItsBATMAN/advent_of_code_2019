require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt").join("").split(",").map(&.to_i)

def get_val(arr, mode, pos)
  return arr[pos] if mode == 1
  return arr[arr[pos]]
end

def solve(id)
  i, arr = 0, INPUT.dup
  skip = [0, 4, 4, 2, 2, 3, 3, 4, 4]

  until arr[i] == 99
    chars = "0000#{arr[i]}".chars.last(5)
    # puts "#{chars.join}\t#{arr[i, 4]}"
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
      if val != 0
        puts val
        return
      end
    elsif op == 5
      if get_val(arr, chars[0], i + 1) != 0
        i = get_val(arr, chars[1], i + 2)
        next
      end
    elsif op == 6
      if get_val(arr, chars[0], i + 1) == 0
        i = get_val(arr, chars[1], i + 2)
        next
      end
    elsif op == 7
      if get_val(arr, chars[0], i + 1) < get_val(arr, chars[1], i + 2)
        arr[arr[i + 3]] = 1
      else
        arr[arr[i + 3]] = 0
      end
    elsif op == 8
      if get_val(arr, chars[0], i + 1) == get_val(arr, chars[1], i + 2)
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

def part1
  solve(1)
end

def part2
  solve(5)
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }
puts Benchmark.realtime { puts "Part 2 #{part2}" }
