-----------------------------------------------------------------------------
-- Msg class. 
-----------------------------------------------------------------------------

-- ***** Variables *****
Msg = {
  duration = 1,
}

-- 'Constructor'
function Msg:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  return o
end

function Msg:print(con_text, osd_text)
  
  if(con_text~=nil) then
    mp.msg.info(con_text)
  end

  if(osd_text~=nil) then
    mp.osd_message(osd_text, self.duration)
  end
  
end

