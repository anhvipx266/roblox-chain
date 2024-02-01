local Signal = require(script.Parent.Signal)

export type Keyframe = {
	TimePosition:number, -- điểm thời gian của Keyframe, >= 0
	Props:{[string]:any},
	Value:any,

	Reached:Signal.Signal -- Signal
}

local propPointFunction = function(_start, _end, v, ori, t, len, rev, seed)
	return _start
end

local Keyframe = {}
Keyframe.__index = Keyframe
Keyframe.ClassName = "Keyframe"
Keyframe.__tostring = function(self)
    return `{string.rep('-', 35)} {self.ClassName} {string.rep('-', 35)}`
end
--/default props
Keyframe.Props = {}
Keyframe.TimePosition = 0

function Keyframe.new(time_position:number, props:{[string]:any}, maker, propFunctions, startFunctions, endFunctions)
	local self = setmetatable({}, Keyframe)
	assert(time_position >= 0, "TimePosition must be greater or equal 0!")
	
	self.TimePosition = time_position
	self.Props = props
	self.PropFunctions = propFunctions
	self.StartFunctions = startFunctions
	self.EndFunctions = endFunctions

	if maker then self.Reached = Signal.new() end
	
	return self
end

return Keyframe