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
    local xshow = mp.get_opt("xshow")
    
    if xshow == "yes" then
        local filename = mp.get_property("filename", "Unknown")
        local path = mp.get_property("path", "Unknown")
        local bytes = tonumber(mp.get_property("file-size", "0"))
        local size = get_readable_size(bytes)

        -- ASS Style tags
        -- Positioning: \an1 = Anchored at the Bottom-Left
        -- \pos(30, 950) = 30px from the left, 950px from the top.
        -- Note: If your video window is smaller/larger, mpv automatically scales this ASS canvas coordinate base (typically 1280x720 or 1920x1080 default sizing scale).
        -- To make it fit perfectly above or below the play bar, we position it using bottom anchor rules.
        local position_style = "{\\an1}{\\pos(20, 640)}" -- Raised up from the absolute bottom (assuming default 720p base canvas layout)
        
        -- Text Properties
        local text_style     = "{\\fs18}{\\b1}"
        
        -- Bounding Box: Opaque background padding box
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

        -- Hide the overlay automatically after 3 seconds
        mp.add_timeout(3.0, function()
            overlay:remove()
        end)
    end
end

mp.register_event("file-loaded", show_file_info)
