class MapRelation < ActiveRecord::Base
  belongs_to :relative_map, :polymorphic => false
  belongs_to :basis_map, :polymorphic => false
end
