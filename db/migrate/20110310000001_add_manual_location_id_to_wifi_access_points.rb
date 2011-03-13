class AddManualLocationIdToWifiAccessPoints < ActiveRecord::Migration
  def self.up
    add_column :wifi_access_points, :manual_location_id, :integer
  end

  def self.down
    remove_column :wifi_access_points, :manual_location_id
  end
end
