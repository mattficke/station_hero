require 'open-uri'
require 'json'

class Station < ActiveRecord::Base
  has_many :arrivals
  has_many :trips, through: :arrivals

  has_many :departures
  has_many :trips, through: :departures
  # convert the annoying CaBi XML feed to JSON
    def self.status
      doc = Nokogiri::XML(open("https://www.capitalbikeshare.com/data/stations/bikeStations.xml"))
      list = []
      doc.css('station').each do |station|
        station_info = {
          :id => station.at_css('id').content,
          :name => station.at_css('name').content,
          :terminalName => station.at_css('terminalName').content,
          :lastCommWithServer => station.at_css('lastCommWithServer').content,
          :lat => station.at_css('lat').content,
          :long => station.at_css('long').content,
          :installed => station.at_css('installed').content,
          :locked => station.at_css('locked').content,
          :temporary => station.at_css('temporary').content,
          :public => station.at_css('public').content,
          :nbBikes => station.at_css('nbBikes').content,
          :nbEmptyDocks => station.at_css('nbEmptyDocks').content,
          :latestUpdateTime => station.at_css('latestUpdateTime').content
        }
        list.push(station_info)
      end
      return list
    end

    def self.fetch(id)
      data = self.status()
      data.each_with_index do |station, index|
        station_int = station[:id].to_i
        if station_int == id
          return data[index]
        end
      end

    end

    def delta(bikes, docks)
      current = Time.now
      if (1..5).include?(current.wday)
        weekday = true
      elsif (6..7).include?(current.wday)
        weekday = false
      end
      today = current.yday
      start = current.prev_quarter.beginning_of_quarter.yday

      deltas = []
      while start <= current.prev_quarter.end_of_quarter.yday
        xday = today - start
        time = xday.days.ago
        time_plus = xday.days.ago.advance(:minutes=>15)
        departure_trips = Trip.where("start_date > ?", time).where("start_date < ?", time_plus)
        arrival_trips = Trip.where("end_date > ?", time).where("end_date < ?", time_plus)
        departure_trip_ids = departure_trips.map{|t| t[:id]}
        arrival_trip_ids = arrival_trips.map{|t| t[:id]}
        arrival_array = arrivals.where(trip_id: arrival_trip_ids)
        departure_array = departures.where(trip_id: departure_trip_ids)

        deltas.push(arrival_array.length - departure_array.length)
        start = start + 5
      end
      bike_counter = 0.0
      dock_counter = 0.0
      deltas.each do |delta|
        if bikes + delta <= 0
          bike_counter = bike_counter + 1
        elsif docks - delta <= 0
          dock_counter = dock_counter + 1
        end
      end
      bike_odds = (bike_counter / deltas.length) * 100
      dock_odds = (dock_counter / deltas.length) * 100
      binding.pry
      return {
        :bike_odds => bike_odds,
        :dock_odds => dock_odds
      }
    end
end
