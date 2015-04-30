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
  -- Unlog played first
  self:unlog_played()
  
  -- Log played.
  local current_position = math.floor(mp.get_property_number("time-pos"))
  local current_unix_time = os.time()
  
  local tags = self.TAG_NAME_ON .."="..current_unix_time.." "..self.TAG_NAME_AT.."="..current_position
  self.tmsu:tags(tags, self.file_path)
  
end

-- Untag all tag starting with 'xplayed'
function Playlist:unlog_played()

  -- Get raw tags of current file.
  local cmd_results = self.tmsu:get_tags(self.file_path) 

  -- Extract xplayedXXXX tags.
  local xplayed_tags = ""
  local tag_pattern = "xplayed"
  for token in string.gmatch(cmd_results, "%S+") do
    if string.starts(token, tag_pattern) then
      xplayed_tags = xplayed_tags .. " " .. token
    end
  end

  -- Untag all tag starting with 'xplayed'
  if( xplayed_tags~="" ) then
    self.tmsu:untags(xplayed_tags, self.file_path)
  end
  
end
