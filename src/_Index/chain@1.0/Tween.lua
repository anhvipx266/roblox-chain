--[[
    Chuỗi tạo, chạy Tween Instance
]]
local ts = game:GetService("TweenService")

local Chain = require(script.Parent.Chain)

local Tween = table.clone(Chain)
Tween.__index = Tween
Tween.__tostring = function(self) return self.ClassName end
Tween.ClassName = 'Tween'
Tween.ShortName = 'tw'
--/main
function Tween:param(ins:Instance, mayInfo, mayTo, ...)
    local para = table.pack(mayInfo, mayTo, ...)
    local info, to
    if typeof(mayInfo) == "TweenInfo" then
        info = mayInfo
        to = mayTo
    else
        -- tạo info từ chuỗi para trước to - table
        for i = 1, para.n do
            if type(para[i]) == "table" then
                to = para[i]
                info = TweenInfo.new(unpack(para, 1, i - 1))
                break
            end
        end
    end
    local f2 = function()
        local tw = ts:Create(ins, info, to)
        tw:Play()
        tw.Completed:Wait()
    end
    return f2
end
function Tween:wrap(sp, ins:Instance, mayInfo, mayTo, ...)
    local f2 = self:param(ins, mayInfo, mayTo, ...)
    return self:pack(self, false, f2)
end

return setmetatable({}, Tween)