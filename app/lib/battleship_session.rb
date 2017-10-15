class BattleshipSession
  attr_accessor :store

  def initialize(store)
    @store = store
  end

  def start(positions)
    ships  = positions.map { |(x,y)| [[x,y], [x, y - 1], [x,y - 2]] }
    errors = validate_starting_positions(ships)
    return errors if errors.present?

    session_id = SecureRandom::uuid
    store.save_session(session_id, { ships: ships })

    { message: "ok", session_id: session_id }
  end

  def record_shot(session_id, position)
    session = store.get_session(session_id)
    errors  = validate_shot(session, session_id, position)
    return errors if errors.present?

    session[:shots] ||= []
    session[:shots] << position
    sunk        = session[:ships].select { |ship| (ship & session[:shots]).size == 3 }
    new_session = session.merge(sunk: sunk, ships: session[:ships] - sunk)

    store.save_session(session_id, new_session)

    if new_session[:ships].empty?
      { message:"game over", session_id: session_id }
    elsif sunk.any?
      { message:"sunk", session_id: session_id }
    elsif session[:ships].any?{ |ship| ship.include?(position) }
      { message:"hit", session_id: session_id }
    else
      { message:"miss", session_id: session_id }
    end
  end

  private

  def validate_starting_positions(positions)
    return { message: "invalid-initialization" } unless positions.present?
    return { message: "invalid-initialization" } unless positions.flatten(1).all?(&method(:in_map?))
  end

  def validate_shot(session, session_id, position)
    return { message:"missing-session" } unless session.present?
  end

  def in_map?(position)
    x,y = position
    (0..9).include?(x) && (0..9).include?(y)
  end
end
