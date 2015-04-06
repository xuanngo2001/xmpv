-- Description: Print "Hello World" when press 'g'.
--	This script should be put in ~/.mpv/lua/ directory.
-- Reference: http://bamos.github.io/2014/07/05/mpv-lua-scripting/
-- 			https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst

require 'os'
require 'io'
require 'string'


function get_properties()
	print(mp.get_property("length"))
end



-- ********************************************************************
-- Main features
-- ********************************************************************
function increment_played()
	local time_played = get_time_played()
	--Remove 'played=xxx' tag: tmsu untag --tags="played" <filename>
	local cmd_untag_played = "tmsu untag --tags=\"played=" .. time_played .. "\" '" .. get_file_name() .. "'"
	print(cmd_untag_played)
	execute_command(cmd_untag_played)
	
	--Increment the number of times played: tmsu tag --tags played=123 <filename>
	time_played = time_played + 1
	local cmd_inc_time_played = "tmsu tag --tags  played=" .. time_played .. " '" .. get_file_name() .. "'"
	execute_command(cmd_inc_time_played)
end

function get_stats()
	print("-----------------------------------------------------------")
	print("Filename: " .. get_file_name())
	print("  Played: " .. get_time_played())
	print("    Tags: " .. get_tags())
	print()
end


---------------------------------------
-- Set key bindings.
---------------------------------------
mp.add_key_binding("a", "increment_played", increment_played)
mp.add_key_binding("i", "show_statistics", get_stats)



-- ********************************************************************
-- Helper functions
-- ********************************************************************
function get_time_played()
	-- Get tags of current play file: tmsu tags <filename>
	local command = "tmsu tags '" .. get_file_name() .. "'"
	local line_result = execute_command(command)
	
	-- Extract the number of time played.
	local time_played = 0
	for token in string.gmatch(line_result, "%S+") do
		if string.starts(token, "played=") then
			time_played = string.gsub(token, "played=", "")
		end
	end
	
	return time_played
end

function get_file_name()
	return mp.get_property("path")
end

-- Execute command and return result.
function execute_command(command)
	local handle = io.popen(command)
	local result = handle:read("*a")
	handle:close()
	return result
end

-- Extract tags of file from tmsu.
function get_tags()
	local filename = get_file_name()
	-- Get tags: tmsu tags <filename>
	local cmd_get_tags = "tmsu tags '" .. filename .. "'"
	local cmd_results = execute_command(cmd_get_tags)
	
	-- Remove <filename> from result.
	cmd_results = string.gsub(cmd_results, "^.*: ", "")

	-- Remove 'played=' tag from result.
	cmd_results = string.gsub(cmd_results, "played=.* ", "")
	
	-- Remove newline tag from result.
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

-- ********************************************************************
-- Library functions
-- ********************************************************************
function string.starts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end
