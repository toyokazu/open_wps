class CreateWifiAccessPoints < ActiveRecord::Migration
  def self.up
    create_table :wifi_access_points do |t|
      t.string :ssid
      t.string :mac

      t.timestamps
    end
  end

  def self.down
    drop_table :wifi_access_points
  end
end
