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

-- Main function to display the information
local function show_file_info()
    local xfile_info = mp.get_opt("xfile_info")
    
    if xfile_info == "yes" then
        local filename = mp.get_property("filename", "Unknown")
        local path = mp.get_property("path", "Unknown")
        local bytes = tonumber(mp.get_property("file-size", "0"))
        local size = get_readable_size(bytes)

        -- ASS Style tags
        -- Positioning: Change \an7 to experiment with placement
        -- Padding/Margin: \pos(20,20) nudges the text 50px from top and 20px from left
        local position_style = "{\\an7}{\\pos(20,50)}"
        
        -- Text Properties: \fs20 = Font size 20, \b1 = Bold
        local text_style     = "{\\fs20}{\\b1}"
        
        -- Bounding Box: \bord4 = 4px thick border, \3c&H111111& = Dark grey/black box background
        -- \shad0 = Disable text shadow so it doesn't clip into our box
        local box_style      = "{\\bord4}{\\3c&H111111&}{\\shad0}"
        
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

        -- Hide the overlay automatically after 3 seconds
        mp.add_timeout(5.0, function()
            overlay:remove()
        end)
    end
end

mp.register_event("file-loaded", show_file_info)
