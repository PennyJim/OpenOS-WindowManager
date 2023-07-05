---@meta

---@class Color: integer
---@alias ElementType "element" | "box" | "text" | "window" | "textbox" --Unneded?
---@alias clickEvent "down" | "drag" | "drop" | "touch"
---@alias keyEvent "key_down" | "key_up" | "clipboard"

---@class Component
---@field address string
---@field type string

---@class GPU: Component
---@field bind fun(address:string,reset:boolean?):boolean,string?
---@field getScreen fun():string
---@field getBackground fun():number,boolean
---@field setBackground fun(color:Color,isPaletteIndex:boolean?):Color,number?
---@field getForeground fun():number,boolean
---@field setForeground fun(color:Color,isPaletteIndex:boolean?):Color,number?
---@field getPaletteColor fun(index:number):number
---@field setPaletteColor fun(index:number,value:Color):number
---@field maxDepth fun():number
---@field getDepth fun():number
---@field setDepth fun(bit:number):string
---@field maxResolution fun():number,number
---@field getResolution fun():number,number
---@field setResolution fun(width:number,height:number):boolean
---@field getViewport fun():number,number
---@field setViewport fun(width:number,height:number):boolean
---@field get fun(x:number,y:number):string,Color,Color,number?,number?
---@field set fun(x:number,y:number,value:string,vertical:boolean?):boolean
---@field copy fun(x:number,y:number,width:number,height:number,tx:number,ty:number):boolean
---@field fill fun(x:number,y:number,width:number,height:number,char:string):boolean

---@class GPU: Component
---@field getActiveBuffer fun():number
---@field setActiveBuffer fun(index:number):number
---@field buffers fun():number[]
---@field allocateBuffer fun(width:number?,height:number?):number
---@field freeBuffer fun(index:number?):boolean
---@field freeAllBuffers fun()
---@field totalMemory fun():number
---@field freeMemory fun():number
---@field getBufferSize fun(index:number?):number,number
---@field bitblt fun(dst:number?,col:number?,row:number?,width:number?,height:number?,src:number?,fromCol:number?,fromRow:number?)

---@class Keyboard: Component
---@field isAltDown fun(): boolean
---@field isControl fun(char:number): boolean
---@field isControlDown fun(): boolean
---@field isKeyDown fun(charOrCode: any): boolean
---@field isShiftDown fun(): boolean
---@field keys table<string,integer>|table<integer,string>

-----@class os
-----@field clock fun():number
-----@field date fun(format:string?,time:number?):string|table
-----@field difftime fun(t1:number,t2:number):number
-----@field execute fun(command:string?):number|string
-----@field exit fun(code:boolean|string?, close:boolean)
-----@field setenv fun(varname:string, value:any):any?
-----@field getenv fun(varname:string):any?
-----@field remove fun(filename:string):boolean?, string?, integer?
-----@field rename fun(oldname:string, newname:string):boolean?, string?, integer?
-----@field time fun(table:table?):number
-----@field tmpname fun():string
-----@field sleep fun(seconds:number)