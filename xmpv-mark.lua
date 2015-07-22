-----------------------------------------------------------------------------
-- Mark class. 
-----------------------------------------------------------------------------
require 'xmpv-utils'
require 'xmpv-tmsu'
require 'xmpv-msg'

-- ***** Variables *****
Mark = {
  TAG_NAME="xmark",
  file_path="",
  
  tmsu = Tmsu:new(),
  msg = Msg:new(),
}

-- 'Constructor'
function Mark:new(o, file_path)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  -- Extra arguments
  self.file_path = file_path
  
  return o
end

--  It breeds from goto_previous_position().
function Mark:delete_previous_position()

  local mark_positions = self:get_mark_positions()
  local mark_positions_size = #mark_positions 
  if(mark_positions_size < 1) then
    self.msg:warn("No marked position")
  else
  
    local current_pos = mp.get_property_number("time-pos")
    local found_previous_pos = false
    local previous_pos = mark_positions[mark_positions_size] -- Initialize previous position to be the last pos.
    for i, mark_position in ipairs(mark_positions) do
      if tonumber(current_pos) < tonumber(mark_position) then
        self.tmsu:untag(self.TAG_NAME, previous_pos, self.file_path)
        found_previous_pos = true
        local warn_msg = string.format("M(-) %s", time_to_string(previous_pos))
        self.msg:warn(warn_msg)        
        break
      else
        previous_pos = mark_position
      end
    end
  
    -- 'Make it goes around logic' here: If previous pos not found, then goes to the last pos.
    if ( not found_previous_pos ) then
      previous_pos = mark_positions[mark_positions_size]
      self.tmsu:untag(self.TAG_NAME, previous_pos, self.file_path)
      local warn_msg = string.format("M(-) %s", time_to_string(previous_pos))
      self.msg:warn(warn_msg)
    end
    
  end

end


-- Go to the next marked position.
--  Make it goes around: If it is the end, start over.
--  Special cases:
--    -No marked position.
--    -Only 1 marked position.
--    -Should not take current position == to mark position. Only the next bigger position.
--    -Can do Next, Next ...
function Mark:goto_next_position()
  
  local mark_positions = self:get_mark_positions()
  if(#mark_positions < 1) then
    self.msg:warn("No marked position")
  else
  
    local current_pos = mp.get_property_number("time-pos")
    local found_next_pos = false
    for i, mark_position in ipairs(mark_positions) do
      if tonumber(current_pos) < tonumber(mark_position) then
        mp.commandv("seek", mark_position, "absolute", "exact")
        found_next_pos = true
        local msg = string.format("-> %s", time_to_string(mark_position))
        self.msg:print(msg)   
        break
      end
    end
  
    -- 'Make it goes around logic' here.
    if ( not found_next_pos ) then
      mp.commandv("seek", mark_positions[1], "absolute", "exact")
      local msg = string.format("@-> %s", time_to_string(mark_positions[1]))
      self.msg:print(msg) 
    end
    
  end
   
end

-- Go to the previous marked position.
--  Make it goes around: If it is the beginning, go to the last position.
--  It breeds from goto_next_position().
--  Special cases:
--    -No marked position.
--    -Only 1 marked position.
--    -Can do Previous, Previous ...
function Mark:goto_previous_position()
  
  local mark_positions = self:get_mark_positions()
  local mark_positions_size = #mark_positions 
  if(mark_positions_size < 1) then
    self.msg:warn("No marked position")
  else
  
    local current_pos = mp.get_property_number("time-pos") - 2 --  Minus 2 seconds to allow time for user to do Previous, Previous, ... 
    local found_previous_pos = false
    local previous_pos = mark_positions[mark_positions_size] -- Initialize previous position to be the last pos.
    for i, mark_position in ipairs(mark_positions) do
      if tonumber(current_pos) < tonumber(mark_position) then
        mp.commandv("seek", previous_pos, "absolute", "exact")
        found_previous_pos = true
        local msg = string.format("%s <-", time_to_string(previous_pos))
        self.msg:print(msg)     
        break
      else
        previous_pos = mark_position
      end
    end
  
    -- 'Make it goes around logic' here: If previous pos not found, then goes to the last pos.
    if ( not found_previous_pos ) then
      previous_pos = mark_positions[mark_positions_size]
      mp.commandv("seek", previous_pos, "absolute", "exact")
      local msg = string.format("%s <-@", time_to_string(previous_pos))
      self.msg:print(msg)
    end
    
  end

end

-- Mark position but discard fraction of second.
function Mark:mark_position()
  local current_position = math.floor(mp.get_property_number("time-pos"))
  self.tmsu:tag(self.TAG_NAME, current_position, self.file_path)
  
  local msg = string.format("M(+) %s", time_to_string(current_position))
  self.msg:print(msg)
end


-- Return a string of formatted marked positions.
--  Marked positions formatted as HH:MM:SS, HH:MM:SS, HH:MM:SS
function Mark:get_formatted_positions()
  local mark_positions = self:get_mark_positions()
  for i, mark_position in ipairs(mark_positions) do
    mark_positions[i] = time_to_string(mark_position)
  end
  
  return table.concat(mark_positions, ", ")
end


-- Return marked positions in ascending order
function Mark:get_mark_positions()

  local raw_tags = self.tmsu:get_tags(self.file_path)
  
  local mark_tag_label = self.TAG_NAME .."="
  local i = 1
  local mark_position_values = {}
  for token in string.gmatch(raw_tags, "%S+") do
    if string.starts(token, mark_tag_label) then
      mark_position_values[i]=string.gsub(token, mark_tag_label, "")
      i = i + 1
    end
  end

  table.sort(mark_position_values, function(a,b) return tonumber(a)<tonumber(b) end)  
  return mark_position_values
end

-- Export marked time positions into a file with extension XMP(X marked positions)
--  * Human readable marked time positions.
--  * Marked time positions command for TMSU.
function Mark:export()
  -- Get marked tag values command.
  local mark_positions_string = self.TAG_NAME .. "=" .. table.concat(self:get_mark_positions(), " ".. self.TAG_NAME .. "=")
  local mark_positions_cmd = self.tmsu:get_tag_cmd(mark_positions_string, self.file_path)
  
  -- Get formatted marked time positions
  local formatted_mark_positions = "# Marked time positions: " .. self:get_formatted_positions() 
  
  -- Write marked time positions to file:
  --  * Human readable marked time positions
  --  * Tag values TMSU command 
  local filename = mp.get_property("path") .. ".xmp"
  file = io.open(filename, "w")
  io.output(file)
  io.write(formatted_mark_positions .. "\n")
  io.write(mark_positions_cmd .. "\n")
  io.close(file)
  
  -- Display actions messages.
  print(string.format("Exported \n\t%s\n\tto \"%s\".", formatted_mark_positions, filename))
end