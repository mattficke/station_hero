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

    
end
