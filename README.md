

# DESCRIPTION
`xmpv` is a set of Lua scripts for **MPV** media player that uses **TMSU** to provide the following extra features:
  
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
Copy `xmpv.lua` and `xmpv-*.lua` to `scripts` directory of MPV:
```
# In Linux
cp xmpv.lua   ~/.config/mpv/scripts/
cp xmpv-*.lua ~/.config/mpv/scripts/
```

```
:: In Windows
copy /Y xmpv.lua   %APPDATA%\mpv\scripts\
copy /Y xmpv-*.lua %APPDATA%\mpv\scripts\
```

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


