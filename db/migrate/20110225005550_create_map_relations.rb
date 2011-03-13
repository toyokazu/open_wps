class CreateMapRelations < ActiveRecord::Migration
  def self.up
    create_table :map_relations do |t|
      t.references :basis_map
      t.references :relative_map
      t.float :alt_diff
      t.float :brng_diff
      t.integer :ref_x
      t.integer :ref_y

      t.timestamps
    end
  end

  def self.down
    drop_table :map_relations
  end
end
