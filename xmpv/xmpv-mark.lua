-----------------------------------------------------------------------------
-- Mark class. 
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
Mark = {
  json = Json:new(),

  msg = Msg:new(),
}

-- 'Constructor'
function Mark:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  return o
end

-- Return current playback position in seconds. Otherwise, warn and return nil.
function Mark:get_time_pos()
  local time_pos = mp.get_property_number("time-pos")
  if time_pos == nil then
    self.msg:warn("No current position")
  end
  return time_pos
end

--  It breeds from goto_previous_position().
--  Delete the previous position from `<video filename>.xmpv.json`.
function Mark:delete_previous_position()

  local mark_positions = self:get_mark_positions()
  local mark_positions_size = #mark_positions 
  if(mark_positions_size < 1) then
    self.msg:warn("No marked position")
    return
  end

  local current_pos = self:get_time_pos()
  if current_pos == nil then return end
  local previous_pos = mark_positions[mark_positions_size] -- Initialize previous position to be the last pos.
  for i, mark_position in ipairs(mark_positions) do
    if tonumber(current_pos) < tonumber(mark_position) then
      break
    else
      previous_pos = mark_position
    end
  end
  -- 'Make it goes around logic' here: If previous pos not found, then it is the last pos.

  local ok, err = self.json:unmark(previous_pos, mp.get_property("path"))
  if ok == nil then
    self.msg:error("Cannot delete marked position: " .. tostring(err))
    return
  end

  local warn_msg = string.format("M(-) %s", time_to_hh_mm_ss(previous_pos))
  self.msg:warn(warn_msg)

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
  
    local current_pos = self:get_time_pos()
    if current_pos == nil then return end
    local found_next_pos = false
    for i, mark_position in ipairs(mark_positions) do
      if tonumber(current_pos) < tonumber(mark_position) then
        mp.commandv("seek", mark_position, "absolute", "exact")
        found_next_pos = true
        local msg = string.format("-> %s", time_to_hh_mm_ss(mark_position))
        self.msg:print(msg)   
        break
      end
    end
  
    -- 'Make it goes around logic' here.
    if ( not found_next_pos ) then
      mp.commandv("seek", mark_positions[1], "absolute", "exact")
      local msg = string.format("@-> %s", time_to_hh_mm_ss(mark_positions[1]))
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
  
    local current_pos = self:get_time_pos()
    if current_pos == nil then return end
    current_pos = current_pos - 2 --  Minus 2 seconds to allow time for user to do Previous, Previous, ... 
    local found_previous_pos = false
    local previous_pos = mark_positions[mark_positions_size] -- Initialize previous position to be the last pos.
    for i, mark_position in ipairs(mark_positions) do
      if tonumber(current_pos) < tonumber(mark_position) then
        mp.commandv("seek", previous_pos, "absolute", "exact")
        found_previous_pos = true
        local msg = string.format("%s <-", time_to_hh_mm_ss(previous_pos))
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
      local msg = string.format("%s <-@", time_to_hh_mm_ss(previous_pos))
      self.msg:print(msg)
    end
    
  end

end

-- Mark position but discard fraction of second.
function Mark:mark_position()
  local time_pos = self:get_time_pos()
  if time_pos == nil then return end
  local current_position = math.floor(time_pos)

  local ok, err = self.json:mark(current_position, mp.get_property("path"))
  if ok == nil then
    self.msg:error("Cannot mark position: " .. tostring(err))
    return
  end

  if ok == false then
    self.msg:warn(string.format("Already marked %s", time_to_hh_mm_ss(current_position)))
    return
  end
  
  local msg = string.format("M(+) %s", time_to_hh_mm_ss(current_position))
  self.msg:print(msg)
end


-- Return a string of formatted marked positions.
--  Marked positions formatted as HH:MM:SS, HH:MM:SS, HH:MM:SS
function Mark:get_formatted_positions()
  local mark_positions = self:get_mark_positions()
  for i, mark_position in ipairs(mark_positions) do
    mark_positions[i] = time_to_hh_mm_ss(mark_position)
  end
  
  return table.concat(mark_positions, ", ")
end


-- Return marked positions in ascending order from `<video filename>.xmpv.json`.
-- Return empty table if there is no position or the json file cannot be read.
function Mark:get_mark_positions()
  local positions, err = self.json:get_positions(mp.get_property("path"))
  if positions == nil then
    self.msg:warn("Cannot get marked positions: " .. tostring(err))
    return {}
  end

  return positions
end

-- Export marked time positions from `<video filename>.xmpv.json` into a file with extension XMP(X marked positions)
--  * Human readable marked time positions.
function Mark:export()
  local positions, err = self.json:get_positions(mp.get_property("path"))
  if positions == nil then
    self.msg:warn("Cannot export marked positions: " .. tostring(err))
    return
  end

  if #positions < 1 then
    self.msg:warn("No marked position. Nothing to export.")
    return
  end

  -- Construct formatted marked time positions
  local formatted = {}
  for i, position in ipairs(positions) do
    formatted[i] = time_to_hh_mm_ss(position)
  end
  local formatted_mark_positions = "# Marked time positions: " .. table.concat(formatted, ", ")

  -- Write human readable marked time positions to file.
  local filename = mp.get_property("path") .. ".xmp"
  local ok, write_err = self:write_file(filename, formatted_mark_positions .. "\n")
  if not ok then
    self.msg:error("Cannot export to \"" .. filename .. "\": " .. tostring(write_err))
    return
  end

  -- Display actions messages.
  local asst = Asst:new()
  local msg = string.format("Exported \n\t%s\n\tto \"%s\".", asst:long_text(formatted_mark_positions), asst:long_text(filename))
  self.msg:info(msg)
end

-- Write content to file. Return true, or nil and error message.
function Mark:write_file(path, content)
    local file, open_err = io.open(path, "w")
    if file == nil then
        return nil, tostring(open_err)
    end

    local write_ok, write_err = file:write(content)
    local close_ok, close_err = file:close() -- Close reports flush errors, e.g. disk full.
    if not write_ok then
        return nil, tostring(write_err)
    end
    if not close_ok then
        return nil, tostring(close_err)
    end
    return true
end

-- Export delete script, e.g. write 'rm -f <quoted filename>' > filename.del
function Mark:export_delete_script()
    local filename        = mp.get_property("path")
    local output_filename = filename .. ".del"
    local f               = io.open(output_filename, "r")
    local asst            = Asst:new()
    
    if f then
        f:close()
        os.remove(output_filename)
        
        local text = string.format("Removed delete script: \n%s", output_filename)

        local conMsg = string.format("%s%s%s", "\27[31m", text, "\27[0m")
        local osdMsg = string.format("%s%s%s%s", asst:on(), asst:red(), text, asst:reset(), asst:off())
        self.msg:print(conMsg, osdMsg, 5)
        
    else
        local ok, write_err = self:write_file(output_filename, "rm -f " .. get_shell_filename(filename) .. "\n")
        if not ok then
            self.msg:error("Cannot create delete script: " .. tostring(write_err))
            return
        end
        local text = string.format("Created delete script: \n%s", output_filename)

        local conMsg = string.format("%s%s%s", "\27[32m", text, "\27[0m")
        local osdMsg = string.format("%s%s%s%s", asst:on(), asst:green(), text, asst:reset(), asst:off())
        self.msg:print(conMsg, osdMsg, 2)
        
    end
end

-- Export current marked position to a file(<video filename>.sh)
function Mark:export_current_position_script()
    local filename        = mp.get_property("path")
    local output_filename = filename .. ".sh"
    local asst            = Asst:new()

    local current_pos = mp.get_property_number("time-pos")
    if current_pos == nil then
        self.msg:warn("No current position")
        return
    end

    -- Write command shell: mpv --start=<current_position> '<video_filename>'
    local position_hh_mm_ss = time_to_hh_mm_ss(current_pos)
    local shell_filename = get_shell_filename(filename)
    local ok, write_err = self:write_file(output_filename, "mpv --start=" .. position_hh_mm_ss .. " " .. shell_filename .. "\n")
    if not ok then
        self.msg:error("Cannot create current position script: " .. tostring(write_err))
        return
    end
    local text = string.format("Created current position script: \n%s", output_filename)

    local conMsg = string.format("%s%s%s", "\27[32m", text, "\27[0m")
    local osdMsg = string.format("%s%s%s%s", asst:on(), asst:green(), text, asst:reset(), asst:off())
    self.msg:print(conMsg, osdMsg, 2)
end