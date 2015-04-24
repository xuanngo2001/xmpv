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
function time_to_string(seconds)
  return string.format("%.2d:%.2d:%.2d", seconds/(60*60), seconds/60%60, seconds%60)
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

-- Reference: https://love2d.org/forums/viewtopic.php?f=4&t=11145
function get_basename(filename)
  return filename:match("^([^%.]*)%.?") -- "myfile.lua" -> "myfile"
end
-- ********************************************************************
-- Library functions
-- ********************************************************************
function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end