-- DESCRIPTION: xmpv.lua integrates MPV and TMSU to provide the following features:
--		-Tag files that you liked.
-- USAGE:
--		Hot keys:
--			Alt+l: Increment likes.
--			Alt+d: Decrement likes.
--			Alt+r: Reset likes to zero.
--			Alt+i: Print info.

-- INSTALL: This script should be copied to ~/root/.config/mpv/scripts/ directory.
-- REFERENCE: http://bamos.github.io/2014/07/05/mpv-lua-scripting/
-- 			https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst

require 'os'
require 'io'
require 'string'

likes_tag="likes"
file_name_for_cmd = ""

-- On "file-loaded", this function will run.
function initialization()
	file_name_for_cmd = get_file_name_for_cmd()
end


-- ********************************************************************
-- Helper functions
-- ********************************************************************

-- Increment the previous likes number by 1.
function increment_likes()

	local likes_number = get_likes_number()
	
	--Remove 'likes=xxx' tag: tmsu untag --tags="likes" <filename>
	local cmd_untag_likes = string.format("tmsu untag --tags=\"%s=%d\" %s", likes_tag, likes_number, file_name_for_cmd)
	execute_command(cmd_untag_likes)
	
	--Increment the number of likes: tmsu tag --tags likes=123 <filename>
	likes_number = likes_number + 1
	local cmd_inc_likes_number = string.format("tmsu tag --tags=\"%s=%d\" %s", likes_tag, likes_number, file_name_for_cmd)
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
	
	-- Get raw tags of current file.
	local cmd_results = get_raw_tags()	
	
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

-- Extract tags of file from TMSU.
function get_tags()

	-- Get raw tags of current file.
	local cmd_results = get_raw_tags()
	
	-- Remove <filename> from result.
	cmd_results = string.gsub(cmd_results, "^.*: ", "")

	-- Remove 'likes=' tag from result.
	--	Handle negative value too.
	local likes_tag_pattern = likes_tag .. "=[-]?%d*"
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

-- Return raw tags, unformatted from TMSU.
function get_raw_tags()
	-- Get tags of current file: tmsu tags <filename>
	local cmd_get_tags = string.format("tmsu tags %s", file_name_for_cmd)
	return execute_command(cmd_get_tags)	

end

function get_file_name_for_cmd(filename)
	local filename = get_file_name()
	
	--Escape double quotes.
	filename = string.format('%q', filename)
	return filename
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

-- Decrement the previous likes number by 1.
function decrement_likes()

	local likes_number = get_likes_number()
	
	--Remove 'likes=xxx' tag: tmsu untag --tags="likes" <filename>
	local cmd_untag_likes = string.format("tmsu untag --tags=\"%s=%d\" %s", likes_tag, likes_number, file_name_for_cmd)
	execute_command(cmd_untag_likes)
	
	--Decrement the number of likes: tmsu tag --tags likes=123 <filename>
	likes_number = likes_number - 1
	local cmd_inc_likes_number = string.format("tmsu tag --tags=\"%s=%d\" %s", likes_tag, likes_number, file_name_for_cmd)
	print(cmd_inc_likes_number)
	execute_command(cmd_inc_likes_number)
	
end

-- Reset likes number to 0.
function reset_likes()
	
	--Set the number of likes to zero: tmsu tag --tags likes=0 <filename>
	local likes_number = 0
	local cmd_inc_likes_number = string.format("tmsu tag --tags=\"%s=%d\" %s", likes_tag, likes_number, file_name_for_cmd)
	print(cmd_inc_likes_number)
	execute_command(cmd_inc_likes_number)
	
end

-- Print information about this file.
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
mp.add_key_binding("Alt+d", "decrement_likes", decrement_likes)
mp.add_key_binding("Alt+r", "reset_likes", reset_likes)
mp.add_key_binding("Alt+i", "show_statistics", print_stats)

-- Auto increment after X seconds.
mp.register_event("file-loaded", initialization)
mp.register_event("file-loaded", auto_increment_likes)

