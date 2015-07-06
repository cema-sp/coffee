module CoffeeServer; end

class CoffeeServer::Point
  include Mongoid::Document

  field :address, type: String, default: ''
  field :coordinates, type: Hash
  field :predefined, type: Boolean, default: false
  field :votes, type: Integer, default: 1
  field :comment, type: String, default: ''

  validates_presence_of :coordinates
  validate :coordinates_keys_validation
  validates_numericality_of :votes, equal_to: 1, message: '"votes" should equal 1'
  validates_format_of :predefined, with: /false/, message: '"predefined" should be false'

  # Custom validations

  def coordinates_keys_validation
    if coordinates.present?
      unless coordinates.length == 2 
        errors.add(:coordinates, 'coordinates should contain both lat & lon')
      end
      coordinates.each do |key, _|
        unless [:lat, :lon, 'lat', 'lon'].include?(key)
          errors.add(:coordinates, 'coordinates should contain lat & lon')
        end
      end
    end
  end
end
