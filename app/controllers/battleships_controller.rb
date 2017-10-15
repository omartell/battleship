class BattleshipsController < ApplicationController
  def create
    positions = params.fetch(:positions)
    id        = SecureRandom::uuid

    self.class.battleships[id] = { initial: positions }

    render json: { message: "OK", positions: positions, links: { self: battleship_path(id) } }
  end

  def self.battleships
    @battleships ||= {}
  end
end
