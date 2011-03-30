class ManualLocation < ActiveRecord::Base
  belongs_to :map
  has_one :movement_log
  has_one :wifi_access_point

  class << self
    def time_condition(options = {})
      # after=2005-08-09T10:57:00-08:00 (RFC 3339 format)
      # manual_location.time is recorded as integer value of the timestamp (micro second)
      if options[:after].nil?
        after_param = Time.new(1970,01,01).to_i * 1000
      else
        after_param = Time.zone.parse(options[:after]).to_i * 1000
      end
      # before=2005-08-09T10:57:00-08:00 (RFC 3339 format)
      if options[:before].nil?
        before_param = Time.new(2031,01,01).to_i * 1000
      else
        before_param = Time.zone.parse(options[:before]).to_i * 1000
      end
      ['manual_locations.time BETWEEN ? AND ?', after_param, before_param]
    end
  end

  def init_by_params(params)
    self.map_id = params["map_id"].to_i
    self.x = params["curr_x"].to_i
    self.y = params["curr_y"].to_i
    self.height = params["height"].to_f
    d = Math::sqrt(params["step_x"].to_f ** 2 + params["step_y"].to_f ** 2)
    self.u_x = params["step_x"].to_f / d
    self.u_y = params["step_y"].to_f / d
    self.time = params["time"]
  end
end
