class WpsLogger::MapRelation < WpsLogger::Base
  set_table_name :map_relations

  belongs_to :relative_map, :polymorphic => false
  belongs_to :basis_map, :polymorphic => false
end
