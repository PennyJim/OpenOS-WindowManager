Vector2 = require("./CustomUI/Vector2")
BoxElement = require("./CustomUI/Elements/BoxElement")
Artist = require("./CustomUI/Artist")

---@class Textbox: BoxElement
---@field __call fun(self:Textbox,x:integer,y:integer,w:integer,h:integer,bg:Color?,fg:Color?,defaultText:string?,defaultTextColor:Color?):Textbox
---@field defaultText string?
---@field defaultColor Color?
---@field text string
---@field cursorOffset integer
---@field textOffset integer
---@field flickerTime number
local Textbox = BoxElement:new{}
---Constructor
---@param x integer
---@param y integer
---@param w integer
---@param bg Color?
---@param fg Color?
---@param defaultText string?
---@param defaultColor Color?
---@return Textbox
function Textbox:construct(x, y, w, bg, fg, defaultText, defaultColor)
  local newObj = BoxElement.construct(self, x, y, w, 3, bg, fg)
  newObj.defaultText = defaultText
  newObj.defaultColor = defaultColor
  newObj.text = ""
  newObj.cursorOffset = 0
  newObj.textOffset = 0
  newObj.type = "textbox"
  newObj.flickerTime = math.maxinteger
  return newObj
end
function Textbox._sanitize(x, y, w, bg, fg, defaultText, defaultColor)
  --Sanitize Input Types
  checkArg(1, x, "number")
  checkArg(2, y, "number")
  checkArg(3, w, "number")
  checkArg(4, bg, "number", "nil")
  checkArg(5, fg, "number", "nil")
  checkArg(6, defaultText, "string", "nil")
  checkArg(7, defaultColor, "number", "nil")
  --Sanitize Inputs
  assert(w>=5, "#3 is too small (Expected at least 5, got"..w..")")
  if defaultText then
    assert(w>=#defaultText+2, "#3 is too small (Expected at least #6 + 2 ("..
      (#defaultText+2).."), got "..w..")")
  end
end

function Textbox:__call(...)
  self._sanitize(...)
  return self:construct(...)
end

function Textbox:_drawSelfBefore(gpu)
  -- Draw box
  gpu.fill(self.pos.x,self.pos.y,self.size.x,self.size.y, " ")
  Artist.border(gpu, self.pos, self.size)

  -- Draw internal text
  if #self.text > 0 then
    -- Draw text using textOffset
    local text = self.text:sub(1+self.textOffset, self.size.x-2+self.textOffset)
    gpu.set(self.pos.x+1, self.pos.y+1, text)

  -- Draw defaultText if exists
  elseif self.defaultText then
    -- Change color if defaultColor exists
    local oldColor = Artist.switchForeground(gpu, self.defaultColor)

    -- Draw defaultText
    gpu.set(self.pos.x+1, self.pos.y+1, self.defaultText)
    -- Revert color to not-break compatibility
    if oldColor then gpu.setForeground(oldColor) end
  end
end

---@param gpu GPU
function Textbox:drawCursor(gpu, clickState)
  -- Invert text cursor if flickerTime is 0-0.5 seconds
  -- os.time()/72 is seconds for some reason??
  local curFlicker = os.time() - self.flickerTime
  if curFlicker < 36 then
    local pos = self:_getAbsPos() + Vector2{self.cursorOffset+1, 1}
    -- Invert position
    local char, fg, bg = gpu.get(pos.x, pos.y)
    local oldBg, oldFg = Artist.switchColors(gpu, fg, bg)
    gpu.set(pos.x, pos.y, char)
    return oldBg, oldFg, false --I want it to still draw the normal cursor

  -- reset flickerTime if it's greater than 1 second
  -- Should result in toggling back and forth every second
  elseif curFlicker > 72 then self.flickerTime = os.time() end
end


---Move text window in that direction
---@param direction integer
function Textbox:_moveText(direction)
  -- Bound direction to -1 or 1 (or 0, but that does nothing)
  if direction < 0 then direction = -1
  elseif direction > 0 then direction = 1 end
  -- If text window already at bounds, do nothing
  if direction < 0 and self.textOffset == 0 or
    direction > 0 and self.textOffset >= #self.text - self.size.x + 3
  then return end
  -- update text window
  self.textOffset = self.textOffset+direction
  self.parentWindow:markRedraw()
end
---Move cursor to position
---@param xPos integer
function Textbox:_moveCursor(xPos)
  -- Bound to window and shift it left or right
  if xPos < 1 then 
    self:_moveText(-1)
    xPos = 1
  elseif xPos > self.size.x-2 then
    self:_moveText(1)
    xPos = self.size.x-2
  end
  self.cursorOffset = xPos-1
  self.flickerTime = os.time()

  -- Shift cursorOffset to the left if after string
  local biggestOffset = #self.text:sub(self.textOffset, -1)
  if self.cursorOffset > biggestOffset then
    self.cursorOffset = biggestOffset
  end
end

function Textbox:down(clickState, pos, button, user)
  -- If within text window, set cursorOffset
  -- pos - self.pos = [1,1] --> [0,0]
  local localPos = pos - self:_getAbsPos()
  if localPos.y == 1 and localPos.x ~= 0 or localPos.x ~= self.size.x-1 then
    self:_moveCursor(localPos.x)
    --Make self active element
    clickState.selectedElement = self
    return true
  end
  return false
end
function Textbox:drag(clickState, pos, button, user)
  -- Set cursorOffset to nearest point in text window
  -- And shift window if to the left or right
  self:_moveCursor((pos-self:_getAbsPos()).x)
  -- Old code, not useful if new `_moveCursor()` works
  -- local localPos = pos - self.pos -- [1,1] --> [0,0] because math
  -- if localPos.x < 1 then self:_moveCursor(1)
  -- elseif localPos.x > self.size.x-2 then self:_moveCursor(self.size.x-2)
  -- else self:_moveCursor(localPos.x) end
end
-- function TextBox:drop(clickState, pos, button, user)

-- end

-- TODO: make into a proper function when keyboard events are implemented
function Textbox:keyPress(key)
  local offset = self.textOffset+self.cursorOffset
  local newText = self.text:sub(1, offset) .. key .. self.text:sub(offset+1, -1)
  -- Move cursor
  -- Or text window if at end of text window
  if self.cursorOffset < self.size.x-2 then
    self.cursorOffset = self.cursorOffset+1
  else
    self.textOffset = self.textOffset+1
  end


  --Left arrrow
  self:_moveCursor(self.cursorOffset)
  --Right arrrow
  self:_moveCursor(self.cursorOffset+2)
end


Textbox = Textbox:new{}
return Textbox