module Store
  module_function

  def save_session(session_id, positions)
    battleships[session_id] = positions
  end

  def get_session(session_id)
    battleships[session_id]
  end

  def battleships
    @battleships ||= {}
  end
  private :battleships
end

class BattleshipSession
  attr_accessor :store

  def initialize(store)
    @store = store
  end

  def start(positions)
    ships  = positions.flat_map { |(x,y)| [[x,y], [x, y - 1], [x,y - 2]] }
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

    store.save_session(session_id, session)

    intersection = session[:shots] & session[:ships]

    if intersection.present?
      { message:"hit", session_id: session_id }
    end
  end

  private

  def validate_starting_positions(positions)
    return { message: "invalid-initialization" } unless positions.present?
    return { message: "invalid-initialization" } unless  positions.all?(&method(:in_map?))
  end

  def validate_shot(session, session_id, position)
    return { message:"missing-session" } unless session.present?
  end

  def in_map?(position)
    x,y = position
    (0..9).include?(x) && (0..9).include?(y)
  end
end

class BattleshipsController < ApplicationController
  def create
    positions = params.fetch(:positions)
    result   = BattleshipSession.new(Store).start(positions)

    if result[:message] == "ok"
      render json: { message: result[:message], links: { self: battleship_path(result[:session_id]) } }
    else
      render json: { message: result[:message] }, status: 400
    end
  end

  def update
    id      = params.fetch(:id)
    result  = BattleshipSession.new(Store).record_shot(id, params.fetch(:position))
    message = result[:message]

    if %w(hit).include?(message)
      render json: { message: message , links: { self: battleship_path(id) }}
    else
      render json: { message: message }, status: 400
    end
  end
end
