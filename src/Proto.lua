--[[
    Một Lớp dẫn xuất của Chain đều chỉ khác biệt ở phần xử lý tham số
    -> Kết xuất ra function hoặc biến đổi đối số cho function
    ---------------------------------------------------------
    VD trong Proto là function sẽ wrap trong 1 function ảo print("Proto Chain")
]]
local Chain = require(script.Parent.Chain)

local Proto = table.clone(Chain)
Proto.__index = Proto
Proto.__tostring = function(self) return self.ClassName end
Proto.ClassName = 'Proto'
Proto.ShortName = 'proto'
--/main
-- need overwrite
function Proto:wrap(sp, f, ...)
    local f2 = function(...)
        print("Proto!")
        f(...)
    end
    return self:pack(self, false, f2, ...)
end

return setmetatable({}, Proto)