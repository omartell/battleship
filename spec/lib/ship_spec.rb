require "rails_helper"

RSpec.describe Ship do
  let(:ship) { Ship.new(start: [0, 3]) }

  it 'as coordinates associated with it' do
    expect(ship.coordinates).to eq([[0,3], [0,2], [0,1]])
  end

  describe "#shot" do
    it 'reports back hit if the coordinate was hit' do
      expect(ship.shot([0,3])).to eq(:hit)
    end

    it 'reports back miss if the coordinate was not hit' do
      expect(ship.shot([0,0])).to eq(:miss)
    end

    it 'reports when the ship has been sunk' do
      ship.shot([0,3])
      ship.shot([0,2])

      expect(ship.shot([0,1])).to eq(:sunk)
    end
  end

  describe "#sunk" do
    it 'is true when all coordinates have been hit' do
      ship.shot([0,3])
      ship.shot([0,2])
      ship.shot([0,1])

      expect(ship).to be_sunk
    end
  end
end
