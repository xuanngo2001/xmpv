-----------------------------------------------------------------------------
-- ASS tag class: http://docs.aegisub.org/latest/ASS_Tags/ 
--  -Simplify display of ASS tag. 
-----------------------------------------------------------------------------
Asst = {
}

-- 'Constructor'
function Asst:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  return o
end

-- -------------------------------- --
-- FUNCTIONS --
-- -------------------------------- --

-- Enable ASS tag by returning on code. 
function Asst:on()
  return mp.get_property("osd-ass-cc/0")
end

-- Disable ASS tag by returning off code. 
function Asst:off()
  return mp.get_property("osd-ass-cc/1")
end