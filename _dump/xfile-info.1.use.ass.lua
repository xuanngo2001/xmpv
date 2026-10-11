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
        -- \an7 = Top-left alignment
        -- \fs22 = Font size 22
        -- \b1 = Bold text
        local style_start  = "{\\an7}{\\fs22}{\\b1}"
        local label_style  = "{\\c&H33FF33&}" -- Green for labels
        local value_style  = "{\\c&HFFFFFF&}" -- White for data

        -- Build the layout text
        overlay.data = style_start ..
            label_style .. "File: " .. value_style .. filename .. "\\N" ..
            label_style .. "Path: " .. value_style .. path .. "\\N" ..
            label_style .. "Size: " .. value_style .. size

        -- Render the overlay onto the screen
        overlay:update()

        -- Hide the overlay automatically after 3 seconds (3000 milliseconds)
        mp.add_timeout(3.0, function()
            overlay:remove()
        end)
    end
end

mp.register_event("file-loaded", show_file_info)
