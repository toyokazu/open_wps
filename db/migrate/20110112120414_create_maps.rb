class CreateMaps < ActiveRecord::Migration
  def self.up
    create_table :maps do |t|
      t.string :name
      t.float :o_lat
      t.float :o_lon
      t.float :o_alt
      t.geometry :geom, :z => true
      t.integer :o_x
      t.integer :o_y
      t.float :dist_pix_ratio
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :maps
  end
end
