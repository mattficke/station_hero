class Arrival < ActiveRecord::Base
  belongs_to :trip
  belongs_to :station
end
