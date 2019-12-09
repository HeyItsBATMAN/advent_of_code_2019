require "benchmark"

DAY   = PROGRAM_NAME.match(/aoc\d{2}/).not_nil![0]
INPUT = File.read_lines("#{DAY}.txt").join("").split(",").map(&.to_i)

class Computer
  @arr : Array(Int32)
  @skip = [0, 4, 4, 2, 2, 3, 3, 4, 4]

  def initialize(@inputs = [] of Int32, @ip = 0, @arr = INPUT.dup)
    @chars = [] of Int32
  end

  def add_input(inputs : Array(Int32))
    @inputs = @inputs + inputs
  end

  def get_val(offset = 0)
    pos = @ip + 1 + offset
    mode = @chars[offset]
    val = @arr[pos]

    return val if mode == 1
    return @arr[val]
  end

  def index(offset = 0)
    pos = @ip + 1 + offset
    val = @arr[pos]
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
        @arr[index(2)] = get_val < get_val(1) ? 1 : 0
      when 8
        @arr[index(2)] = get_val == get_val(1) ? 1 : 0
      end

      @ip += @skip[op]
    end
    nil
  end
end

def part1
  [0, 1, 2, 3, 4].permutations.max_of { |perm|
    last = 0
    perm.each { |n|
      solver = Computer.new([n, last])
      last = solver.run.not_nil!
    }
    last
  }
end

def part2
  [5, 6, 7, 8, 9].permutations.map { |perm|
    vals = [0, 0, 0, 0, 0]
    # Save memory state
    solvers = [] of Computer
    done = false

    # To start the process, a 0 signal is sent to amplifier A's input exactly once.
    perm.map_with_index { |n, i|
      solver = Computer.new([n, vals[i]])
      solvers << solver
      next_val = solver.run
      vals[(i + 1) % 5] = next_val.not_nil!
    }

    until done
      perm.map_with_index { |_, i|
        # Repeat with previous state but different input
        solvers[i].add_input([vals[i]])
        next_val = solvers[i].run
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
