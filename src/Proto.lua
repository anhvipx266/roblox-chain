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
function Proto:wrap(sp, f, ...)
    local f2 = function(...)
        print("Proto!")
        f(...)
    end
    return self:pack(self, false, f2, ...)
end
-- thực thi một Chuỗi - Chain
-- function Proto.run(...)
--     local chain, _f = Proto.wrap(false, ...)
--     _f()
--     return chain
-- end
-- -- sinh một Chuỗi - Chain
-- function Proto.spawn(...)
--     local chain, _f = Proto.wrap(true, ...)
--     task.spawn(_f)
--     return chain
-- end
-- -- thử một Chuỗi - Chain
-- function Proto.try(f, ...)
--     local chain, _f = Proto.wrap(false, ...)
--     local success, err = pcall(_f)
--     if not success then warn("Chain err:\n", err) end
--     chain.err = err
--     return chain
-- end
--------------------------------------------------------------------------
-- short function
Proto.r = Proto.run
Proto.s = Proto.spawn
Proto.t = Proto.try
Proto.rb = Proto.runBlend
Proto.sb = Proto.spawnBlend
Proto.tb = Proto.tryBlend


return setmetatable({}, Proto)