class MovementLogsController < ApplicationController
  before_filter :authenticate_user!
  # GET /maps/1/movement_logs/
  def index
    if !params["map_id"].nil?
      @map = Map.find(params["map_id"])
    end
    if @map.nil?
      #FIXME
    else
      @movement_logs = MovementLog.where("manual_locations.map_id = ?", params[:map_id]).order("manual_locations.time").all(:include => [:manual_location])
    end
  end
end
