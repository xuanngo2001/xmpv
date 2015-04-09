--[[
<readme>

# DESCRIPTION
`xmpv.lua` is an extension script for **MPV** that uses **TMSU** to provide the following features:
  
  * Tag files that you like.
  * Display your top favorite files.
  * Mark time position.
  * Play next marked time position.
  * Play previous marked time position.
  * Delete previous marked time position.

# INSTALL

## Requirements
* MPV: A media player. 
  * http://mpv.io/
* TMSU: A tool for tagging files. 
  * http://tmsu.org/
  
## Install
Copy `xmpv.lua` to `~/.config/mpv/scripts/` directory.

# USAGE
* Run your **MPV** as usual but now you have the following new hot keys:
  * `Alt+l`: Increment likes.
  * `Alt+d`: Decrement likes.
  * `Alt+r`: Reset likes to zero.
  * `Alt+i`: Print information of current playing file.
  * `Alt+t`: Print top favorites files.
  * `Alt+m`: Mark time position.
  * `Alt+n`: Play next marked time position.
  * `Alt+b`: Play previous marked time position.
  * `Alt+v`: Delete previous marked time position.  

# EXAMPLES:
```
[xmpv] ----------------------------------------------------------- 
[xmpv]   Filename: some_music_file_name.mp3 
[xmpv]      Likes: 11 
[xmpv]       Tags: music, funky 
[xmpv] Marked Pos: 00:01:04, 00:02:41 
[xmpv] 
```

```
[xmpv] ----------------------------------------------------------- 
[xmpv] [Likes]--------------- TOP FAVORITES ---------------------- 
[xmpv] [  34] /x/audio/UnderInfluence/Books, Books, Books_20120526_33300.mp3 
[xmpv] [  11] ./some_music_file_name.mp3 
[xmpv] [   9] /x/audio/UnderInfluence/Brand.Envy_20120512_72214.mp3 
[xmpv] [   2] /x/audio/UnderInfluence/Colour.Schemes-How.Colours.Make.Us.Buy_2012-05-05.mp3 
[xmpv] [   1] ./00 file name& weird.mp3 
```

# REFERENCE: 
* https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst
* https://github.com/mpv-player/mpv/blob/master/DOCS/man/input.rst (also, search for 'osd-ass-cc')
* `mpv --list-properties` lists all properties available.
* Sample lua scripts: https://github.com/mpv-player/mpv/wiki/User-Scripts
* http://docs.aegisub.org/3.2/ASS_Tags/
* http://www.linuxquestions.org/questions/slackware-14/mplayer-shows-question-marks-for-some-characters-on-subtitle-works-fine-on-xine-906077/
* http://boards.4chan.org/g/thread/47352550/mpv-mpv-general

</readme>
]]--


require 'os'
require 'io'
require 'string'

likes_tag = "xlikes"
mark_tag  = "xmark"

file_name_for_cmd = ""

-- On "file-loaded", this function will run.
function on_file_loaded_init()

	file_name_for_cmd = get_file_name_for_cmd()
	tmsu_check()
	
  -- Auto increment the number of likes, when playback has elapsed
  --  for more than half.
  mp.add_timeout((get_length()/2), increment_likes)
  
end


-- ********************************************************************
-- Private functions
-- ********************************************************************

-- Return time length in seconds.
function get_length()
	local length = mp.get_property("length")
	
	-- Discard milliseconds
	length = string.gsub(length, "%.%d*", "")
	
	return length
end

-- Return file path.
function get_file_path()
	return mp.get_property("path")
end



-- Extract tags of file from TMSU.
function get_tags()
  
  tmsu = Tmsu:new()
	-- Get raw tags of current file.
	local cmd_results = tmsu:get_tags()
	
	-- Remove <filename> from result.
  --    [ ]? => With or without a space. No space when no tag at all.
	cmd_results = string.gsub(cmd_results, "^.*:[ ]?", "")

	-- Remove 'likes=XXX' tag from result.
	--	Handle negative value too.
	local likes_tag_pattern = likes_tag .. "=[-]?%d*"
	cmd_results = string.gsub(cmd_results, likes_tag_pattern, "")

	-- Remove 'mark=XXXXX' tag from result.
	local mark_tag_pattern = mark_tag .. "=%d*[.]?%d*"
	cmd_results = string.gsub(cmd_results, mark_tag_pattern, "")
	
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


-- Return sanitized file path for command line execution
--  string.format('%q', 'a string with "quotes"') => "a string with \"quotes\""
function get_file_name_for_cmd(filename)
	local filename = get_file_path()
	
	--Escape double quotes.
	filename = string.format('%q', filename)
	return filename
end




-- ********************************************************************
-- TMSU functions
-- ********************************************************************


-- Log error if TMSU is not found.
function tmsu_check()
  local cmd_get_tmsu_version = "tmsu --version"
  local cmd_results = execute_command(cmd_get_tmsu_version)
  
  if (string.find(cmd_results, "TMSU")==nil) then
    local message =            string.format("ERROR: %s can't run.\n", mp.get_script_name())
          message = message .. string.format("ERROR: It requires TMSU. Download it at http://tmsu.org/.")
    mp.msg.error(message)
  end 
end



-- ********************************************************************
-- Library functions
-- ********************************************************************
function string.starts(String,Start)
	return string.sub(String,1,string.len(Start))==Start
end


-- Execute command and return result.
function execute_command(command)
  local handle = io.popen(command)
  local result = handle:read("*a")
  handle:close()
  return result
end

-- ********************************************************************
-- Main features
-- ********************************************************************









-- Return seconds formatted as HH:MM:SS
function toTimeFormat(seconds)
  return string.format("%.2d:%.2d:%.2d", seconds/(60*60), seconds/60%60, seconds%60)
end









-- Print information about this file.
function print_stats()
  likes = Likes:new(nil, file_name_for_cmd)
  mark = Mark:new(nil, file_name_for_cmd)
  
	print("-----------------------------------------------------------")
	print("      File: " .. get_file_path())
	print("     Likes: " .. likes:get_number())
	print("      Tags: " .. get_tags())
  print("Marked Pos: " .. mark:get_formatted_positions())
	print()
end



------------------------------------------------------------------------
-- Set key bindings.
--	Note: Ensure this section to be at the end of file
--			so that all functions needed are defined.
------------------------------------------------------------------------

dofile("/root/.config/mpv/scripts/xmpv-likes.lua")


function increment_likes()
  likes = Likes:new(nil, file_name_for_cmd)
  likes:increment()
end

function decrement_likes()
  likes = Likes:new(nil, file_name_for_cmd)
  likes:decrement()
end

function reset_likes()
  likes = Likes:new(nil, file_name_for_cmd)
  likes:reset()
end

function print_top_favorites()
  likes = Likes:new(nil, file_name_for_cmd)
  likes:print_top_favorites()
end



dofile("/root/.config/mpv/scripts/xmpv-mark.lua")
mark = Mark:new(nil, file_name_for_cmd)

function mark_position()
  mark:mark_position()
end

function goto_next_mark_position()
  mark:goto_next_position()
end

function goto_previous_mark_position()
  mark:goto_previous_position()
end

function delete_previous_mark_position()
  mark:delete_previous_position()
end


mp.add_key_binding("Alt+l", "increment_likes", increment_likes)
mp.add_key_binding("Alt+d", "decrement_likes", decrement_likes)
mp.add_key_binding("Alt+r", "reset_likes", reset_likes)
mp.add_key_binding("Alt+t", "top_favorites", print_top_favorites)
mp.add_key_binding("Alt+i", "show_statistics", print_stats)
mp.add_key_binding("Alt+m", "mark_position", mark_position)
mp.add_key_binding("Alt+n", "goto_next_mark_position", goto_next_mark_position)
mp.add_key_binding("Alt+b", "goto_previous_mark_position", goto_previous_mark_position)
mp.add_key_binding("Alt+x", "delete_previous_mark_position", delete_previous_mark_position)

mp.register_event("file-loaded", on_file_loaded_init)
