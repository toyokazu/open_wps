class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :wifi_access_points, :manual_location_id
    add_index :wifi_logs, :wifi_access_point_id
    add_index :wifi_logs, :movement_log_id
    add_index :movement_logs, :gps_location_id
    add_index :movement_logs, :manual_location_id
    add_index :movement_logs, :user_id
    add_index :manual_locations, :map_id
    add_index :map_relations, :basis_map_id
    add_index :map_relations, :relative_map_id
  end

  def self.down
    remove_index :map_relations, :relative_map_id
    remove_index :map_relations, :basis_map_id
    remove_index :manual_locations, :map_id
    remove_index :movement_logs, :user_id
    remove_index :movement_logs, :manual_location_id
    remove_index :movement_logs, :gps_location_id
    remove_index :wifi_logs, :movement_log_id
    remove_index :wifi_logs, :wifi_access_point_id
    remove_index :wifi_access_points, :manual_location_id
  end
end

