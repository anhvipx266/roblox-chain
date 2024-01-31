--[[
    Chuỗi tạo, chạy Tween Instance
]]
local ts = game:GetService("TweenService")

local Chain = require(script.Parent.Chain)

local __prototype = {}
local Tween = table.clone(getmetatable(Chain))
Tween.__index = Tween
Tween.__prototype = __prototype
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

return setmetatable(__prototype, Tween)