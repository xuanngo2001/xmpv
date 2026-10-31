-----------------------------------------------------------------------------
-- Json class for `<video filename>.xmpv.json`.
--
-- File format:
--   {"positions": [10, 25, 60]}
-----------------------------------------------------------------------------
local utils = require 'mp.utils'

-- ***** Variables *****
Json = {
  EXTENSION = ".xmpv.json",
}

-- 'Constructor'
function Json:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self

  return o
end

-- Return json file path of video, or nil if file_path is empty.
function Json:get_json_path(file_path)
  if file_path == nil or file_path == "" then
    return nil
  end
  return file_path .. self.EXTENSION
end

-- Read json file. Return table, or nil and error message.
-- A missing or empty file returns an empty table.
function Json:read_json(json_path)
  local file = io.open(json_path, "r")
  if file == nil then
    return {} -- File does not exist yet.
  end

  local ok, content = pcall(file.read, file, "*a")
  file:close()
  if not ok then
    return nil, "read_json: cannot read " .. json_path .. ": " .. tostring(content)
  end

  if content == nil or content:match("^%s*$") then
    return {}
  end

  local data = utils.parse_json(content)
  if type(data) ~= "table" then
    return nil, "read_json: invalid JSON in " .. json_path
  end
  return data
end

-- Write table to json file. Return true, or nil and error message.
function Json:write_json(json_path, data)
  local content, format_err = utils.format_json(data)
  if content == nil then
    return nil, "write_json: cannot format JSON: " .. tostring(format_err)
  end

  local file, open_err = io.open(json_path, "w")
  if file == nil then
    return nil, "write_json: cannot open " .. json_path .. ": " .. tostring(open_err)
  end

  local ok, write_err = pcall(file.write, file, content, "\n")
  file:close()
  if not ok then
    return nil, "write_json: cannot write " .. json_path .. ": " .. tostring(write_err)
  end
  return true
end

-- Return value of `key` in `<file_path>.xmpv.json`.
-- Return nil if key (or json file) does not exist.
-- On failure return nil and error message.
function Json:get_value(key, file_path)
  local json_path = self:get_json_path(file_path)
  if json_path == nil then
    local err = "get_value: file path is empty"
    print(err)
    return nil, err
  end

  local data, read_err = self:read_json(json_path)
  if data == nil then
    print(read_err)
    return nil, read_err
  end

  return data[key]
end

-- Set `key` to `value` in `<file_path>.xmpv.json`. Create json file if it does not exist.
-- A nil value removes the key.
-- Return true, or nil and error message on failure.
function Json:set_value(key, value, file_path)
  local json_path = self:get_json_path(file_path)
  if json_path == nil then
    local err = "set_value: file path is empty"
    print(err)
    return nil, err
  end

  local data, read_err = self:read_json(json_path)
  if data == nil then
    print(read_err)
    return nil, read_err
  end

  data[key] = value

  local ok, write_err = self:write_json(json_path, data)
  if not ok then
    print(write_err)
    return nil, write_err
  end
  return true
end

-- Return positions in ascending order from `<file_path>.xmpv.json`.
-- A missing json file returns an empty table.
-- On failure return nil and error message.
function Json:get_positions(file_path)
  local json_path = self:get_json_path(file_path)
  if json_path == nil then
    local err = "get_positions: file path is empty"
    print(err)
    return nil, err
  end

  local data, read_err = self:read_json(json_path)
  if data == nil then
    print(read_err)
    return nil, read_err
  end

  local positions = {}
  if type(data.positions) == "table" then
    for _, value in ipairs(data.positions) do
      local position = tonumber(value)
      if position ~= nil then
        table.insert(positions, position)
      end
    end
  end

  table.sort(positions)
  return positions
end

-- Remove position from `positions` array of `<file_path>.xmpv.json`.
-- Return true if position was removed, false if not present,
-- or nil and error message on failure.
function Json:unmark(position, file_path)
  position = tonumber(position)
  if position == nil then
    local err = "unmark: invalid position"
    print(err)
    return nil, err
  end

  local json_path = self:get_json_path(file_path)
  if json_path == nil then
    local err = "unmark: file path is empty"
    print(err)
    return nil, err
  end

  local data, read_err = self:read_json(json_path)
  if data == nil then
    print(read_err)
    return nil, read_err
  end

  if type(data.positions) ~= "table" then
    return false
  end

  local kept = {}
  for _, existing in ipairs(data.positions) do
    if tonumber(existing) ~= position then
      table.insert(kept, existing)
    end
  end

  if #kept == #data.positions then
    return false
  end
  data.positions = kept

  local ok, write_err = self:write_json(json_path, data)
  if not ok then
    print(write_err)
    return nil, write_err
  end
  return true
end

-- Mark position in `positions` array of `<file_path>.xmpv.json`
-- if position is not already present. Create json file if it does not exist.
-- Return true if position was added, false if already present,
-- or nil and error message on failure.
function Json:mark(position, file_path)
  position = tonumber(position)
  if position == nil then
    local err = "mark: invalid position"
    print(err)
    return nil, err
  end

  local json_path = self:get_json_path(file_path)
  if json_path == nil then
    local err = "mark: file path is empty"
    print(err)
    return nil, err
  end

  local data, read_err = self:read_json(json_path)
  if data == nil then
    print(read_err)
    return nil, read_err
  end

  if type(data.positions) ~= "table" then
    data.positions = {}
  end

  for _, existing in ipairs(data.positions) do
    if tonumber(existing) == position then
      return false
    end
  end

  table.insert(data.positions, position)
  table.sort(data.positions, function(a, b) return tonumber(a) < tonumber(b) end)

  local ok, write_err = self:write_json(json_path, data)
  if not ok then
    print(write_err)
    return nil, write_err
  end
  return true
end
