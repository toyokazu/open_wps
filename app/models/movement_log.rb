class MovementLog < ActiveRecord::Base
  belongs_to :gps_location
  belongs_to :manual_location
  belongs_to :user
end
