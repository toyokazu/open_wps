class WifiLog < ActiveRecord::Base
  belongs_to :wifi_access_point
  belongs_to :movement_log

  class << self
    def new_by_json(json)
      self.new(json.reject {|k, v| !self.attribute_method?(k)})
    end

    def signal_condition(options = {})
      # parameter format
      # signal=-79
      if params[:signal].nil?
        condition = {}
      else
        condition = ['wifi_logs.signal = ?', params[:signal].to_i]
      end
      condition
    end
  end
end
