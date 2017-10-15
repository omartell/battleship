require "rails_helper"

RSpec.describe Battleship, type: :request do
  it "allows to initialize the position of the ships" do
    post battleships_path, params: { positions: [[0,3], [4,8], [6,6]]}, as: :json

    expect(response.parsed_body).to include("message" => "OK")
    expect(response.parsed_body).to include("links" => { "self" => a_string_matching(%r{/battleships/(\w|\d|-)+})})
  end
end
