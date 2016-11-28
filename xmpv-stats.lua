-----------------------------------------------------------------------------
-- Stats class. 
-----------------------------------------------------------------------------
require 'xmpv-utils'
require 'mp.options'
require 'xmpv-tmsu'
require 'xmpv-likes'
require 'xmpv-mark'
require 'xmpv-msg'
require 'xmpv-asst'

-- ***** Variables *****
Stats = {
  file_path="",

  tmsu = Tmsu:new(),  
  msg = Msg:new(),
  asst = Asst:new(),
  likes = nil,
  mark = nil,
}

-- 'Constructor'
function Stats:new(o, file_path)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  -- Initialize values
  self.file_path = file_path
  
  self.likes = Likes:new(nil, self.file_path)
  self.mark = Mark:new(nil, self.file_path)
  
  return o
end

-- Print information about current playing file.
function Stats:print()

  local indent = "   "
  local file   = string.format("%6s: %s\n", "File", self.asst:long_text(mp.get_property_osd("filename")))
  local likes  = string.format("%6s: %s\n", "Likes", self.likes:get_number())
  local tags   = string.format("%6s: %s\n", "Tags", self.asst:long_text(self:get_tags()))
  local marked = string.format("%6s\n%s%s\n", "Marked", indent, self.asst:long_text(self.mark:get_formatted_positions()))
  
  local stats = file .. likes .. tags .. marked
  self.msg:print(stats)
  print(stats)
end

-- Get a list of tags, excluding xmark and xlikes.
function Stats:get_tags()

  -- Get raw tags of current file.
  local cmd_results = self.tmsu:get_tags(self.file_path)
  
  -- Remove <filename> from result.
  --    [ ]? => With or without a space. No space when no tag at all.
  cmd_results = string.gsub(cmd_results, "^.*:[ ]?", "")

  -- Remove 'likes=XXX' tag from result.
  --  Handle negative value too.
  local likes_tag_pattern = Likes.TAG_NAME .. "=[-]?%d*"
  cmd_results = string.gsub(cmd_results, likes_tag_pattern, "")

  -- Remove 'mark=XXXXX' tag from result.
  local mark_tag_pattern = Mark.TAG_NAME .. "=%d*[.]?%d*"
  cmd_results = string.gsub(cmd_results, mark_tag_pattern, "")
  
  -- Remove 'xplayedXXX=XXXXX' tags from result.
  local xplayed_tag_pattern = "xplayed.*[ ]?"
  cmd_results = string.gsub(cmd_results, xplayed_tag_pattern, "")  
  
  -- Remove newline from result.
  cmd_results = string.gsub(cmd_results, "\n", "")
  
  -- Concatenate all tags with comma.
  local tags = ""
  for token in string.gmatch(cmd_results, "%S+") do
    -- Concatenate tags
    tags = tags .. ", " .. token
  end 
  
  -- Quick clean up of comma if there is only 1 tag.
  tags = string.gsub(tags, "^, ", "")
  
  return tags
  
end
