-- DESCRIPTION: xmpv.lua integrates MPV and TMSU to provide the following features:
--		-Tag files that you liked.
-- USAGE:
--	Alt+l: Increment like.
--	Alt+i: Print info.

-- INSTALL: This script should be put in ~/.mpv/lua/ directory.
-- REFERENCE: http://bamos.github.io/2014/07/05/mpv-lua-scripting/
-- 			https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst

require 'os'
require 'io'
require 'string'


-- ********************************************************************
-- Helper functions
-- ********************************************************************

-- Get the previous likes number and add 1.
function increment_likes()
	local time_likes = get_time_likes()
	--Remove 'likes=xxx' tag: tmsu untag --tags="likes" <filename>
	local cmd_untag_likes = "tmsu untag --tags=\"likes=" .. time_likes .. "\" '" .. get_file_name() .. "'"
	print(cmd_untag_likes)
	execute_command(cmd_untag_likes)
	
	--Increment the number of times likes: tmsu tag --tags likes=123 <filename>
	time_likes = time_likes + 1
	local cmd_inc_time_likes = "tmsu tag --tags  likes=" .. time_likes .. " '" .. get_file_name() .. "'"
	execute_command(cmd_inc_time_likes)
	
end

-- Return length in seconds.
function get_length()
	local length = mp.get_property("length")
	
	-- Discard miliseconds
	length = string.gsub(length, "%.%d*", "")
	
	return length
end

-- Return number of times likes.
function get_time_likes()
	-- Get tags of current play file: tmsu tags <filename>
	local command = "tmsu tags '" .. get_file_name() .. "'"
	local line_result = execute_command(command)
	
	-- Extract the number of time likes.
	local time_likes = 0
	for token in string.gmatch(line_result, "%S+") do
		if string.starts(token, "likes=") then
			time_likes = string.gsub(token, "likes=", "")
		end
	end
	
	return time_likes
end

-- Return filename.
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

	-- Get tags: tmsu tags <filename>
	local cmd_get_tags = "tmsu tags '" .. get_file_name() .. "'"
	local cmd_results = execute_command(cmd_get_tags)
	
	-- Remove <filename> from result.
	cmd_results = string.gsub(cmd_results, "^.*: ", "")

	-- Remove 'likes=' tag from result.
	cmd_results = string.gsub(cmd_results, "likes=.* ", "")
	
	-- Remove newline from result.
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



-- ********************************************************************
-- Main features
-- ********************************************************************

-- Auto increment the number of times likes, when playback has elapsed
--	for more than half.
function auto_increment_likes(event)
	mp.add_timeout((get_length()/2), increment_likes)
end

function print_stats()
	print("-----------------------------------------------------------")
	print("Filename: " .. get_file_name())
	print("  likes: " .. get_time_likes())
	print("    Tags: " .. get_tags())
	print()
end



------------------------------------------------------------------------
-- Set key bindings.
--	Note: Ensure this section to be at the end of file
--			so that all functions needed are defined.
------------------------------------------------------------------------
mp.add_key_binding("Alt+l", "increment_likes", increment_likes)
mp.add_key_binding("Alt+i", "show_statistics", print_stats)

-- Auto increment after X seconds.
mp.register_event("file-loaded", auto_increment_likes)
