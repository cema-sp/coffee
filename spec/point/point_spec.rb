require File.expand_path '../../spec_helper.rb', __FILE__

RSpec.describe CoffeeServer::Point do
  describe 'coordinates' do
    it { should validate_presence_of :coordinates }

    describe 'keys' do
      context 'valid keys' do
        let(:point) { CoffeeServer::Point.new(coordinates: {lat: 1, lon: 2}) }
        subject { point }
        it { should be_valid }
      end

      context 'invalid keys' do
        let(:point) { CoffeeServer::Point.new(coordinates: {la: 1, lo: 2}) }
        subject { point }
        it { should_not be_valid }
      end

      context 'invalid keys count' do
        let(:point) { CoffeeServer::Point.new(coordinates: {lon: 2}) }
        subject { point }
        it { should_not be_valid }
      end
    end
  end

  describe 'predefined' do
    it { should allow_value(false).for(:predefined) }
    it { should_not allow_value(true).for(:predefined) }
  end

  describe 'votes' do
    it do
      should validate_numericality_of(:votes)
        .is_equal_to(1)
        .with_message('"votes" should equal 1')
    end
  end
end
