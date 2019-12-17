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

def generate_map
  comp = Computer.new

  temp = ""
  while true
    tile = comp.run
    break if tile.nil?
    temp += tile.chr
  end
  temp.split("\n").map(&.chars).reject(&.empty?)
end

MAP = generate_map

def part1
  map = MAP.dup
  is_intersection = ->(x : Int32, y : Int32) {
    return false if map[y - 1]?.nil?
    return false if map[y + 1]?.nil?
    return false if map[y][x - 1]?.nil?
    return false if map[y][x + 1]?.nil?
    map[y - 1][x] == '#' && map[y + 1][x] == '#' && map[y][x - 1] == '#' && map[y][x + 1] == '#'
  }
  sum = 0
  map.map_with_index { |line, y|
    line.map_with_index { |c, x|
      next if c == '.'
      next if !is_intersection.call(x, y)
      sum += x * y
    }
  }
  sum
end

def part2
  comp = Computer.new
  comp.change_addr(0_i64, 2_i64)

  mov_a = "L,12,L,12,R,12\n".chars.map(&.ord.to_i64)
  mov_b = "L,8,L,8,R,12,L,8,L,8\n".chars.map(&.ord.to_i64)
  mov_c = "L,10,R,8,R,12\n".chars.map(&.ord.to_i64)
  movs = "A,A,B,C,C,A,B,C,A,B\n".chars.map(&.ord.to_i64)

  comp.add_input(movs)
  comp.add_input(mov_a)
  comp.add_input(mov_b)
  comp.add_input(mov_c)

  video_feed = false
  comp.add_input([video_feed ? 121_i64 : 110_i64, 10_i64])

  temp = ""
  while true
    tile = comp.run
    break if tile.nil?
    return tile if tile > 127
    temp += tile.chr
    if tile.chr == '\n'
      # Enable for print
      # puts temp.chars.join(" ").gsub(".", " ")
      # sleep 0.5 if temp == "\n" && video_feed
      temp = ""
    end
  end
  0
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }
puts Benchmark.realtime { puts "Part 2 #{part2}" }
