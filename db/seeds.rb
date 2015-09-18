# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
require 'json'
require 'csv'
require 'date'



data = File.read('stations.json')

station_data = JSON.parse(data)

station_data.each do |station|
  Station.create({
    cabi_id: station["cabi_id"],
    station_name: station["station_name"],
    latitude: station["lat"],
    longitude: station["long"]
    })
end

csv_text = File.read('2015-Q2-Trips-History-Data.csv')
csv = CSV.parse(csv_text, :headers => true)
csv.each do |row|
  begin
    start_station = Station.find_by(station_name: row[2])
    end_station = Station.find_by(station_name: row[4])
    start_date = Chronic.parse(row[1])
    end_date = Chronic.parse(row[3])

    trip = Trip.create({
      duration: row[0],
      start_date: start_date,
      end_date: end_date
      })

    trip.departures.create({
      station_id: start_station.id
      })

    trip.arrivals.create({
      station_id: end_station.id
      })

  rescue
    next
  end
end
