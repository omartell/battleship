module Battleship
  module_function

  def start(positions)
    id              = SecureRandom::uuid
    battleships[id] = { initial: positions }
    id
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
end
