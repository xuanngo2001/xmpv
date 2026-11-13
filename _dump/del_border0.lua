-- Description: On file loaded, check if there a <playing video file>.del exists, add red border.

local utils = require("mp.utils")
local overlay = mp.create_osd_overlay("ass-events")

local function update_border()
    local path = mp.get_property("path")
    if not path then
        overlay:remove()
        return
    end

    -- Check if "<video_path>.del" exists (e.g., "video.mp4.del")
    local del_file = path .. ".del"
    local info = utils.file_info(del_file)

    if info and info.is_file then
        local w, h = mp.get_osd_size()
        if not w or w == 0 or not h or h == 0 then
            return
        end

        local thickness = 10 -- Border thickness in pixels
        local t = thickness / 2

        -- Draw a hollow red rectangle along the screen edges using ASS vector drawing
        -- Note: ASS colors use &HBBGGRR& format (0000FF = pure red)
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

-- Run when a file loads
mp.register_event("file-loaded", update_border)

-- Redraw if the window is resized so the border stays aligned
mp.observe_property("osd-width", "number", update_border)
mp.observe_property("osd-height", "number", update_border)
