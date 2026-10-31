-----------------------------------------------------------------------------
-- xJson class will manipulate TMSU application. 
-----------------------------------------------------------------------------
local home = os.getenv("HOME")
package.path = package.path .. ';' .. home .. '/.config/mpv/scripts/?.lua'
--package.path = package.path .. ';' .. 'C:\\xuan\\soft-bin\\mpv-x86_64-20200419-git-a09c769\\portable_config\\scripts\\?.lua'

require 'xmpv-utils'
require 'xmpv-msg'

local json = require("json") -- Assumes a standard JSON library is available

--- Marks a playback position in a sidecar json file (<video filename>.xmpv.json).
-- Creates the JSON file and the 'positions' array if they do not exist.
-- Appends the position only if it's unique.
-- @param position The position to store (number, string, or table)
-- @param file_path The original video file path
function mark(position, file_path)
    local json_path = file_path .. ".xmpv.json"
    local data = { positions = {} }

    -- 1. Try to read and parse the existing file
    local file = io.open(json_path, "r")
    if file then
        local content = file:read("*a")
        file:close()
        
        if content and content ~= "" then
            local status, parsed_data = pcall(json.decode, content)
            if status and type(parsed_data) == "table" then
                data = parsed_data
                if type(data.positions) ~= "table" then
                    data.positions = {}
                end
            end
        end
    end

    -- 2. Check if the position is already present in the array
    local exists = false
    for _, val in ipairs(data.positions) do
        if val == position then
            exists = true
            break
        end
    end

    -- 3. If unique, append and write the updated table back to the file
    if not exists then
        table.insert(data.positions, position)
        
        local write_file = io.open(json_path, "w")
        if write_file then
            write_file:write(json.encode(data))
            write_file:close()
        end
    end
end


