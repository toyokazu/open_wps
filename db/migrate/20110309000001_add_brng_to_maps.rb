class AddBrngToMaps < ActiveRecord::Migration
  def self.up
    add_column :maps, :brng, :float
  end

  def self.down
    remove_column :maps, :brng
  end
end
