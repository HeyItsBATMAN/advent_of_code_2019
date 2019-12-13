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
  arcade = Computer.new
  map = Hash(Int64, Hash(Int64, Int64)).new

  while true
    input = [] of Int64 | Nil
    3.times do
      input << arcade.run
    end
    break if input.includes? nil
    x, y, id = input.map(&.not_nil!)
    map[y] = Hash(Int64, Int64).new if !map[y]?
    map[y][x] = id
  end
  map.values.map(&.values).flatten.count(2)
end

def part2
  arcade = Computer.new
  map = Hash(Int64, Hash(Int64, Int64)).new
  arcade.change_addr(0_i64, 2_i64)
  ball_pos = 0_i64
  paddle_pos = 0_i64

  # Create map
  while true
    input = [] of Int64 | Nil
    3.times do
      input << arcade.run
    end
    break if input.includes? nil
    x, y, id = input.map(&.not_nil!)
    break if x == -1 && y == 0 # Mapping done condition

    ball_pos = x if id == 4_i64
    paddle_pos = x if id == 3_i64

    map[y] = Hash(Int64, Int64).new if !map[y]?
    map[y][x] = id
  end

  # Play game
  while true
    input = [] of Int64 | Nil
    3.times do
      input << arcade.run
    end
    break if input.includes? nil
    x, y, id = input.map(&.not_nil!)

    ball_pos = x if id == 4_i64
    paddle_pos = x if id == 3_i64

    arcade.change_input([(ball_pos == paddle_pos) ? 0_i64 : (ball_pos > paddle_pos ? 1_i64 : -1_i64)])

    map[y] = Hash(Int64, Int64).new if !map[y]?
    map[y][x] = id

    # Visualised
    # map.values.each { |line|
    # puts line.values.join.gsub("0", " ").gsub("1", "█").gsub("2", "░").gsub("3", "▂").gsub("4", "●")
    # }
  end

  map[0][-1]
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }.total_milliseconds
puts Benchmark.realtime { puts "Part 2 #{part2}" }.total_milliseconds
