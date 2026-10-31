-----------------------------------------------------------------------------
-- Json class will manipulate TMSU application. 
-----------------------------------------------------------------------------
local home = os.getenv("HOME")
package.path = package.path .. ';' .. home .. '/.config/mpv/scripts/?.lua'
--package.path = package.path .. ';' .. 'C:\\xuan\\soft-bin\\mpv-x86_64-20200419-git-a09c769\\portable_config\\scripts\\?.lua'

require 'xmpv-utils'
require 'xmpv-msg'

-- ***** Variables *****
Json = {
  msg = Msg:new(),  
}

-- 'Constructor'
function Json:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

-- ***** Functions *****
function Json:get_tag_cmd(tags_value, cmd_file_path)
  local shell_filename = get_shell_filename(cmd_file_path)
  return string.format("tmsu tag --tags=\"%s\" %s", tags_value, shell_filename)
end

-- @deprecated Use tags() instead
function Json:tag(tag_name, tag_value, cmd_file_path)
  local cmd_tag = self:get_tag_cmd(tag_name.."="..tag_value, cmd_file_path)
  return execute_command(cmd_tag)
end

function Json:tags(tags_value, cmd_file_path)
  local cmd_tag = self:get_tag_cmd(tags_value, cmd_file_path)
  return execute_command(cmd_tag)
end

-- @deprecated. Use untags() instead.
function Json:untag(tag_name, tag_value, cmd_file_path)
  local cmd_untag = string.format("tmsu untag --tags=\"%s=%s\" %s", tag_name, tag_value, cmd_file_path)
  return execute_command(cmd_untag)
end

function Json:get_untag_cmd(tags_value, cmd_file_path)
  return string.format("tmsu untag --tags=\"%s\" %s", tags_value, cmd_file_path)
end

function Json:untags(tags_value, cmd_file_path)
  local cmd_untag = self:get_untag_cmd(tags_value, cmd_file_path)
  print(cmd_untag)
  return execute_command(cmd_untag)
end


-- Return raw tags, unformatted from TMSU.
function Json:get_tags(file_name_for_cmd)
  local shell_filename = get_shell_filename(file_name_for_cmd)
  local cmd_get_tags = string.format("tmsu tags %s", shell_filename)
  return execute_command(cmd_get_tags)  
end

-- Check if TMSU application exists.
function Json:exists()
  local cmd_get_tmsu_version = "tmsu --version"
  local cmd_results = execute_command(cmd_get_tmsu_version)
  
  if (string.find(cmd_results, "TMSU")==nil) then
    local error_msg = string.format("%s can't run.\n", mp.get_script_name())
		  error_msg = error_msg .. string.format("It requires TMSU. Download it at http://tmsu.org/.")
		  self.msg:error(error_msg)
	
  end 
end

-- Mark position in positions array in <video filename>.xmpv.json if position is not already present. 
--  If file json does not exist, it will be created.
function Json:mark(position, file_path)
  local json_filename = file_path .. ".xmpv.json"
  local positions = {}
  local f = io.open(json_filename, "r")
  if f then
    local content = f:read("*a")
    f:close()
    if content ~= "" then
      local ok, data = pcall(function() return require("json").decode(content) end)
      if ok and data and data.positions then
        positions = data.positions
      end
    end
  end

  for _, pos in ipairs(positions) do
    if pos == position then
      return
    end
  end

  table.insert(positions, position)
  local data = { positions = positions }
  local file = io.open(json_filename, "w")
  io.output(file)
  io.write(require("json").encode(data))
  io.close(file)
end

