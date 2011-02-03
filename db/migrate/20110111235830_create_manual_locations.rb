class CreateManualLocations < ActiveRecord::Migration
  def self.up
    create_table :manual_locations do |t|
      t.references :map
      t.integer :x
      t.integer :y
      t.float :height
      t.float :u_x
      t.float :u_y
      t.integer :time

      t.timestamps
    end
  end

  def self.down
    drop_table :manual_locations
  end
end
