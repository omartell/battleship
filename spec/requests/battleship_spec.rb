require "rails_helper"

RSpec.describe Battleship, type: :request do

  def shot(position, battleship)
    put battleship.dig("links", "self"), params: { position: position }, as: :json
  end

  context "initialization" do
    it "allows to initialize the position of the ships" do
      post battleships_path, params: { positions: [[0,3], [4,8], [6,6]]}, as: :json

      expect(response.parsed_body).to include("message" => "ok")
      expect(response.parsed_body).to include("links" => { "self" => a_string_matching(%r{/battleships/(\w|\d|-)+})})
    end

    it "returns bad-request when not specifying a single position" do
      post battleships_path, params: { positions: []}, as: :json

      expect(response.status).to eq(400)
      expect(response.parsed_body).to include("message" => "invalid-initialization")
    end

    it "returns bad-request when one of the positions is outside of 10x10" do
      post battleships_path, params: { positions: [[10,10]]}, as: :json

      expect(response.status).to eq(400)
      expect(response.parsed_body).to include("message" => "invalid-initialization")
    end
  end

  context "recording shots" do
    it "reports sucessful shots for current battleships" do
      post battleships_path, params: { positions: [[0,3], [4,8], [6,6]]}, as: :json

      battleship = response.parsed_body

      shot([0,3], battleship)

      expect(response.parsed_body).to include("message" => "hit")

      shot([0,2], battleship)

      expect(response.parsed_body).to include("message" => "hit")
    end

    it "reports missing sessions when recording a shot for a non-existent battleship" do
      put battleship_path(SecureRandom::uuid), params: { position: [0,3] }, as: :json

      expect(response.status).to eq(400)
      expect(response.parsed_body).to include("message" => "missing-session")
    end

    it "reports non successful shots as misses" do
      post battleships_path, params: { positions: [[0,3], [4,8], [6,6]]}, as: :json

      battleship = response.parsed_body

      shot([0,3], battleship)

      expect(response.parsed_body).to include("message" => "hit")

      shot([0,4], battleship)

      expect(response.parsed_body).to include("message" => "miss")
    end

    it "reports ships as sunk once they'ven hit in all positions" do
      post battleships_path, params: { positions: [[0,3], [4,8], [6,6]]}, as: :json

      battleship = response.parsed_body

      [[0,3], [0,2], [0,1]].each do |position|
        shot(position, battleship)
      end

      expect(response.parsed_body).to include("message" => "sunk")

      shot([4,8], battleship)

      expect(response.parsed_body).to include("message" => "hit")

      shot([4,7], battleship)

      shot([4,6], battleship)

      expect(response.parsed_body).to include("message" => "sunk")
    end

    it "reports game over once they'ven hit in all positions" do
      post battleships_path, params: { positions: [[0,3], [4,8], [6,6]]}, as: :json

      battleship = response.parsed_body

      [[0,3], [0,2], [0,1], [4,8], [4,7], [4,6],[6,6], [6,5], [6,4]].each do |position|
        shot(position, battleship)
      end

      expect(response.status).to eq(200)
      expect(response.parsed_body).to include("message" => "game-over")
    end
  end
end
