require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt").join("").split(",").map(&.to_i)

def get_val(arr, mode, pos)
  return arr[pos] if mode == 1
  return arr[arr[pos]]
end

def solve(id)
  i, arr, skip = 0, INPUT.dup, [0, 4, 4, 2, 2, 3, 3, 4, 4]
  until arr[i] == 99
    chars = "0000#{arr[i]}".chars.last(5).reverse.map(&.to_i)
    op = chars.shift(2).reject { |n| n == 0 }.join.to_i

    case op
    when 1, 2
      vals = [get_val(arr, chars[0], i + 1), get_val(arr, chars[1], i + 2)]
      arr[arr[i + 3]] = op == 1 ? vals.sum : vals.product
    when 3
      arr[arr[i + 1]] = id
    when 4
      val = get_val(arr, chars[0], i + 1)
      return val if val != 0
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
end

puts Benchmark.realtime { puts "Part 1 #{solve(1)}" }.total_milliseconds
puts Benchmark.realtime { puts "Part 2 #{solve(5)}" }.total_milliseconds
