--[[
Description:
-- This script displays information about the currently loaded file in mpv.
-- It shows the filename, path, and human-readable file size on the OSD.

Usage: 
    mpv --script-opts=xfile-info=yes "your_video_file.mp4"

mpv.conf:
    script-opts=xfile-info=yes

]]--

-- Function to get human-readable file size
local function get_readable_size(bytes)
    if not bytes or bytes == 0 then return "Unknown Size" end
    local units = {"B", "KB", "MB", "GB", "TB"}
    local i = 1
    while bytes > 1024 and i < #units do
        bytes = bytes / 1024
        i = i + 1
    end
    return string.format("%.2f %s", bytes, units[i])
end

-- Main function to display the information
local function show_file_info()
    local xshow = mp.get_opt("xshow")
    
    if xshow == "yes" then
        local filename = mp.get_property("filename", "Unknown")
        local path = mp.get_property("path", "Unknown")
        local bytes = tonumber(mp.get_property("file-size", "0"))
        local size = get_readable_size(bytes)

        -- ASS Style tags
        -- ${osd-ass-cc/0} tells mpv to stop escaping ASS code and render it
        -- \an7 = Top-left alignment
        -- \fs22 = Font size 22
        -- \b1 = Bold text
        local ass_enable   = "${osd-ass-cc/0}"
        local style_start  = "{\\an7}{\\fs22}{\\b1}"
        local label_style  = "{\\c&H33FF33&}" -- Green for labels
        local value_style  = "{\\c&HFFFFFF&}" -- White for data

        -- Format the message text with styles
        local message = string.format(
            "%s%s%sFile:%s %s\n%s%sPath:%s %s\n%s%sSize:%s %s", 
            ass_enable, style_start,
            label_style, value_style, filename,
            label_style, value_style, path,
            label_style, value_style, size
        )

        -- Display on screen for 3 seconds
        mp.osd_message(message, 3)
    end
end

-- Trigger the function automatically every time a new file finishes loading
mp.register_event("file-loaded", show_file_info)
