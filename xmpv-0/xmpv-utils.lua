-----------------------------------------------------------------------------
-- This file hold common functions. 
-----------------------------------------------------------------------------

-- Execute command and return result.
function execute_command(command)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  return result
end

-- Return seconds formatted as HH:MM:SS
function time_to_hh_mm_ss(time_pos_sec)
    local hours = math.floor(time_pos_sec / 3600)
    local minutes = math.floor((time_pos_sec % 3600) / 60)
    local seconds = math.floor(time_pos_sec % 60)

    -- Formats into HH:MM:SS with leading zeros
    local formatted_time = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    return formatted_time
end

-- Return correct path depending on the operating system
function get_script_path(script_name)
  local home_dir = os.getenv ("HOME")
  if (home_dir==nil) then
    home_dir = os.getenv ("APPDATA")
    return home_dir .. "\\mpv\\scripts\\" .. script_name
  else
      return home_dir .. "/.config/mpv/scripts/" .. script_name
  end

end

-- Get filename without extension.
-- Reference: https://love2d.org/forums/viewtopic.php?f=4&t=11145
function get_basename(filename)
  return filename:match("^([^%.]*)%.?") -- "myfile.lua" -> "myfile"
end

-- Return true if string is empty.
-- Reference: http://stackoverflow.com/a/19667498
function is_empty(s)
  return s == nil or s == ''
end

-- Return filename formatted for shell. e.g escape $
function get_shell_filename(s)
    return string.gsub(s, "%$", "\\$")
end

-- ********************************************************************
-- Library functions
-- ********************************************************************
function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end