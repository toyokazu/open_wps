class ManualLocation < ActiveRecord::Base
  belongs_to :map
  has_one :movement_log

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
