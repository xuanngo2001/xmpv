# DESCRIPTION
  `xmpv.lua` is an extension of **MPV** that integrates with **TMSU** to provide the following features:
  
    * Tag files that you liked.
    * Display your favorite files.
    * Mark time position.
    * Play next marked time position.
    * Play previous marked time position.
    * Delete previous marked time position.

# USAGE
  * Hot keys:
    * Alt+l: Increment likes.
    * Alt+d: Decrement likes.
    * Alt+r: Reset likes to zero.
    * Alt+i: Print info.
    * Alt+t: Print top favorites files.
    * Alt+m: Mark time position.
    * Alt+n: Play next marked time position.
    * Alt+b: Play previous marked time position.
    * Alt+v: Delete previous marked time position.  

# INSTALL
  This script should be copied to `~/.config/mpv/scripts/` directory.

# REFERENCE: 
  * http://bamos.github.io/2014/07/05/mpv-lua-scripting/
  * https://github.com/mpv-player/mpv/blob/master/DOCS/man/lua.rst
  * https://github.com/mpv-player/mpv/blob/master/DOCS/man/input.rst
  * `mpv --list-properties` lists all properties available.