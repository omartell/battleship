class BattleshipsController < ApplicationController
  def create
    positions = params.fetch(:positions)
    result    = BattleshipSession.new(Store).start(positions)

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

    if %w(hit miss sunk game-over).include?(message)
      render json: { message: message, links: { self: battleship_path(id) }}
    else
      render json: { message: message }, status: 400
    end
  end
end
