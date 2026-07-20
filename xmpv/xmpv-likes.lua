-----------------------------------------------------------------------------
-- Likes class. 
-----------------------------------------------------------------------------
require 'xmpv-utils'
require 'xmpv-tmsu'
require 'xmpv-msg'
require 'xmpv-asst'


-- ***** Variables *****
Likes = {
  TAG_NAME="xlikes",
  file_path="",
  
  tmsu = Tmsu:new(),
  msg = Msg:new(),
  asst = Asst:new(),
}

-- 'Constructor'
function Likes:new(o, file_path)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  -- Extra arguments
  self.file_path = file_path
  
  return o
end

-- Increment the previous likes number by 1.
function Likes:increment()

  local likes_number = self:get_number()
  if(likes_number=="") then
    likes_number = 0
  else
    --Remove current 'likes=xxx' tag number.
    self.tmsu:untag(self.TAG_NAME, likes_number, self.file_path)
  end
  
  --Increment the number of likes.
  likes_number = likes_number + 1
  self.tmsu:tag(self.TAG_NAME, likes_number, self.file_path)
  self.msg:print(string.format("L(+) %d", likes_number))
  
end

-- Decrement the previous likes number by 1.
function Likes:decrement()

  local likes_number = self:get_number()
  
  if(likes_number=="") then
    likes_number = 0
  else
    --Remove current 'likes=xxx' tag number.
    self.tmsu:untag(self.TAG_NAME, likes_number, self.file_path)    
  end 
  
  --Decrement the number of likes: tmsu tag --tags likes=123 <filename>
  likes_number = likes_number - 1
  self.tmsu:tag(self.TAG_NAME, likes_number, self.file_path)
  self.msg:print(string.format("L(-) %d", likes_number))
  
end

-- Return number of likes. Otherwise, return empty string.
function Likes:get_number()
  
  -- Get raw tags of current file.
  local cmd_results = self.tmsu:get_tags(self.file_path) 

  -- Extract the number of likes.
  local likes_number = ""
  local tag_pattern = self.TAG_NAME .. "="
  for token in string.gmatch(cmd_results, "%S+") do
    if string.starts(token, tag_pattern) then
      likes_number = string.gsub(token, tag_pattern, "")
    end
  end
  
  return likes_number
end

-- Print top (max_favorites=10) favorites/likes
function Likes:print_top_favorites()
  
  -- Get likes values: 'tmsu values <tagname>'.
  local cmd_get_likes_values = string.format("tmsu values %s", self.TAG_NAME)
  local cmd_results = execute_command(cmd_get_likes_values)
  
  -- Put likes values in array.
  local likes_values = {}
  local index = 0 -- In lua, index starts from 1 instead of 0.
  for token in string.gmatch(cmd_results, "%S+") do
    if(token~=nil) then
      index = index + 1
      likes_values[index] = token
    end
  end 
  
  -- Sort likes values in ascending order by numerical value.
  table.sort(likes_values, function(a,b) return tonumber(a)<tonumber(b) end)
  
  -- Get top favorites
  local max_favorites = 10
  local n=0 -- n will get the final number of favorites.
  local top_favorites = {}
  for i=index,1,-1 do
    -- Put files into top_favorites array.
    local cmd_get_top_favorites = string.format("tmsu files \"%s=%d\"", self.TAG_NAME, likes_values[i])
    local cmd_results = execute_command(cmd_get_top_favorites)
    for line in string.gmatch(cmd_results, "[^\r\n]+") do 
      n = n + 1
      top_favorites[n] = string.format("[%4d] %s", likes_values[i], line)
    end
    
    -- Stop looping if it reaches max_favorites.
    if n > max_favorites then
      break -- Terminate the loop instantly.
    end
  end
  
  -- Print top favorites
  --  Use n instead of max_favorites. Drawback: It will display all
  --    the 10th likes.
  local favorites_msg = "TOP FAVORITES\n"
  favorites_msg = favorites_msg .. table.concat(top_favorites, '\n')
  self.msg:print(favorites_msg, self.asst:long_text(favorites_msg), 10)
end

-- Reset by removing completely the likes tag.
function Likes:reset()

  local likes_number = self:get_number()
  if(likes_number~="") then
    --Remove current 'likes=xxx' tag.
    self.tmsu:untag(self.TAG_NAME, likes_number, self.file_path)
    self.msg:print(string.format("RESET %s", self.TAG_NAME))
  else
    self.msg:print("NOTHING to RESET")
  end
  
end

