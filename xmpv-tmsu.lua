-----------------------------------------------------------------------------
-- Tmsu class will manipulate TMSU application. 
-----------------------------------------------------------------------------
require 'xmpv-utils'
require 'xmpv-msg'

-- ***** Variables *****
Tmsu = {
  msg = Msg:new(),  
}

-- 'Constructor'
function Tmsu:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- ***** Functions *****
function Tmsu:get_tag_cmd(tags_value, cmd_file_path)
  return string.format("tmsu tag --tags=\"%s\" %s", tags_value, cmd_file_path)
end

-- @deprecated Use tags() instead
function Tmsu:tag(tag_name, tag_value, cmd_file_path)
  local cmd_tag = self:get_tag_cmd(tag_name.."="..tag_value, cmd_file_path)
  return execute_command(cmd_tag)
end

function Tmsu:tags(tags_value, cmd_file_path)
  local cmd_tag = self:get_tag_cmd(tags_value, cmd_file_path)
  return execute_command(cmd_tag)
end

-- @deprecated. Use untags() instead.
function Tmsu:untag(tag_name, tag_value, cmd_file_path)
  local cmd_untag = string.format("tmsu untag --tags=\"%s=%s\" %s", tag_name, tag_value, cmd_file_path)
  return execute_command(cmd_untag)
end

function Tmsu:get_untag_cmd(tags_value, cmd_file_path)
  return string.format("tmsu untag --tags=\"%s\" %s", tags_value, cmd_file_path)
end

function Tmsu:untags(tags_value, cmd_file_path)
  local cmd_untag = self:get_untag_cmd(tags_value, cmd_file_path)
  print(cmd_untag)
  return execute_command(cmd_untag)
end


-- Return raw tags, unformatted from TMSU.
function Tmsu:get_tags(file_name_for_cmd)
  local cmd_get_tags = string.format("tmsu tags %s", file_name_for_cmd)
  return execute_command(cmd_get_tags)  
end

-- Check if TMSU application exists.
function Tmsu:exists()
  local cmd_get_tmsu_version = "tmsu --version"
  local cmd_results = execute_command(cmd_get_tmsu_version)
  
  if (string.find(cmd_results, "TMSU")==nil) then
    local error_msg = string.format("%s can't run.\n", mp.get_script_name())
		  error_msg = error_msg .. string.format("It requires TMSU. Download it at http://tmsu.org/.")
		  self.msg:error(error_msg)
	
  end 
end
