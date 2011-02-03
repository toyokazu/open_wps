class Map < ActiveRecord::Base
  has_attached_file :image, :styles => { :medium => "320x320>", :thumb => "128x128>" }
end
