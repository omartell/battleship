module Battleship
  class Validator
    def self.validate_starting_positions(positions)
      return { message: "invalid-initialization" } unless positions.present?
      return { message: "invalid-initialization" } if positions.any? { |(x,y)|
        (0..9).exclude?(x) || (0..9).exclude?(y)
      }
    end

    def self.validate_shot(battleships, session_id, position)
      return { message:"missing-session" } unless battleships[session_id]
    end
  end

  module_function

  def start(positions)
    ships  = positions.flat_map { |(x,y)| [[x,y], [x, y - 1], [x,y - 2]] }
    errors = Validator.validate_starting_positions(ships)
    return errors if errors.present?

    session_id = SecureRandom::uuid
    battleships[session_id] = { ships: ships }

    { message: "ok", session_id: session_id }
  end

  def record_shot(session_id, position)
    errors = Validator.validate_shot(battleships, session_id, position)
    return errors if errors.present?

    battleships[session_id][:shots] ||= []
    battleships[session_id][:shots] << position
    intersection = battleships[session_id][:shots] & battleships[session_id][:ships]

    if intersection.present?
      { message:"hit", session_id: session_id }
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
    result   = Battleship.start(positions)

    if result[:message] == "ok"
      render json: { message: result[:message], links: { self: battleship_path(result[:session_id]) } }
    else
      render json: { message: result[:message] }, status: 400
    end
  end

  def update
    id      = params.fetch(:id)
    result  = Battleship.record_shot(id, params.fetch(:position))
    message = result[:message]

    if %w(hit).include?(message)
      render json: { message: message , links: { self: battleship_path(id) }}
    else
      render json: { message: message }, status: 400
    end
  end
end
