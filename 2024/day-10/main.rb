#!/usr/bin/env ruby

DIRECTIONS = [[1, 0], [0, 1], [-1, 0], [0, -1]].freeze
EX_USAGE = 64

def compute_grid(map)
  grid = {}
  map.each_with_index do |row, row_index|
    row.each_with_index do |cell, col_index|
      grid[cell] = [] if grid[cell].nil?
      grid[cell] << [row_index, col_index]
    end
  end
  grid
end

def in_bounds?(coords, bounds)
  coords.first.between?(0, bounds.first - 1) && coords.last.between?(0, bounds.last - 1)
end

def compute_trail_score(coords, map, grid, bounds, part2: false, score: 0)
  DIRECTIONS.each do |direction|
    next_coords = coords.zip(direction).map { |x, y| x + y }

    next unless in_bounds?(next_coords, bounds)

    current_value = grid.keys.select { |key| grid[key].include?(coords) }.first
    next_value = grid.keys.select { |key| grid[key].include?(next_coords) }.first

    if !next_value.nil? && next_value == (current_value + 1)
      if current_value + 1 == 9
        score += 1
        grid[next_value].delete(next_coords) unless part2
      else
        score = compute_trail_score(next_coords, map, grid, bounds, part2: part2, score: score)
      end
    end
  end

  score
end

def main(argv)
  if argv.size != 1
    warn 'Usage: ruby 2024/day-10/main.rb <file>'
    exit EX_USAGE
  end
  map = File.readlines(argv.first).map { |line| line.chomp.chars }.map { |row| row.map(&:to_i) }
  grid = compute_grid(map)
  scores = []

  starting_positions = grid[0]

  starting_positions.each do |coords|
    scores.push(compute_trail_score(coords, map, Marshal.load(Marshal.dump(grid)), [map.size, map.first.size]))
  end

  puts "Part 1: #{scores.reduce(0, :+)}"

  scores.clear

  starting_positions.each do |coords|
    scores.push(compute_trail_score(coords, map, Marshal.load(Marshal.dump(grid)), [map.size, map.first.size],
                                    part2: true))
  end

  puts "Part 2: #{scores.reduce(0, :+)}"
end

main ARGV if __FILE__ == $PROGRAM_NAME
