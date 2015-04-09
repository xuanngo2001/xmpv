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