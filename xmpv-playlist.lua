-----------------------------------------------------------------------------
-- Playlist class. 
-----------------------------------------------------------------------------
require 'xmpv-tmsu'
require 'xmpv-msg'

-- ***** Variables *****
Playlist = {
  TAG_NAME_ON="xplayedon",
  TAG_NAME_AT="xplayedat",
  file_path="",
  
  tmsu = Tmsu:new(),
  msg = Msg:new(),  
}

-- 'Constructor'
function Playlist:new(o, file_path)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  -- Extra arguments
  self.file_path = file_path
  
  return o
end

function Playlist:log_played()
  local current_position = math.floor(mp.get_property_number("time-pos"))
  local current_date_time = os.date("%Y-%m-%d_%X")
  
  local tags = self.TAG_NAME_ON .."="..current_date_time.." "..self.TAG_NAME_AT.."="..current_position
  print(tags)
end