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

def is_wall?(map, x, y)
  map[y]? != nil && map[y][x]? != nil && map[y][x]
end

def print_map(map, x, y)
  minmax_y = map.keys.minmax
  minmax_x = map.values.flatten.map(&.keys).flatten.minmax
  (minmax_y[0]..minmax_y[1]).to_a.map { |yy|
    puts (minmax_x[0]..minmax_x[1]).to_a.map { |xx|
      (yy == 0 && xx == 0) ? "S" : (yy == y && xx == x) ? "E" : (map[yy]? && map[yy][xx]?) ? "█" : " "
    }.join
  }
end

def generate_map
  map = {0_i64 => {0_i64 => false}}
  set_map = ->(x : Int64, y : Int64, wall : Bool) {
    map[y] = Hash(Int64, Bool).new if map[y]?.nil?
    map[y][x] = wall
  }

  x, y, goal_x, goal_y = 0_i64, 0_i64, 0_i64, 0_i64
  x_dir, y_dir = [0, 0, -1, 1], [-1, 1, 0, 0]
  queue = Deque(Tuple(Int64, Int64, Computer)).new
  queue << {x, y, Computer.new}
  visited = Set(Tuple(Int64, Int64)).new
  visited << {x, y}
  while queue.size > 0
    x, y, droid = queue.pop
    4.times do |i|
      xx, yy = x + x_dir[i], y + y_dir[i]
      next if visited.includes?({xx, yy})
      visited << {xx, yy}
      next if is_wall?(map, xx, yy)

      dd = droid.clone
      dd.add_input([i.to_i64 + 1])
      status = dd.run

      set_map.call(xx, yy, status == 0)

      if status != 0
        set_map.call(xx, yy, false)
        queue << {xx, yy, dd}
        if status == 2
          goal_x = xx
          goal_y = yy
        end
      end
    end
  end
  return {map: map, x: goal_x, y: goal_y}
end

start = Time.monotonic
MAP = generate_map
puts "Generate Map"
puts (Time.monotonic - start).total_milliseconds

def part1
  x, y = 0_i64, 0_i64
  x_dir, y_dir = [0, 0, -1, 1], [-1, 1, 0, 0]

  y_bounds = MAP[:map].keys.minmax
  x_bounds = MAP[:map].values.flatten.map(&.keys).flatten.minmax

  steps = 0
  nodes_left = 1
  nodes_next = 0

  queue = Deque(Tuple(Int64, Int64, Int32)).new
  queue << {x, y, 0}
  visited = Set(Tuple(Int64, Int64)).new
  visited << {x, y}

  while queue.size > 0
    x, y, steps = queue.pop
    if x == MAP[:x] && y == MAP[:y]
      return steps
    end

    4.times do |i|
      xx, yy = x + x_dir[i], y + y_dir[i]

      next if is_wall?(MAP[:map], xx, yy)
      next if visited.includes?({xx, yy})
      next if xx < x_bounds[0] || xx > x_bounds[1]
      next if yy < y_bounds[0] || yy > y_bounds[1]

      queue << {xx, yy, steps + 1}
      visited << {xx, yy}
      nodes_next += 1
    end

    nodes_left -= 1

    if nodes_left == 0
      nodes_left = nodes_next
      nodes_next = 0
    end
  end
end

def part2
  x, y = MAP[:x], MAP[:y]
  x_dir, y_dir = [0, 0, -1, 1], [-1, 1, 0, 0]

  y_bounds = MAP[:map].keys.minmax
  x_bounds = MAP[:map].values.flatten.map(&.keys).flatten.minmax

  steps = 0
  nodes_left = 1
  nodes_next = 0

  queue = Deque(Tuple(Int64, Int64)).new
  queue << {x, y}
  visited = Set(Tuple(Int64, Int64)).new
  visited << {x, y}

  while queue.size > 0
    x, y = queue.shift

    4.times do |i|
      xx, yy = x + x_dir[i], y + y_dir[i]

      next if is_wall?(MAP[:map], xx, yy)
      next if visited.includes?({xx, yy})
      next if xx < x_bounds[0] || xx > x_bounds[1]
      next if yy < y_bounds[0] || yy > y_bounds[1]

      queue << {xx, yy}
      visited << {xx, yy}
      nodes_next += 1
    end

    nodes_left -= 1

    if nodes_left == 0
      nodes_left = nodes_next
      nodes_next = 0
      steps += 1 if queue.size > 0
    end
  end
  steps
end

print_map(MAP[:map], MAP[:x], MAP[:y])

puts Benchmark.realtime { puts "Part 1 #{part1}" }.total_milliseconds
puts Benchmark.realtime { puts "Part 2 #{part2}" }.total_milliseconds
