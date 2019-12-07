require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt").join("").split(",").map(&.to_i)

# INPUT = "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5".split(",").map(&.to_i)

# INPUT = "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10".split(",").map(&.to_i)

def get_val(arr, mode, pos)
  return arr[pos] if mode == 1
  return arr[arr[pos]]
end

def solve(inputs : Array(Int32), i = 0, arr = INPUT.dup)
  skip = [0, 4, 4, 2, 2, 3, 3, 4, 4]
  until arr[i] == 99
    chars = "0000#{arr[i]}".chars.last(5).reverse.map(&.to_i)
    op = chars.shift(2).reject { |n| n == 0 }.join.to_i

    case op
    when 1, 2
      vals = [get_val(arr, chars[0], i + 1), get_val(arr, chars[1], i + 2)]
      arr[arr[i + 3]] = op == 1 ? vals.sum : vals.product
    when 3
      next_input = inputs.shift?
      if !next_input.nil?
        arr[arr[i + 1]] = next_input
      end
    when 4
      val = get_val(arr, chars[0], i + 1)
      if val != 0
        i += skip[op]
        return {val, i, arr}
      end
    when 5
      if get_val(arr, chars[0], i + 1) != 0
        i = get_val(arr, chars[1], i + 2)
        next
      end
    when 6
      if get_val(arr, chars[0], i + 1) == 0
        i = get_val(arr, chars[1], i + 2)
        next
      end
    when 7
      arr[arr[i + 3]] =
        get_val(arr, chars[0], i + 1) < get_val(arr, chars[1], i + 2) ? 1 : 0
    when 8
      arr[arr[i + 3]] =
        get_val(arr, chars[0], i + 1) == get_val(arr, chars[1], i + 2) ? 1 : 0
    end

    i += skip[op]
  end
  {nil, i, arr}
end

def part1
  [0, 1, 2, 3, 4].permutations.max_of { |perm|
    last = 0
    perm.each { |n| last = solve([n, last])[0].not_nil! }
    last
  }
end

def part2
  [5, 6, 7, 8, 9].permutations.map { |perm|
    # Save instruction pointer
    vals, ip = [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]
    # Save memory state
    mem = Array.new(5, [] of Int32)
    done = false

    # To start the process, a 0 signal is sent to amplifier A's input exactly once.
    perm.map_with_index { |n, i|
      next_val, ip[i], mem[i] = solve([n, vals[i]])
      vals[(i + 1) % 5] = next_val.not_nil!
    }

    until done
      perm.map_with_index { |_, i|
        # Repeat with previous state but different input
        next_val, ip[i], mem[i] = solve([vals[i]], ip[i], mem[i])
        if next_val.nil?
          done = true
          break
        end
        vals[(i + 1) % 5] = next_val
      }
    end
    # Return E
    vals.first
  }.max
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }.total_milliseconds
puts Benchmark.realtime { puts "Part 2 #{part2}" }.total_milliseconds
