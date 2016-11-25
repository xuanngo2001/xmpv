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
-- BASIC FUNCTIONS --
-- -------------------------------- --

function Asst:on()  return mp.get_property("osd-ass-cc/0") end
function Asst:off() return mp.get_property("osd-ass-cc/1") end

function Asst:reset() return "{\\r}" end

function Asst:underline_o() return "{\\u1}" end
function Asst:underline_f() return "{\\u0}" end

function Asst:font_size(fs) return "{\\fs" .. fs .. "}" end

-- -------------------------------- --
-- BIGGER FUNCTIONS --
-- -------------------------------- --
function Asst:long_text(text)
  return string.format("%s%s%s%s%s", self:on(), 
                                       self:font_size(12), 
                                        text, 
                                       self:reset(), 
                                     self:off()
                      )
end