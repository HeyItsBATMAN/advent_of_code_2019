require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt").join.split(",").map(&.to_i64)

class Computer
  @arr : Hash(Int64, Int64)
  @skip = [0, 4, 4, 2, 2, 3, 3, 4, 4, 2]

  def initialize(@inputs = [] of Int64, @ip = 0_i64, @base = 0)
    @arr = INPUT.map_with_index { |n, i| {i.to_i64, n} }.to_h
    @chars = [] of Int32
  end

  def_clone

  def change_addr(index, value)
    @arr[index] = value
  end

  def add_input(inputs : Array(Int64))
    @inputs = @inputs + inputs
  end

  def change_input(inputs : Array(Int64))
    @inputs = inputs
  end

  def get_val(offset = 0)
    pos = @ip + 1 + offset
    mode = @chars[offset]
    val = @arr[pos]

    @arr[val] = 0 if !@arr[val]?
    @arr[val + @base] = 0 if !@arr[val + @base]?

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
        @ip += @skip[op]
        return val
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

def part1
  (0..49).to_a.map { |y| (0..49).to_a.map { |x|
    Computer.new([y.to_i64, x.to_i64]).run
  } }.flatten.count(1)
end

def part2
  size = 100
  ship = "#" * size
  map = [] of String

  y = 0
  while true
    x = 0
    line = [] of Char

    # TODO: Improve map generation
    while !line.includes?('#') || line.last? != '.'
      res = Computer.new([x.to_i64, y.to_i64]).run
      line << (res == 0 ? '.' : '#')
      x += 1
    end

    map << line.join

    y += 1

    next if map.size < size
    i = map.size - size
    idx = map[i].rindex(ship)
    next if idx.nil?
    next if map[i + size - 1][idx]? != '#'
    return idx * 10000 + i
  end
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }
puts Benchmark.realtime { puts "Part 2 #{part2}" }
