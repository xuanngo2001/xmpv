--[[
<readme>

# DESCRIPTION
`xmpv` is a set of Lua scripts for **MPV** media player that uses **TMSU** to provide the following extra features:
  
  * Tag files that you like.
  * Display your top favorite files.
  * Mark time position.
  * Play next marked time position.
  * Play previous marked time position.
  * Delete previous marked time position.
  * Export marked time positions to a file.

# INSTALL

## Requirements
* MPV: A media player. 
  * http://mpv.io/
* TMSU: A tool for tagging files. 
  * http://tmsu.org/
  
## Install
Copy `xmpv.lua` and `xmpv-*.lua` to `scripts` directory of MPV:

    # In Linux
    cp xmpv.lua   ~/.config/mpv/scripts/
    cp xmpv-*.lua ~/.config/mpv/scripts/
    
    :: In Windows
    copy /Y xmpv.lua   %APPDATA%\mpv\scripts\
    copy /Y xmpv-*.lua %APPDATA%\mpv\scripts\


# USAGE
* Run your **MPV** as usual but now you have the following extra hot keys:
  * `Alt+l`: Increment likes.
  * `Alt+d`: Decrement likes.
  * `Alt+r`: Reset likes to zero.
  * `Alt+i`: Print information of current playing file.
  * `Alt+t`: Print top favorite files.
  * `Alt+m`: Mark time position.
  * `Alt+n`: Play next marked time position.
  * `Alt+b`: Play previous marked time position.
  * `Alt+x`: Delete previous marked time position.
  * `Alt+e`: Export marked time positions to a file.

* Alternate key bindings:
  * `Alt+Shift+t`: Print top favorite files.
  * `Alt+Shift+e`: Export marked time positions to a file.


# EXAMPLES:

    [xmpv]   File: some_music_file_name.mp3
    [xmpv]  Likes: 14
    [xmpv]   Tags: funky, music
    [xmpv] Marked
    [xmpv]    00:00:07, 00:00:08, 00:00:15, 00:00:19


    [xmpv] TOP FAVORITES
    [xmpv] [  37] ./00 file name& weird.mp3
    [xmpv] [  35] ./00 10sec.mp3
    [xmpv] [  27] ./00 10sec222222222.mp3
    [xmpv] [  20] ./00 09_30secd.mp3
    [xmpv] [  14] ./some_music_file_name.mp3
    
    

# REFERENCE: 
* https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst
* https://github.com/mpv-player/mpv/blob/master/DOCS/man/input.rst (also, search for 'osd-ass-cc')
* `mpv --list-properties` lists all properties available.
* Sample lua scripts: https://github.com/mpv-player/mpv/wiki/User-Scripts
* http://docs.aegisub.org/3.2/ASS_Tags/
* http://www.linuxquestions.org/questions/slackware-14/mplayer-shows-question-marks-for-some-characters-on-subtitle-works-fine-on-xine-906077/
* http://boards.4chan.org/g/thread/47352550/mpv-mpv-general
* https://github.com/lvml/mpv-plugin-excerpt (Begin & end markers)
* https://raw.githubusercontent.com/mpv-player/mpv/master/TOOLS/lua/autoload.lua  (Append to playlist)

# TODO: 
* Queue
* Playlist
</readme>

DUMP
mp.set_property("loop-file", "inf")
mp.set_property("options/keep-open","yes")
mp.set_property("options/keep-open","always")
mp.register_event("eof-reached", function)
mp.commandv("seek", 0.0, "absolute", "exact")
mp.set_property("time-pos", tostring(pos))   ->Seek
mp.set_property("pause", 'yes')
mp.command('quit') 
]]--


require 'os'
require 'io'
require 'string'
require 'mp'

require 'xmpv-utils'
require 'xmpv-tmsu'
require 'xmpv-likes'
require 'xmpv-mark'
require 'xmpv-stats'
require 'xmpv-playlist'

local start_time = 0

-- On "file-loaded", this function will run.
function on_file_loaded_init()
  
  start_time = mp.get_time() -- Reset start for every new file loaded.
  file_name_for_cmd = string.format('%q', mp.get_property("path")) -- file path with double quote escaped.
  
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
  function export_mark_position         () mark:export() end
  
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
  mp.add_key_binding("Alt+e", "export_mark_position", export_mark_position) 
  
  -- Alternative keys
  mp.add_key_binding("Alt+Shift+e", "export_mark_position", export_mark_position)
  mp.add_key_binding("Alt+Shift+t", "top_favorites", print_top_favorites)
  
end

mp.register_event("file-loaded", on_file_loaded_init)

-- *********************************************************
--  HOOKS
-- *********************************************************

-- Auto increment likes if played for more than half.
--  Discard short media file.
function auto_increment_likes(length, file_name_for_cmd)
  local length_in_secs = math.floor(length)  -- Discard fraction of seconds.
  if(tonumber(length_in_secs)>8) then  -- Discard short media file.
    local threshold_position = length_in_secs/2
    local time_elapsed = mp.get_time()-start_time
    if(tonumber(time_elapsed)>tonumber(threshold_position)) then
      local likes = Likes:new(nil, file_name_for_cmd)
      likes:increment()
    end
  end
end

-- Log date, time and position played.
function log_played(file_name_for_cmd)
  local playlist = Playlist:new(nil, file_name_for_cmd)
  playlist:log_played()
end

-- Run the followings when file is unloaded.
function on_unload_main()
  local length_in_string = mp.get_property_number("length")
  if(length_in_string~=nil) then  -- Process only playable file.
  
    local file_name_for_cmd = string.format('%q', mp.get_property("path")) -- file path with double quote escaped.
    auto_increment_likes(length_in_string, file_name_for_cmd)
    log_played(file_name_for_cmd)
    
  end 
  
end

mp.add_hook("on_unload", 50, on_unload_main)

