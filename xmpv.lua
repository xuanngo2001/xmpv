--[[
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
  * `Alt+i`: Print info.
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
* https://github.com/mpv-player/mpv/blob/master/DOCS/man/input.rst
* `mpv --list-properties` lists all properties available.

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

-- Increment the previous likes number by 1.
function increment_likes()

	local likes_number = get_likes_number()
	
	if(likes_number=="") then
		likes_number = 0
	else
		--Remove current 'likes=xxx' tag number.
		tmsu_untag(likes_tag, likes_number, file_name_for_cmd)
	end
	
	--Increment the number of likes.
	likes_number = likes_number + 1
	tmsu_tag(likes_tag, likes_number, file_name_for_cmd)
	mp.msg.info(string.format("INFO: Increased likes to %d.", likes_number))
	
end

-- Return time length in seconds.
function get_length()
	local length = mp.get_property("length")
	
	-- Discard milliseconds
	length = string.gsub(length, "%.%d*", "")
	
	return length
end

-- Return number of likes.
function get_likes_number()
	
	-- Get raw tags of current file.
	local cmd_results = tmsu_get_tags()	
	
	-- Extract the number of likes.
	local likes_number = ""
	local likes_tag_pattern = likes_tag .. "="
	for token in string.gmatch(cmd_results, "%S+") do
		if string.starts(token, likes_tag_pattern) then
			likes_number = string.gsub(token, likes_tag_pattern, "")
		end
	end
	
	return likes_number
end

-- Return file path.
function get_file_path()
	return mp.get_property("path")
end



-- Extract tags of file from TMSU.
function get_tags()

	-- Get raw tags of current file.
	local cmd_results = tmsu_get_tags()
	
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


-- Print top (max_favorites=10) favorites/likes
function print_top_favorites()
	
	-- Get likes values: 'tmsu values <tagname>'.
	local cmd_get_likes_values = string.format("tmsu values %s", likes_tag)
	local cmd_results = execute_command(cmd_get_likes_values)
	
	-- Put likes values in array.
	local likes_values = {}
	local index = 0 -- In lua, index starts from 1 instead of 0.
	for token in string.gmatch(cmd_results, "%S+") do
		if(token~=nil) then
			index = index + 1
			likes_values[index] = token
		end
	end	
	
	-- Sort likes values in ascending order by numerical value.
	table.sort(likes_values, function(a,b) return tonumber(a)<tonumber(b) end)
	
	-- Get top favorites
	local max_favorites = 10
	local n=0	-- n will get the final number of favorites.
	local top_favorites = {}
	for i=index,1,-1 do
		-- Put files into top_favorites array.
		local cmd_get_top_favorites = string.format("tmsu files \"%s=%d\"", likes_tag, likes_values[i])
		local cmd_results = execute_command(cmd_get_top_favorites)
		for line in string.gmatch(cmd_results, "[^\r\n]+") do 
      n = n + 1
			top_favorites[n] = string.format("[%4d] %s", likes_values[i], line)
		end
		
		-- Stop looping if it reaches max_favorites.
		if n > max_favorites then
			break -- Terminate the loop instantly.
		end
	end
	
	-- Print top favorites
	--	Use n instead of max_favorites. Drawback: It will display all
	--		the 10th likes.
	print("-----------------------------------------------------------")
	print("[Likes]--------------- TOP FAVORITES ----------------------")
	for j=1,n do
		print(top_favorites[j]) 
	end
	
end

-- ********************************************************************
-- TMSU functions
-- ********************************************************************

function tmsu_tag(tag_name, tag_value, cmd_file_path)
  local cmd_tag = string.format("tmsu tag --tags=\"%s=%s\" %s", tag_name, tag_value, cmd_file_path)
  execute_command(cmd_tag)
end

function tmsu_untag(tag_name, tag_value, cmd_file_path)
  local cmd_untag = string.format("tmsu untag --tags=\"%s=%s\" %s", tag_name, tag_value, cmd_file_path)
  execute_command(cmd_untag)
end

-- Return raw tags, unformatted from TMSU.
function tmsu_get_tags()
  -- Get tags of current file: tmsu tags <filename>
  local cmd_get_tags = string.format("tmsu tags %s", file_name_for_cmd)
  return execute_command(cmd_get_tags)  

end

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

-- http://lua-users.org/wiki/SplitJoin
function string.gsplit(s, sep, plain)
  local start = 1
  local done = false
  local function pass(i, j, ...)
    if i then
      local seg = s:sub(start, i - 1)
      start = j + 1
      return seg, ...
    else
      done = true
      return s:sub(start)
    end
  end
  return function()
    if done then return end
    if sep == '' then done = true return s end
    return pass(s:find(sep, start, plain))
  end
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



--  It breeds from goto_previous_mark_position().
function delete_previous_mark_position()

  local mark_positions = get_mark_positions()
  local mark_positions_size = table.getn(mark_positions) 
  if(mark_positions_size < 1) then
    mp.msg.warn("WARN: No marked position.")
  else
  
    local current_pos = mp.get_property("time-pos")
    local found_previous_pos = false
    local previous_pos = mark_positions[mark_positions_size] -- Initialize previous position to be the last pos.
    for i, mark_position in ipairs(mark_positions) do
      if tonumber(current_pos) < tonumber(mark_position) then
        tmsu_untag(mark_tag, previous_pos, file_name_for_cmd)
        found_previous_pos = true
        local warn_msg = string.format("WARN: Delete marked position %s.", toTimeFormat(previous_pos))
        mp.msg.warn(warn_msg)        
        break
      else
        previous_pos = mark_position
      end
    end
  
    -- 'Make it goes around logic' here: If previous pos not found, then goes to the last pos.
    if ( not found_previous_pos ) then
      previous_pos = mark_positions[mark_positions_size]
      tmsu_untag(mark_tag, previous_pos, file_name_for_cmd)
      local warn_msg = string.format("WARN: Delete marked position %s.", toTimeFormat(previous_pos))
      mp.msg.warn(warn_msg)
    end
    
  end

end


-- Go to the next marked position.
--  Make it goes around: If it is the end, start over.
--  Special cases:
--    -No marked position.
--    -Only 1 marked position.
--    -Should not take current position == to mark position. Only the next bigger position.
--    -Can do Next, Next ...
function goto_next_mark_position()
  
  local mark_positions = get_mark_positions()
  if(table.getn(mark_positions) < 1) then
    mp.msg.warn("WARN: No marked position.")
  else
  
    local current_pos = mp.get_property("time-pos")
    local found_next_pos = false
    for i, mark_position in ipairs(mark_positions) do
      if tonumber(current_pos) < tonumber(mark_position) then
        mp.commandv("seek", mark_position, "absolute", "exact")
        found_next_pos = true
        local warn_msg = string.format("Goto %d => %s.", mark_position, toTimeFormat(mark_position))
        mp.msg.warn(warn_msg)        
        break
      end
    end
  
    -- 'Make it goes around logic' here.
    if ( not found_next_pos ) then
      mp.commandv("seek", mark_positions[1], "absolute", "exact")
      local warn_msg = string.format("WARN: No more next marked position. Go to the first position at %s.", toTimeFormat(mark_positions[1]))
      mp.msg.warn(warn_msg)
    end
    
  end
   
end

-- Go to the previous marked position.
--  Make it goes around: If it is the beginning, go to the last position.
--  It breeds from goto_next_mark_position().
--  Special cases:
--    -No marked position.
--    -Only 1 marked position.
--    -Can do Previous, Previous ...
function goto_previous_mark_position()
  
  local mark_positions = get_mark_positions()
  local mark_positions_size = table.getn(mark_positions) 
  if(mark_positions_size < 1) then
    mp.msg.warn("WARN: No marked position.")
  else
  
    local current_pos = mp.get_property("time-pos") - 2 --  Minus 2 seconds to allow time for user to do Previous, Previous, ... 
    local found_previous_pos = false
    local previous_pos = mark_positions[mark_positions_size] -- Initialize previous position to be the last pos.
    for i, mark_position in ipairs(mark_positions) do
      if tonumber(current_pos) < tonumber(mark_position) then
        mp.commandv("seek", previous_pos, "absolute", "exact")
        found_previous_pos = true
        local warn_msg = string.format("Back to %d => %s.", previous_pos, toTimeFormat(previous_pos))
        mp.msg.warn(warn_msg)        
        break
      else
        previous_pos = mark_position
      end
    end
  
    -- 'Make it goes around logic' here: If previous pos not found, then goes to the last pos.
    if ( not found_previous_pos ) then
      previous_pos = mark_positions[mark_positions_size]
      mp.commandv("seek", previous_pos, "absolute", "exact")
      local warn_msg = string.format("WARN: No more previous marked position. Back to the last position at %s.", toTimeFormat(previous_pos))
      mp.msg.warn(warn_msg)
    end
    
  end

end

-- Mark position but discard fraction of second.
function mark_position()
  local current_position = math.floor(mp.get_property("time-pos"))
  tmsu_tag(mark_tag, current_position, file_name_for_cmd)
end


-- Return a string of formatted marked positions.
--  Marked positions formatted as HH:MM:SS, HH:MM:SS, HH:MM:SS
function get_formatted_mark_positions()
  local mark_positions = get_mark_positions()
  for i, mark_position in ipairs(mark_positions) do
    mark_positions[i] = toTimeFormat(mark_position)
  end
  
  return table.concat(mark_positions, ", ")
end

-- Return seconds formatted as HH:MM:SS
function toTimeFormat(seconds)
  return string.format("%.2d:%.2d:%.2d", seconds/(60*60), seconds/60%60, seconds%60)
end

-- Return marked positions in ascending order
function get_mark_positions()

  local raw_tags = tmsu_get_tags()
  
  local mark_tag_label = mark_tag .."="
  local i = 1
  local mark_position_values = {}
	for token in string.gmatch(raw_tags, "%S+") do
		if string.starts(token, mark_tag_label) then
			mark_position_values[i]=string.gsub(token, mark_tag_label, "")
      i = i + 1
		end
	end

  table.sort(mark_position_values, function(a,b) return tonumber(a)<tonumber(b) end)  
  return mark_position_values
end





-- Decrement the previous likes number by 1.
function decrement_likes()

	local likes_number = get_likes_number()
	
	if(likes_number=="") then
		likes_number = 0
	else
    --Remove current 'likes=xxx' tag number.
    tmsu_untag(likes_tag, likes_number, file_name_for_cmd)		
	end	
	
	--Decrement the number of likes: tmsu tag --tags likes=123 <filename>
	likes_number = likes_number - 1
  tmsu_tag(likes_tag, likes_number, file_name_for_cmd)
  mp.msg.info(string.format("INFO: Decreased likes to %d.", likes_number))	
	
end

-- Reset likes number to 0.
function reset_likes()

	local likes_number = get_likes_number()
	
	if(likes_number=="") then
		likes_number = 0
	else  
		--Remove 'likes=xxx' tag: tmsu untag --tags="likes" <filename>
		local cmd_untag_likes = string.format("tmsu untag --tags=\"%s=%s\" %s", likes_tag, likes_number, file_name_for_cmd)
		execute_command(cmd_untag_likes)
	end	
	
	--Set the number of likes to zero: tmsu tag --tags likes=0 <filename>
	likes_number = 0
	local cmd_inc_likes_number = string.format("tmsu tag --tags=\"%s=%s\" %s", likes_tag, likes_number, file_name_for_cmd)
	print(cmd_inc_likes_number)
	execute_command(cmd_inc_likes_number)
	
end

-- Print information about this file.
function print_stats()
	print("-----------------------------------------------------------")
	print("  Filename: " .. get_file_path())
	print("     Likes: " .. get_likes_number())
	print("      Tags: " .. get_tags())
  print("Marked Pos: " .. get_formatted_mark_positions())
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
mp.add_key_binding("Alt+t", "top_favorites", print_top_favorites)
mp.add_key_binding("Alt+i", "show_statistics", print_stats)
mp.add_key_binding("Alt+m", "mark_position", mark_position)
mp.add_key_binding("Alt+n", "goto_next_mark_position", goto_next_mark_position)
mp.add_key_binding("Alt+b", "goto_previous_mark_position", goto_previous_mark_position)
mp.add_key_binding("Alt+v", "delete_previous_mark_position", delete_previous_mark_position)

mp.register_event("file-loaded", on_file_loaded_init)
