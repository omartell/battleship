class BattleshipSession
  attr_accessor :store

  def initialize(store)
    @store = store
  end

  def start(positions)
    ships  = positions.map { |(x, y)| [[x, y], [x, y - 1], [x, y - 2]] }
    errors = validate_initial_positions(ships)
    return errors if errors.present?

    session_id = SecureRandom.uuid
    store.save_session(session_id, ships: ships)

    { message: 'ok', session_id: session_id }
  end

  def record_shot(session_id, shot)
    session = store.get_session(session_id)
    errors  = validate_shot(session, session_id, shot)
    return errors if errors.present?

    sunk, session = new_session_from(session, shot)
    store.save_session(session_id, session)

    if session[:ships].empty?
      { message: 'game-over', session_id: session_id }
    elsif sunk.any?
      { message: 'sunk', session_id: session_id }
    elsif session[:ships].any? { |ship| ship.include?(shot) }
      { message: 'hit', session_id: session_id }
    else
      { message: 'miss', session_id: session_id }
    end
  end

  private

  def new_session_from(session, shot)
    session = session.merge(shots: session.fetch(:shots, []) + [shot])
    sunk    = session[:ships].select { |ship| sunk?(session, ship) }
    new_session = session.merge(sunk: session.fetch(:sunk, []) + sunk,
                                ships: session.fetch(:ships) - sunk)

    [sunk, new_session]
  end

  def sunk?(session, ship)
    (ship & session[:shots]).size == 3
  end

  def validate_initial_positions(positions)
    if positions.empty? ||!positions.flatten(1).all?(&method(:in_map?))
      { message: 'invalid-initialization' }
    end
  end

  def validate_shot(session, _session_id, _position)
    if !session.present?
      { message: 'missing-session' }
    end
  end

  def in_map?(position)
    x, y = position
    (0..9).cover?(x) && (0..9).cover?(y)
  end
end
