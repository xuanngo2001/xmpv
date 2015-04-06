-- DESCRIPTION: xmpv.lua integrates MPV and TMSU to provide the following features:
--		-Tag files that you liked.
-- USAGE:
--	Alt+l: Increment like.
--	Alt+i: Print info.

-- INSTALL: This script should be put in ~/.mpv/lua/ directory. /root/.config/mpv/scripts
-- REFERENCE: http://bamos.github.io/2014/07/05/mpv-lua-scripting/
-- 			https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst

require 'os'
require 'io'
require 'string'

likes_tag="likes"

-- ********************************************************************
-- Helper functions
-- ********************************************************************

-- Increment the previous likes number by 1.
function increment_likes()

	local likes_number = get_likes_number()
	
	--Remove 'likes=xxx' tag: tmsu untag --tags="likes" <filename>
	local cmd_untag_likes = string.format("tmsu untag --tags=\"%s=%d\" '%s'", likes_tag, likes_number, get_file_name())
	execute_command(cmd_untag_likes)
	
	--Increment the number of times likes: tmsu tag --tags likes=123 <filename>
	likes_number = likes_number + 1
	local cmd_inc_likes_number = string.format("tmsu tag --tags=\"%s=%d\" '%s'", likes_tag, likes_number, get_file_name())
	print(cmd_inc_likes_number)
	execute_command(cmd_inc_likes_number)
	
end

-- Return length in seconds.
function get_length()
	local length = mp.get_property("length")
	
	-- Discard miliseconds
	length = string.gsub(length, "%.%d*", "")
	
	return length
end

-- Return number of likes.
function get_likes_number()
	-- Get tags of current file: tmsu tags <filename>
	local cmd_get_tags = string.format("tmsu tags '%s'", get_file_name())
	local cmd_results = execute_command(cmd_get_tags)
	
	-- Extract the number of likes.
	local likes_number = 0
	for token in string.gmatch(cmd_results, "%S+") do
		if string.starts(token, "likes=") then
			likes_number = string.gsub(token, "likes=", "")
		end
	end
	
	return likes_number
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

	-- Get tags of current file: tmsu tags <filename>
	local cmd_get_tags = string.format("tmsu tags '%s'", get_file_name())
	local cmd_results = execute_command(cmd_get_tags)	
	
	-- Remove <filename> from result.
	cmd_results = string.gsub(cmd_results, "^.*: ", "")

	-- Remove 'likes=' tag from result.
	local likes_tag_pattern = likes_tag .. "=.* "
	cmd_results = string.gsub(cmd_results, likes_tag_pattern, "")
	
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
	print("   Likes: " .. get_likes_number())
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
