class WpsLogger::Map < WpsLogger::Base
  set_table_name :maps

  has_attached_file :image, :styles => { :medium => "320x320>", :thumb => "128x128>" }
  has_one :basis_map_relation, :foreign_key => 'relative_map_id', :class_name => 'MapRelation'
  has_many :relative_map_relations, :foreign_key => 'basis_map_id', :class_name => 'MapRelation'
  has_one :basis_map, :through => :basis_map_relation, :class_name => 'Map'
  has_many :relative_maps, :through => :relative_map_relations, :class_name => 'Map'
end
