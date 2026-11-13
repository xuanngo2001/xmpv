-- Press Ctrl+d to toggle the .del file and red border
local utils = require("mp.utils")
local overlay = mp.create_osd_overlay("ass-events")

local function get_del_path()
    local path = mp.get_property("path")
    if not path then
        return nil
    end
    -- Skip URLs/streams where local marker files cannot be created
    if path:match("^[%a][%w%+%-%.]*://") then
        return nil
    end
    return path .. ".del"
end

local function update_border()
    local del_file = get_del_path()
    if not del_file then
        overlay:remove()
        return
    end

    local info = utils.file_info(del_file)

    if info and info.is_file then
        local w, h = mp.get_osd_size()
        if not w or w == 0 or not h or h == 0 then
            return
        end

        local thickness = 10 -- Border thickness in pixels
        local t = thickness / 2

        -- Draw a hollow red rectangle along the screen edges
        local ass = string.format(
            "{\\an7\\pos(0,0)\\bord%d\\3c&H0000FF&\\3a&H00&\\1a&HFF&\\p1}m %d %d l %d %d %d %d %d %d",
            thickness,
            t, t,
            w - t, t,
            w - t, h - t,
            t, h - t
        )

        overlay.res_x = w
        overlay.res_y = h
        overlay.data = ass
        overlay:update()
    else
        overlay:remove()
    end
end

local function toggle_del_marker()
    local del_file = get_del_path()
    if not del_file then
        mp.osd_message("Cannot mark streams for deletion")
        return
    end

    local info = utils.file_info(del_file)

    if info and info.is_file then
        local ok, err = os.remove(del_file)
        if ok then
            mp.osd_message("Removed .del marker")
        else
            mp.msg.error("Failed to remove .del file: " .. tostring(err))
            mp.osd_message("Error removing .del marker")
        end
    else
        local f, err = io.open(del_file, "w")
        if f then
            f:close()
            mp.osd_message("Marked for deletion (.del created)")
        else
            mp.msg.error("Failed to create .del file: " .. tostring(err))
            mp.osd_message("Error creating .del marker")
        end
    end

    update_border()
end

-- Run when a file loads
mp.register_event("file-loaded", update_border)

-- Redraw if the window is resized
mp.observe_property("osd-width", "number", update_border)
mp.observe_property("osd-height", "number", update_border)

-- Press Ctrl+d to toggle the .del file and red border
mp.add_key_binding("Ctrl+d", "toggle-del-marker", toggle_del_marker)
