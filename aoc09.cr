require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt").join.split(",").map(&.to_i64)

class Computer
  @arr : Array(Int64)
  @skip = [0, 4, 4, 2, 2, 3, 3, 4, 4, 2]

  def initialize(@inputs = [] of Int64, @ip = 0_i64, @arr = INPUT.dup, @base = 0)
    (@arr.size*16).times { |_| @arr << 0_i64 }
    @chars = [] of Int32
  end

  def add_input(inputs : Array(Int64))
    @inputs = @inputs + inputs
  end

  def get_val(offset = 0)
    pos = @ip + 1 + offset
    mode = @chars[offset]
    val = @arr[pos]

    return val if mode == 1
    return @arr[val + @base] if mode == 2
    return @arr[val]
  end

  def index(offset = 0)
    pos = @ip + 1 + offset
    mode = @chars[offset]
    val = @arr[pos]
    return val + @base if mode == 2
    return val
  end

  def run
    until @arr[@ip] == 99
      @chars = "0000#{@arr[@ip]}".chars.last(5).reverse.map(&.to_i)
      op = @chars.shift(2).reject { |n| n == 0 }.join.to_i

      case op
      when 1, 2
        vals = [get_val, get_val(1)]
        @arr[index(2)] = op == 1 ? vals.sum : vals.product
      when 3
        next_input = @inputs.shift?
        if !next_input.nil?
          @arr[index] = next_input
        end
      when 4
        val = get_val
        if val != 0
          @ip += @skip[op]
          return val
        end
      when 5
        if get_val != 0
          @ip = get_val(1)
          next
        end
      when 6
        if get_val == 0
          @ip = get_val(1)
          next
        end
      when 7
        @arr[index(2)] = get_val < get_val(1) ? 1_i64 : 0_i64
      when 8
        @arr[index(2)] = get_val == get_val(1) ? 1_i64 : 0_i64
      when 9
        @base += get_val
      end

      @ip += @skip[op]
    end
    nil
  end
end

puts Benchmark.realtime { puts "Part 1 #{Computer.new([1_i64]).run}" }.total_milliseconds
puts Benchmark.realtime { puts "Part 2 #{Computer.new([2_i64]).run}" }.total_milliseconds
