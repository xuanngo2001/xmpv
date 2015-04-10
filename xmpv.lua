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
  * `Alt+x`: Delete previous marked time position.  

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
require 'mp'

local home_dir = os.getenv ("HOME")
dofile(home_dir .. "/.config/mpv/scripts/xmpv-utils.lua")
dofile(home_dir .. "/.config/mpv/scripts/xmpv-tmsu.lua")
dofile(home_dir .. "/.config/mpv/scripts/xmpv-likes.lua")
dofile(home_dir .. "/.config/mpv/scripts/xmpv-mark.lua")
dofile(home_dir .. "/.config/mpv/scripts/xmpv-stats.lua")

likes_tag = "xlikes"
mark_tag  = "xmark"

file_name_for_cmd = ""




  

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

-- Return sanitized file path for command line execution
--  string.format('%q', 'a string with "quotes"') => "a string with \"quotes\""
function get_file_name_for_cmd(filename)
  local filename = get_file_path()
  
  --Escape double quotes.
  filename = string.format('%q', filename)
  return filename
end


-- On "file-loaded", this function will run.
function on_file_loaded_init()

	file_name_for_cmd = get_file_name_for_cmd()
	
  tmsu = Tmsu:new()
  mark = Mark:new(nil, file_name_for_cmd)
  likes = Likes:new(nil, file_name_for_cmd)
  stats = Stats:new(nil, file_name_for_cmd)
	
	tmsu:exists()
	

  
  -- Binding functions
  -- ******************************
  -- Likes
  function increment_likes    () likes:increment() end
  function decrement_likes    () likes:decrement() end
  function reset_likes        () likes:reset()  end
  function print_top_favorites() likes:print_top_favorites()end
  
  -- Mark
  function mark_position                () mark:mark_position() end
  function goto_next_mark_position      () mark:goto_next_position() end
  function goto_previous_mark_position  () mark:goto_previous_position() end
  function delete_previous_mark_position() mark:delete_previous_position() end
  
  -- Stats
  function print_stats() stats:print() end
  
  -- Set binding keys
  mp.add_key_binding("Alt+l", "increment_likes", increment_likes)
  mp.add_key_binding("Alt+d", "decrement_likes", decrement_likes)
  mp.add_key_binding("Alt+r", "reset_likes", reset_likes)
  mp.add_key_binding("Alt+t", "top_favorites", print_top_favorites)
  mp.add_key_binding("Alt+i", "show_statistics", print_stats)
  mp.add_key_binding("Alt+m", "mark_position", mark_position)
  mp.add_key_binding("Alt+n", "goto_next_mark_position", goto_next_mark_position)
  mp.add_key_binding("Alt+b", "goto_previous_mark_position", goto_previous_mark_position)
  mp.add_key_binding("Alt+x", "delete_previous_mark_position", delete_previous_mark_position) -- Key should be far away from the others to prevent accidental deletes.


  -- Auto increment the number of likes, when playback has elapsed
  --  for more than half.
  mp.add_timeout((get_length()/2), increment_likes)
  
end


mp.register_event("file-loaded", on_file_loaded_init)  

