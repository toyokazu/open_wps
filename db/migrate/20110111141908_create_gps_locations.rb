class CreateGpsLocations < ActiveRecord::Migration
  def self.up
    create_table :gps_locations do |t|
      t.string :gpsd_class
      t.string :tag
      t.string :device
      t.float :time
      t.float :lat
      t.float :lon
      t.float :alt
      t.float :epx
      t.float :epy
      t.float :epv
      t.float :ept
      t.float :track
      t.float :speed
      t.float :climb
      t.integer :mode

      t.timestamps
    end
  end

  def self.down
    drop_table :gps_locations
  end
end
