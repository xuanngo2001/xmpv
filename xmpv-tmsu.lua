-----------------------------------------------------------------------------
-- Tmsu class will manipulate TMSU application. 
-----------------------------------------------------------------------------

-- ***** Variables *****
Tmsu = {
  
}

-- 'Constructor'
function Tmsu:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- ***** Functions *****
function Tmsu:tag(tag_name, tag_value, cmd_file_path)
  local cmd_tag = string.format("tmsu tag --tags=\"%s=%s\" %s", tag_name, tag_value, cmd_file_path)
  return execute_command(cmd_tag)
end

function Tmsu:untag(tag_name, tag_value, cmd_file_path)
  local cmd_untag = string.format("tmsu untag --tags=\"%s=%s\" %s", tag_name, tag_value, cmd_file_path)
  return execute_command(cmd_untag)
end

-- Return raw tags, unformatted from TMSU.
function Tmsu:get_tags()
  -- Get tags of current file: tmsu tags <filename>
  local cmd_get_tags = string.format("tmsu tags %s", file_name_for_cmd)
  return execute_command(cmd_get_tags)  

end

-- Check if TMSU application exists.
function Tmsu:exists()
  local cmd_get_tmsu_version = "tmsu --version"
  local cmd_results = execute_command(cmd_get_tmsu_version)
  
  if (string.find(cmd_results, "TMSU")==nil) then
    local message =            string.format("ERROR: %s can't run.\n", mp.get_script_name())
          message = message .. string.format("ERROR: It requires TMSU. Download it at http://tmsu.org/.")
    mp.msg.error(message)
  end 
end
