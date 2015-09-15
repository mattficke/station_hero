require 'nokogiri'
require 'open-uri'

doc = Nokogiri::XML(open("https://www.capitalbikeshare.com/data/stations/bikeStations.xml"))

station_data = File.open('stations.json', "w")

doc.css('station').each do |station|
  station_data.puts("{")
  station_data.puts("'cabi_id': " + "'" + station.at_css('id').content.to_s + "'" + ",")
  station_data.puts ("'station_name': " + "'" + station.at_css('name').content.to_s + "'" + ",")
  station_data.puts ("'lat': " + "'" + station.at_css('lat').content.to_s + "'" + ",")
  station_data.puts ("'long': " + "'" + station.at_css('long').content.to_s + "'")
  station_data.puts("},")
end

station_data.close
