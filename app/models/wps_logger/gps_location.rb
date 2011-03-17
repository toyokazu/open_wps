class WpsLogger::GpsLocation < WpsLogger::Base
  set_table_name :gps_locations

  has_one :movement_log
  class << self
    def new_by_json(json)
      self.new(json.reject {|k, v| !self.attribute_method?(k)})
    end
  end
end
