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
      t.point :geom, :with_z => true, :srid => Coordinate::SRID
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
    add_index :gps_locations, :geom, :spatial=>true
  end

  def self.down
    drop_table :gps_locations
  end
end
