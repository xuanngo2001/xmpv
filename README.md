
# DESCRIPTION
`xmpv` is a set of Lua scripts for `mpv` media player that uses `TMSU` to provide the following extra features:
  
  * Tag files that you like.
  * Display your top favorite files.
  * Mark play position.
  * Play next marked position.
  * Play previous marked position.
  * Delete previous marked position.
  * Export marked positions to a file.

# INSTALL

## Requirements
* `mpv`: A media player. 
  * http://mpv.io/
* `TMSU`: A tool for tagging files. 
  * http://tmsu.org/
  
## Install
Copy `xmpv.lua` and `xmpv-*.lua` to `scripts` directory of `mpv`:

    # In Linux
    cp xmpv.lua   ~/.config/mpv/scripts/
    cp xmpv-*.lua ~/.config/mpv/scripts/
    
    :: In Windows
    copy /Y xmpv.lua   %APPDATA%\mpv\scripts\
    copy /Y xmpv-*.lua %APPDATA%\mpv\scripts\


# USAGE
* Run your `mpv` as usual but now you have the following extra hot keys:
  * `Alt+l`: Increment likes.
  * `Alt+d`: Decrement likes.
  * `Alt+r`: Reset likes to zero.
  * `Alt+i`: Print information of current playing file.
  * `Alt+t`: Print top favorite files.
  * `Alt+m`: Mark position.
  * `Alt+n`: Play next marked position.
  * `Alt+b`: Play previous marked position.
  * `Alt+x`: Delete previous marked position.
  * `Alt+e`: Export marked positions to a file.

**Note**: If there is a conflicting hot key, then use the alternative binding key: simply **also** press the `Shift` key. 

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
* Text formatting example: https://github.com/Argon-/mpv-stats
* http://docs.aegisub.org/3.2/ASS_Tags/
* http://www.linuxquestions.org/questions/slackware-14/mplayer-shows-question-marks-for-some-characters-on-subtitle-works-fine-on-xine-906077/
* http://boards.4chan.org/g/thread/47352550/mpv-mpv-general
* https://github.com/lvml/mpv-plugin-excerpt (Begin & end markers)
* https://raw.githubusercontent.com/mpv-player/mpv/master/TOOLS/lua/autoload.lua  (Append to playlist)

# TODO: 
* Queue
* Playlist

