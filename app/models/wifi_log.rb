class WifiLog < ActiveRecord::Base
  belongs_to :wifi_access_point
  belongs_to :movement_log

  class << self
    def new_by_json(json)
      self.new(json.reject {|k, v| !self.attribute_method?(k)})
    end
  end
end
