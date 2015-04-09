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


-- ********************************************************************
-- Library functions
-- ********************************************************************
function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end