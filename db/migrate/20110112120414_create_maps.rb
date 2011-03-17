class CreateMaps < ActiveRecord::Migration
  def self.up
    create_table :maps do |t|
      t.string :name
      t.float :o_lat
      t.float :o_lon
      t.float :o_alt
      t.point :geom, :with_z => true, :srid => Coordinate::SRID
      t.integer :o_x
      t.integer :o_y
      t.float :dist_pix_ratio
      t.string :description

      t.timestamps
    end
    add_index :maps, :geom, :spatial=>true
  end

  def self.down
    drop_table :maps
  end
end
