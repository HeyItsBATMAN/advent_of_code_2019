require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt").join.split(",").map(&.to_i64)

enum Direction
  Up
  Right
  Down
  Left
end

class Computer
  @arr : Hash(Int64, Int64)
  @skip = [0, 4, 4, 2, 2, 3, 3, 4, 4, 2]

  def initialize(@inputs = [] of Int64, @ip = 0_i64, @base = 0)
    @arr = INPUT.map_with_index { |n, i| {i.to_i64, n} }.to_h
    @chars = [] of Int32
  end

  def add_input(inputs : Array(Int64))
    @inputs = @inputs + inputs
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

def rotate(dir, rotate)
  {
    Direction::Up    => {0 => Direction::Left, 1 => Direction::Right},
    Direction::Right => {0 => Direction::Up, 1 => Direction::Down},
    Direction::Down  => {0 => Direction::Right, 1 => Direction::Left},
    Direction::Left  => {0 => Direction::Down, 1 => Direction::Up},
  }[dir][rotate]
end

def part1
  dir = Direction::Up
  inputs = Hash(String, Int64).new
  colors = Hash(String, Int64).new
  point = [0, 0]
  point_str = point.join(",")

  painter = Computer.new([0_i64])
  while true
    paint = painter.run
    break if paint.nil?
    colors[point_str] = paint
    move = painter.run
    break if move.nil?

    dir = rotate(dir, move)
    case dir
    when Direction::Up    then point[1] += 1
    when Direction::Right then point[0] += 1
    when Direction::Down  then point[1] -= 1
    when Direction::Left  then point[0] -= 1
    end

    point_str = point.join(",")

    inputs[point_str] = 0 if !inputs[point_str]?
    inputs[point_str] += 1

    curr_color = colors[point_str]? ? colors[point_str] : 0_i64
    painter.add_input([curr_color])
  end
  inputs.keys.uniq.size
end

def part2
  dir = Direction::Up
  inputs = Hash(String, Int64).new
  colors = Hash(String, Int64).new
  point = [0, 0]
  point_str = point.join(",")

  painter = Computer.new([1_i64])
  while true
    paint = painter.run
    break if paint.nil?
    colors[point_str] = paint
    move = painter.run
    break if move.nil?

    dir = rotate(dir, move)
    case dir
    when Direction::Up    then point[1] -= 1
    when Direction::Right then point[0] += 1
    when Direction::Down  then point[1] += 1
    when Direction::Left  then point[0] -= 1
    end

    point_str = point.join(",")

    inputs[point_str] = 0 if !inputs[point_str]?
    inputs[point_str] += 1

    curr_color = colors[point_str]? ? colors[point_str] : 0_i64
    painter.add_input([curr_color])
  end
  minmax_x = colors.keys.map(&.split(",")[0].to_i).minmax
  minmax_y = colors.keys.map(&.split(",")[1].to_i).minmax
  (minmax_y[0]..minmax_y[1]).to_a.map { |y|
    (minmax_x[0]..minmax_x[1]).to_a.map { |x|
      colors["#{x},#{y}"]? ? colors["#{x},#{y}"].to_s : "0"
    }.map { |n| n == "0" ? " " : "█" }.join
  }
end

puts Benchmark.realtime { puts "Part 1 #{part1}" }
puts Benchmark.realtime {
  puts "Part 2"
  part2.each { |line| puts line }
}
