require "rails_helper"

RSpec.describe Battleship, type: :request do
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

  it "reports sucessful shots for current battleships" do
    post battleships_path, params: { positions: [[0,3], [4,8], [6,6]]}, as: :json

    battleship = response.parsed_body

    put battleship.dig("links", "self"), params: { position: [0,3] }, as: :json

    expect(response.parsed_body).to include("message" => "hit")
  end

  it "reports missing sessions when recording a shot for a non-existent battleship" do
    put battleship_path(SecureRandom::uuid), params: { position: [0,3] }, as: :json

    expect(response.status).to eq(400)
    expect(response.parsed_body).to include("message" => "missing-session")
  end
end
