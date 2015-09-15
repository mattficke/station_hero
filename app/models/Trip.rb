class Trip < ActiveRecord::Base
  has_many :arrivals
  has_many :stations, through: :arrivals

  has_many :departures
  has_many :stations, through: :departures
end
