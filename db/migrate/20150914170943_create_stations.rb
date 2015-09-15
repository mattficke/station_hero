class CreateStations < ActiveRecord::Migration
  def change
    create_table :stations do |t|
      t.integer :cabi_id
      t.string :station_name
      t.decimal :latitude
      t.decimal :longitude
    end
  end
end
