class MovementLog < ActiveRecord::Base
  belongs_to :gps_location
  belongs_to :manual_location
  belongs_to :user
  has_many :wifi_logs
  has_many :wifi_access_points, :through => :wifi_logs
end
