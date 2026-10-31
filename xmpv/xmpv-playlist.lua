-----------------------------------------------------------------------------
-- Playlist class. Played log is stored in `played_on` and `played_at`
-- of `<video filename>.xmpv.json`.
-----------------------------------------------------------------------------
local home = os.getenv("HOME")
package.path = package.path .. ';' .. home .. '/.config/mpv/scripts/?.lua'
--package.path = package.path .. ';' .. 'C:\\xuan\\soft-bin\\mpv-x86_64-20200419-git-a09c769\\portable_config\\scripts\\?.lua'

require 'xmpv-json'
require 'xmpv-msg'

-- ***** Variables *****
Playlist = {
  KEY_ON="played_on", -- Unix time when played.
  KEY_AT="played_at", -- Position(seconds) when played.

  json = Json:new(),
  msg = Msg:new(),  
}

-- 'Constructor'
function Playlist:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

-- Log unix time and position played. It replaces the previous log.
function Playlist:log_played()
  local file_path = mp.get_property("path")
  local time_pos = mp.get_property_number("time-pos")

  local ok, err = self.json:set_value(self.KEY_ON, os.time(), file_path)
  if ok == nil then
    self.msg:error("Cannot log played: " .. tostring(err))
    return
  end

  if time_pos ~= nil then
    ok, err = self.json:set_value(self.KEY_AT, math.floor(time_pos), file_path)
    if ok == nil then
      self.msg:error("Cannot log played: " .. tostring(err))
    end
  end
end

-- Remove played log.
function Playlist:unlog_played()
  local file_path = mp.get_property("path")

  for _, key in ipairs({self.KEY_ON, self.KEY_AT}) do
    local ok, err = self.json:set_value(key, nil, file_path)
    if ok == nil then
      self.msg:error("Cannot unlog played: " .. tostring(err))
      return
    end
  end
end
