-----------------------------------------------------------------------------
-- Msg class. 
-- 
-- Note:
--  con_text = Display text in console.
-----------------------------------------------------------------------------

-- ***** Variables *****
Msg = {
  duration = 1,
  error_duration = 5, -- Default display duration = 5 seconds.
}

-- 'Constructor'
function Msg:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  
  return o
end

function Msg:print(osd_text)
  mp.osd_message(osd_text, self.duration)
end

-- Logic:
--  info(text)         -> Display same text on console and on OSD.
--  info(nil, text)    -> Display only on OSD.
--  info(text1, text2) -> Display text1 on console and text2 on OSD.
function Msg:info(con_text, osd_text)
  
  if(con_text~=nil) then
    mp.msg.info("INFO: " .. con_text)
  end

  if(osd_text==nil) then
    mp.osd_message("INFO: " .. con_text, self.duration)
  else
    mp.osd_message(osd_text, self.duration)    
  end
  
end

function Msg:warn(con_text, osd_text)
  
  if(con_text~=nil) then
    mp.msg.warn("WARN: " .. con_text)
  end

  if(osd_text==nil) then
    mp.osd_message("WARN: " .. con_text, self.duration)
  else
    mp.osd_message(osd_text, self.duration)    
  end
  
end

function Msg:error(con_text, osd_text)
  
  if(con_text~=nil) then
    mp.msg.error("ERROR: " .. con_text)
  end

  if(osd_text==nil) then
    mp.osd_message("ERROR: " .. con_text, self.error_duration)
  else
    mp.osd_message(osd_text, self.error_duration)    
  end
  
end


