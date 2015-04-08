# DESCRIPTION
`xmpv.lua` is an extension of **MPV** that integrates with **TMSU** to provide the following features:
  
  * Tag files that you like.
  * Display your top favorite files.
  * Mark time position.
  * Play next marked time position.
  * Play previous marked time position.
  * Delete previous marked time position.

# INSTALL
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



# REFERENCE: 
* https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst
* https://github.com/mpv-player/mpv/blob/master/DOCS/man/input.rst
* `mpv --list-properties` lists all properties available.

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