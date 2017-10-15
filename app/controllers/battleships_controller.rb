module Battleship
  module_function

  def start(positions)
    session_id      = SecureRandom::uuid
    all_ships       = positions.map { |(x,y)| [[x,y], [x, y+1], [x,y+2]] }
    battleships[session_id] = { ships: all_ships }
    session_id
  end

  def record_shot(session_id, position)
    return "missing-session" unless battleships[session_id]

    battleships[session_id][:shots] ||= []
    battleships[session_id][:shots] << position

    if battleships[session_id][:shots] & battleships[session_id][:ships]
      "hit"
    else
      "miss"
    end
  end

  def battleships
    @battleships ||= {}
  end
  private :battleships
end

class BattleshipsController < ApplicationController
  def create
    positions = params.fetch(:positions)
    id        = Battleship.start(positions)

    render json: { message: "OK", links: { self: battleship_path(id) } }
  end

  def update
    id      = params.fetch(:id)
    message = Battleship.record_shot(id, params.fetch(:position))

    if message == "missing-session"
      render json: { message: message }, status: 404
    else
      render json: { message: message , links: { self: battleship_path(id) }}
    end
  end
end
