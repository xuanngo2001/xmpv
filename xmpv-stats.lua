-----------------------------------------------------------------------------
-- Stats class. 
-----------------------------------------------------------------------------

-- ***** Variables *****
Stats = {
  file_path="",  
}

-- 'Constructor'
function Stats:new(o, file_path)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  self.file_path = file_path
  return o
end


