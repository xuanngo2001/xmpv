-----------------------------------------------------------------------------
-- Likes class. Likes are stored in `likes` of `<video filename>.xmpv.json`.
-----------------------------------------------------------------------------
local home, appdata = os.getenv("HOME"), os.getenv("APPDATA") -- APPDATA on Windows, where HOME is not set.
if home then
  package.path = package.path .. ';' .. home .. '/.config/mpv/scripts/?.lua'
elseif appdata then
  package.path = package.path .. ';' .. appdata .. '\\mpv\\scripts\\?.lua'
end
--package.path = package.path .. ';' .. 'C:\\xuan\\soft-bin\\mpv-x86_64-20200419-git-a09c769\\portable_config\\scripts\\?.lua'

require 'xmpv-utils'
require 'xmpv-json'
require 'xmpv-msg'
require 'xmpv-asst'


-- ***** Variables *****
Likes = {
  KEY="likes",

  json = Json:new(),
  msg = Msg:new(),
  asst = Asst:new(),
}

-- 'Constructor'
function Likes:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

-- Add `delta` to the number of likes and print it with `label`, e.g. "L(+)".
function Likes:add(delta, label)
  local file_path = mp.get_property("path")

  local likes_number, err = self.json:get_value(self.KEY, file_path)
  if err ~= nil then
    self.msg:error("Cannot get likes: " .. tostring(err))
    return
  end

  likes_number = (tonumber(likes_number) or 0) + delta
  local ok, set_err = self.json:set_value(self.KEY, likes_number, file_path)
  if ok == nil then
    self.msg:error("Cannot set likes: " .. tostring(set_err))
    return
  end

  self.msg:print(string.format("%s %d", label, likes_number))
end

-- Increment the previous likes number by 1.
function Likes:increment()
  self:add(1, "L(+)")
end

-- Decrement the previous likes number by 1.
function Likes:decrement()
  self:add(-1, "L(-)")
end

-- Return number of likes. Otherwise, return empty string.
function Likes:get_number()
  local likes_number, err = self.json:get_value(self.KEY, mp.get_property("path"))
  if err ~= nil then
    self.msg:error("Cannot get likes: " .. tostring(err))
    return ""
  end

  likes_number = tonumber(likes_number)
  if likes_number == nil then
    return ""
  end
  return likes_number
end

-- Reset by removing completely the likes key.
function Likes:reset()
  local file_path = mp.get_property("path")

  local likes_number, err = self.json:get_value(self.KEY, file_path)
  if err ~= nil then
    self.msg:error("Cannot get likes: " .. tostring(err))
    return
  end

  if likes_number == nil then
    self.msg:print("NOTHING to RESET")
    return
  end

  local ok, set_err = self.json:set_value(self.KEY, nil, file_path)
  if ok == nil then
    self.msg:error("Cannot reset likes: " .. tostring(set_err))
    return
  end
  self.msg:print(string.format("RESET %s", self.KEY))
end
