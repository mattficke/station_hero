require 'open-uri'
require 'json'

class Station < ActiveRecord::Base
  has_many :arrivals
  has_many :trips, through: :arrivals

  has_many :departures
  has_many :trips, through: :departures

end
