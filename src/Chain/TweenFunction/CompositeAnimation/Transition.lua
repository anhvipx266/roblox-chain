export type Transition = {
    TimeStart:number,
    TimeEnd:number,
    TimeFunction:(number) -> number,
}

local Transition = {}
Transition.__index = Transition
Transition.__tostring = function(self)
    return `{string.rep('-', 35)} {self.ClassName} {string.rep('-', 35)}`
end
Transition.ClassName = 'Transition'

function Transition.new(time_start, time_end, time_function, lerp)
    local self = setmetatable({}, Transition)

    assert(time_end > time_start, "TimeEnd must be greater than TimeStart!")

    self.TimeStart = time_start
    self.TimeEnd = time_end
    self.TimeFunction = time_function or function(x) return x end
    self.Lerp = lerp or {}

    return self
end
-- @return [0 - 1]
function Transition:GetAlpha(t)
    local x = self.TimeStart + (self.TimeEnd - self.TimeStart) * t
    return self.TimeFunction(x)
end

function Transition:InitLerp(props)
    for k, v in props do
        if self.Lerp[k] then continue end
        if type(v) == 'boolean' then
            self.Lerp[k] = function(v0) return v0 end
        elseif type(v) == 'number' then
            self.Lerp[k] = function(v0, v2, alpha) return v0 + (v2 - v0) * alpha end
        else
            self.Lerp[k] = v.Lerp
        end
    end
end

return Transition