# frozen_string_literal: true

class Ship
  def initialize(start: nil, ship: nil)
    if start
      x, y = start
      @ship = Hash[
        [[x, y], [x, y - 1], [x, y - 2]].map { |k| [k, nil] }
      ]
    else
      @ship = ship
    end
  end

  def coordinates
    @ship.keys
  end

  def shot(coordinate)
    if @ship.key?(coordinate) && @ship.values.compact == %i[hit hit]
      @ship[coordinate] = :hit
      :sunk
    elsif @ship.key?(coordinate)
      @ship[coordinate] = :hit
    else
      :miss
    end
  end

  def serialize
    @ship
  end

  def sunk?
    @ship.values == [:hit] * 3
  end
end
