-----------------------------------------------------------------------------
-- Stats class. 
-----------------------------------------------------------------------------
local home = os.getenv("HOME")
package.path = package.path .. ';' .. home .. '/.config/mpv/scripts/?.lua'

require 'xmpv-utils'
require 'mp.options'
require 'xmpv-likes'
require 'xmpv-mark'
require 'xmpv-msg'
require 'xmpv-asst'

-- ***** Variables *****
Stats = {
  msg = Msg:new(),
  asst = Asst:new(),
  likes = nil,
  mark = nil,
}

-- 'Constructor'
function Stats:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  -- Initialize values
  self.likes = Likes:new()
  self.mark = Mark:new()
  
  return o
end

-- Print information about current playing file.
function Stats:print()

  local indent = "   "
  local file   = string.format("%6s: %s\n", "File", self.asst:long_text(mp.get_property_osd("filename")))
  local likes  = string.format("%6s: %s\n", "Likes", self.likes:get_number())
  local marked = string.format("%6s\n%s%s\n", "Marked", indent, self.asst:long_text(self.mark:get_formatted_positions()))
  
  local stats = file .. likes .. marked
  self.msg:print(stats)
  print(stats)
end
