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
    -- Read the custom xshow parameter from script-opts
    local xshow = mp.get_opt("xfile-info")
    
    -- Only run if xshow equals "yes"
    if xshow == "yes" then
        local filename = mp.get_property("filename", "Unknown")
        local path = mp.get_property("path", "Unknown")
        local bytes = tonumber(mp.get_property("file-size", "0"))
        local size = get_readable_size(bytes)

        -- Format the message text
        local message = string.format(
            "File: %s\nPath: %s\nSize: %s", 
            filename, path, size
        )

        -- Display on screen for 3000 milliseconds (3 seconds)
        mp.osd_message(message, 3)
    end
end

-- Trigger the function automatically every time a new file finishes loading
mp.register_event("file-loaded", show_file_info)
