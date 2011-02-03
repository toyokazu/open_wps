class CreateWifiLogs < ActiveRecord::Migration
  def self.up
    create_table :wifi_logs do |t|
      t.references :wifi_access_point
      t.references :movement_log
      t.integer :signal

      t.timestamps
    end
  end

  def self.down
    drop_table :wifi_logs
  end
end
