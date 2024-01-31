--[[
    Chuỗi tạo, chạy cho Signal, Event
]]
local ts = game:GetService("TweenService")

local Chain = require(script.Parent.Chain)

local __prototype = {}
local Event = table.clone(getmetatable(Chain))
Event.__index = Event
Event.__prototype = __prototype
Event.__tostring = function(self) return self.ClassName end
Event.ClassName = 'Event'
Event.ShortName = 'ev'
--/main
-- Connect
function Event:Connect(signal, f, ...)
    return self:event(signal, signal.Connect, f, ...)
end
function Event:ConnectBlend(blend, signal, f, ...)
    local class = self:find(blend)
    return self:eventBlend(blend ,signal, signal.Connect, f, ...)
end
-- Once
function Event:Once(signal, f, ...)
    return self:event(signal, signal.Once, f, ...)
end
function Event:OnceBlend(blend, signal, f, ...)
    local class = self:find(blend)
    return self:eventBlend(blend ,signal, signal.Once, f, ...)
end
-- ConnectParallel
function Event:ConnectParallel(signal, f, ...)
    return self:event(signal, signal.ConnectParallel, f, ...)
end
function Event:ConnectParallelBlend(blend, signal, f, ...)
    local class = self:find(blend)
    return self:eventBlend(blend ,signal, signal.ConnectParallel, f, ...)
end

-- short function
Event.cn = Event.Connect
Event.connect = Event.Connect
Event.once = Event.Once
Event.cnp = Event.ConnectParallel
Event.connectParallel = Event.ConnectParallel

Event.cnb = Event.ConnectBlend
Event.connectBlend = Event.ConnectBlend
Event.onceb = Event.OnceBlend
Event.onceBlend = Event.OnceBlend
Event.cnpb = Event.ConnectParallelBlend
Event.connectParallelBlend = Event.ConnectParallelBlend

return setmetatable(__prototype, Event)