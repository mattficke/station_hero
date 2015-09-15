class Departure < ActiveRecord::Base
  belongs_to :trip
  belongs_to :station
end
