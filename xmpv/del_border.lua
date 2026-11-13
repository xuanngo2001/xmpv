local utils = require("mp.utils")
local border_overlay = mp.create_osd_overlay("ass-events")
local msg_overlay = mp.create_osd_overlay("ass-events")
local msg_timer = nil

local function clear_colored_osd()
    if msg_timer then
        msg_timer:kill()
        msg_timer = nil
    end
    msg_overlay:remove()
end

local function show_colored_osd(text, bgr_hex, duration)
    clear_colored_osd()

    -- Top-left aligned (\an7) at (25, 75) with bold text (\b1) and custom BGR color
    -- Changed \pos(25,25) to \pos(25,75) to lower the text by 50 pixels
    msg_overlay.data = string.format(
        "{\\an7\\pos(25,75)\\fs28\\b1\\bord2\\1c&H%s&\\3c&H000000&}%s",
        bgr_hex,
        text
    )
    msg_overlay:update()

    msg_timer = mp.add_timeout(duration, function()
        msg_overlay:remove()
        msg_timer = nil
    end)
end

-- Safely wrap any file path in POSIX single quotes (handles spaces, $, `, ", and ')
local function shell_quote(str)
    return "'" .. str:gsub("'", "'\\''") .. "'"
end

local function get_video_and_del_paths()
    local path = mp.get_property("path")
    if not path then
        return nil, nil
    end
    -- Skip URLs/streams where local marker files cannot be created
    if path:match("^[%a][%w%+%-%.]*://") then
        return nil, nil
    end

    -- Resolve to an absolute path so the .del script works from any working directory
    local wd = mp.get_property("working-directory") or ""
    local full_path = utils.join_path(wd, path)
    return full_path, full_path .. ".del"
end

local function update_border()
    local _, del_file = get_video_and_del_paths()
    if not del_file then
        border_overlay:remove()
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

        border_overlay.res_x = w
        border_overlay.res_y = h
        border_overlay.data = ass
        border_overlay:update()
    else
        border_overlay:remove()
    end
end

local function toggle_del_marker()
    local video_file, del_file = get_video_and_del_paths()
    if not del_file then
        show_colored_osd("Cannot mark streams for deletion", "00FFFF", 3)
        return
    end

    local info = utils.file_info(del_file)

    if info and info.is_file then
        local ok, err = os.remove(del_file)
        if ok then
            -- 00FF00 = Green in BGR format
            show_colored_osd("Removed .del marker", "00FF00", 3)
        else
            mp.msg.error("Failed to remove .del file: " .. tostring(err))
            show_colored_osd("Error removing .del marker", "0000FF", 3)
        end
    else
        local f, err = io.open(del_file, "w")
        if f then
            local script_content = string.format(
                "#!/usr/bin/env bash\nrm -fv -- %s\nrm -fv -- %s\n",
                shell_quote(video_file),
                shell_quote(del_file)
            )
            f:write(script_content)
            f:close()

            -- Make the .del file executable so it can be run directly
            os.execute("chmod +x -- " .. shell_quote(del_file))

            show_colored_osd("Marked for deletion (.del created)", "0000FF", 3)
        else
            mp.msg.error("Failed to create .del file: " .. tostring(err))
            show_colored_osd("Error creating .del marker", "0000FF", 3)
        end
    end

    update_border()
end

local function on_file_loaded()
    clear_colored_osd()
    update_border()
end

-- Clear any leftover message and update border when a new file loads
mp.register_event("file-loaded", on_file_loaded)
mp.register_event("end-file", clear_colored_osd)

-- Redraw if the window is resized
mp.observe_property("osd-width", "number", update_border)
mp.observe_property("osd-height", "number", update_border)

-- Press Ctrl+d to toggle the .del file and red border
mp.add_key_binding("Ctrl+d", "toggle-del-marker", toggle_del_marker)
