--[[
Description:
-- This script displays information about the currently loaded file in mpv.
-- It shows the filename, path, and human-readable file size on the OSD.

Usage: 
    mpv --script-opts=xfile_info=yes "your_video_file.mp4"

mpv.conf:
    script-opts=xfile_info=yes

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

-- Initialize the OSD overlay layer
local overlay = mp.create_osd_overlay("ass-events")

-- Create a persistent variable to keep track of our active timer
local active_timer = nil

-- Main function to display the information
local function show_file_info()
    local xfile_info = mp.get_opt("xfile_info")
    
    if xfile_info == "yes" then
        -- CRITICAL FIX: If a timer is already running from the previous video, kill it immediately
        if active_timer then
            active_timer:kill()
            active_timer = nil
        end

        local filename = mp.get_property("filename", "Unknown")
        local path = mp.get_property("path", "Unknown")
        local bytes = tonumber(mp.get_property("file-size", "0"))
        local size = get_readable_size(bytes)

        -- ASS Style tags
        local position_style = "{\\an1}{\\pos(20, 640)}" 
        local text_style     = "{\\fs18}{\\b1}"
        local box_style      = "{\\bord5}{\\3c&H111111&}{\\shad0}"
        
        -- Text Colors
        local label_style    = "{\\c&H33FF33&}" -- Green for labels
        local value_style    = "{\\c&HFFFFFF&}" -- White for data

        -- Combine styles into a single block
        local style_header = position_style .. text_style .. box_style

        -- Build the layout text
        overlay.data = style_header ..
            label_style .. "File: " .. value_style .. filename .. "\\N" ..
            style_header .. label_style .. "Path: " .. value_style .. path .. "\\N" ..
            style_header .. label_style .. "Size: " .. value_style .. size

        -- Render the overlay onto the screen
        overlay:update()

        -- Assign the countdown to our persistent variable
        active_timer = mp.add_timeout(3.0, function()
            overlay:remove()
            active_timer = nil -- Reset tracker once it finishes cleanly
        end)
    end
end

mp.register_event("file-loaded", show_file_info)

