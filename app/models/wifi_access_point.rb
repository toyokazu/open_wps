class WifiAccessPoint < ActiveRecord::Base
  has_many :wifi_logs
  belongs_to :manual_location

  class << self
    def find_or_initialize_by_json(json)
      self.find_or_initialize_by_ssid_and_mac(json.reject {|k, v| !self.attribute_method?(k)})
    end
  end
end
