--[[
    Một Lớp dẫn xuất của Chain đều chỉ khác biệt ở phần xử lý tham số
    -> Kết xuất ra function hoặc biến đổi đối số cho function
    ---------------------------------------------------------
    VD trong Proto là function sẽ wrap trong 1 function ảo print("Proto Chain")
]]
local Chain = require(script.Parent.Chain)

local __prototype = {}
local Proto = table.clone(getmetatable(Chain))
Proto.__index = Proto
Proto.__prototype = __prototype
Proto.__tostring = function(self) return self.ClassName end
Proto.ClassName = 'Proto'
Proto.ShortName = 'proto'
--/main
-- need overwrite
function Proto:param(f, ...)
    local f2 = function(...)
        print("Proto!")
        f(...)
    end
    return f2, ...
end

return setmetatable(__prototype, Proto)