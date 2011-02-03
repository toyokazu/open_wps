class CreateMovementLogs < ActiveRecord::Migration
  def self.up
    create_table :movement_logs do |t|
      t.references :gps_location
      t.references :manual_location
      t.references :user
      t.string :remote_addr
      t.string :user_agent
      t.string :user_device

      t.timestamps
    end
  end

  def self.down
    drop_table :movement_logs
  end
end
