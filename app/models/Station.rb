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

    def delta(id, bikes, docks)
      current = Time.now
      current_time = current.strftime('%R') #Hour:Minute

      ## for possible future weekday/weekend operations
      # if (1..5).include?(current.wday)
      #   weekday = true
      # elsif (6..7).include?(current.wday)
      #   weekday = false
      # end

      today = current.wday #get day of week (Sunday..Saturday =  0..6)

      # DB query. Limit search to trips from the current day of the week.
      depts = Trip.joins(:departures).where("departures.station_id" => id).where("EXTRACT (DOW FROM start_date) = ?", today)
      arrivs = Trip.joins(:arrivals).where("arrivals.station_id" => id).where("EXTRACT (DOW FROM end_date) = ?", today)

      departure_trips = Hash.new
      arrival_trips = Hash.new

      # create/append to array of departures for each date in departure_trips
      depts.each do |departure|
        if departure.start_date.strftime("%R") > current_time && departure.start_date.strftime("%R") < current.advance(:minutes=>15).strftime("%R")
          date = departure.start_date.strftime("%D")
          if departure_trips[date]
            departure_trips[date].push(departure)
          else
            departure_trips[date] = [departure]
          end
        end
      end

      #create/append to array of arrivals for each date in arrival_trips
      arrivs.each do |arrival|
        if arrival.end_date.strftime("%R") > current_time && arrival.end_date.strftime("%R") < current.advance(:minutes=>15).strftime("%R")
          date = arrival.end_date.strftime("%D")
          if arrival_trips[date]
            arrival_trips[date].push(arrival)
          else
            arrival_trips[date] = [arrival]
          end
        end
      end

      deltas = [] #array of delta values for each day in sample set

      arrival_trips.each do |date, trips|
        if departure_trips[date]
          delta = trips.length - departure_trips[date].length
          deltas.push(delta)
        else
          deltas.push(trips.length)
        end
      end

      departure_trips.each do |date, trips|
        if !arrival_trips[date]
          deltas.push(0 - trips.length)
        end
      end

      bike_counter = 0.0 #decimal to force precision when calculating odds
      dock_counter = 0.0
      deltas.each do |delta|
        if bikes + delta <= 0
          bike_counter = bike_counter + 1
        end
        if docks - delta <= 0
          dock_counter = dock_counter + 1
        end
      end

      bike_odds = (bike_counter / deltas.length) * 100
      dock_odds = (dock_counter / deltas.length) * 100

      return {
        :bike_odds => bike_odds.round,
        :dock_odds => dock_odds.round
      }
    end
end
