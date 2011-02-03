class GpsLocation < ActiveRecord::Base
  class << self
    def new_by_json(json)
      self.new(json.reject {|k, v| !self.attribute_method?(k)})
    end
  end
end
