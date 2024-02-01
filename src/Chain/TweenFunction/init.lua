--[[
    Chuỗi tạo, chạy TweenFunction Class
    Tween được thực thi theo tham số cuối
    callback được khớp với function đầu tiên trong tham số
]]

local ts = game:GetService("TweenService")

local Chain = require(script.Parent.Chain)
local Tween = require(script.CompositeAnimation.Tween)
export type TweenFunction = Chain.Chain & {
    param:Chain.WrapFunction
}

local __prototype = {}
local TweenFunction = table.clone(getmetatable(Chain))
TweenFunction.__index = TweenFunction
TweenFunction.__prototype = __prototype
TweenFunction.__tostring = function(self) return self.ClassName end
TweenFunction.ClassName = 'TweenFunction'
TweenFunction.ShortName = 'twf'
--/main
function TweenFunction:param(...)
    local function f(this, ...)
        local param = table.pack(...)
        -- khớp callback với function đầu tiên
        local callback
        for i, v in param do
            if typeof(v) == "function" then callback = v; table.remove(param, i); break; end
        end
        -- chạy Tween
        local tw = Tween.fromSimple(table.unpack(param))
        tw:Play()
        if callback then callback(this, table.unpack(param)) end
    end
    return f, ...
end

return setmetatable(__prototype, TweenFunction)::TweenFunction