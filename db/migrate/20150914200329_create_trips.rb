class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.integer :duration
      t.datetime :start_date
      t.datetime :end_date
    end
  end
end
