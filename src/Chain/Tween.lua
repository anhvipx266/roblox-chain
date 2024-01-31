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
    local info, to, idx
    if typeof(mayInfo) == "TweenInfo" then
        info = mayInfo
        to = mayTo
    else
        -- tạo info từ chuỗi para trước to - table
        for i = 1, para.n do
            idx = i
            if type(para[i]) == "table" then
                to = para[i]
                info = TweenInfo.new(unpack(para, 1, i - 1))
                break
            end
        end
    end
    local f2 = function(this, callback, onCompleted, ...)
        local tw = ts:Create(ins, info, to)
        tw:Play()
        if onCompleted then
            assert(type(callback) == "function", 'onCompleted must be function, got ' .. typeof(callback))
            tw.Completed:Connect(onCompleted)
        end
        tw.Completed:Wait()
        if callback then
            assert(type(callback) == "function", 'Callback must be function, got ' .. typeof(callback))
            callback(ins, tw, info, to)
        end
    end
    return f2, para[idx + 1], para[idx + 2]
end

return setmetatable(__prototype, Tween)