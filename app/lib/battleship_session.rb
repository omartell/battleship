# frozen_string_literal: true

class BattleshipSession
  attr_accessor :store

  def initialize(store)
    @store = store
  end

  def start(positions)
    map    = build_map(positions.map { |position| Ship.new(start: position) })
    errors = validate_initial_positions(map.keys)

    return errors if errors.present?

    session_id = SecureRandom.uuid
    store.save_session(session_id, map.values)

    { message: 'ok', session_id: session_id }
  end

  def shot(session_id, coordinate)
    session = store.get_session(session_id)
    errors  = validate_session(session)
    return errors if errors.present?

    map  = build_map(session.map { |s| Ship.new(ship: s) })
    shot = map[coordinate]&.shot(coordinate)

    store.save_session(session_id, map.values)

    if shot.nil?
      { message: 'miss', session_id: session_id }
    elsif map.values.all?(&:sunk?)
      { message: 'game-over', session_id: session_id }
    elsif shot == :hit
      { message: 'hit', session_id: session_id }
    elsif shot == :sunk
      { message: 'sunk', session_id: session_id }
    end
  end

  private

  def build_map(ships)
    ships.each_with_object({}) do |s, acc|
      s.coordinates.each do |c|
        acc[c] = s
      end
    end
  end

  def validate_initial_positions(positions)
    if positions.empty? || !positions.all?(&method(:in_map?))
      { message: 'invalid-initialization' }
    end
  end

  def validate_session(session)
    { message: 'missing-session' } unless session.present?
  end

  def in_map?(position)
    x, y = position
    (0..9).cover?(x) && (0..9).cover?(y)
  end
end
