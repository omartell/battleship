require "rails_helper"

RSpec.describe Battleship, type: :request do
  it 'allows to initialize the the position of the ships' do
    post battleships_path, params: { positions: [[0,0]] }, as: :json

    expect(response.parsed_body).to eq("message" => "OK")
  end
end
