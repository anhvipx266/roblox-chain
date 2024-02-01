local CompositeKeyframeSequence = require(script.CompositeKeyframeSequence)
local Signal = require(script.Signal)

export type CompositeAnimation = {
    CompositeKeyframeSequences:{CompositeKeyframeSequence.CompositeKeyframeSequence},

	Looped:boolean,
	Speed:number
}

local _prototype = {}
_prototype.__index = _prototype
_prototype.__tostring = function(self)
    return `{string.rep('-', 35)} {self.ClassName} {string.rep('-', 35)}`
end
_prototype.ClassName = 'CompositeAnimation'
_prototype.Speed = 1
_prototype.Loop = 0
_prototype.Speed = 1

function _prototype.new(composite_keyframe_sequences, loop, speed, reverse)
    local self = setmetatable({}, _prototype)

    self.CompositeKeyframeSequences = composite_keyframe_sequences
    self._CKS = self.CompositeKeyframeSequences
    self.Loop = loop
    self.Speed = speed
    self.Reverse = reverse
    -- tính toán độ dài
    self.Length = 0
    for _, cks in self._CKS do
        self.Length = math.max(self.Length, cks.Length)
    end

    self.ReachedEnd = Signal.new()
    self.Completed = Signal.new()

    return self
end

function _prototype:Play(speed, reverse)
    self._loop = self.Loop
    self:_Play(speed, reverse)
end

function _prototype:_Play(speed, reverse)
    self._Speed = speed or self.Speed
    reverse = if self.Reverse ~= nil then self.Reverse else reverse
    if self.IsPlaying then return end
    self.IsPlaying = true
    self._Completed = {}
    self._cn = {}
    for i, cks in self._CKS do
        local cn
        cn = cks.Completed:Once(function()
            self._Completed[i] = cn
            if #self._Completed == #self._CKS then
                self.IsPlaying = false
                self._loop -= 1
                self.ReachedEnd:Fire()
                if self._loop ~= -1 then
                    self:_Play(self._Speed * cks.Speed, reverse)
                else
                    self.Completed:Fire()
                end
            end
        end)
        self._cn[i] = cn
        cks:Play(self._Speed * cks.Speed, reverse)
    end
end

function _prototype:Pause()
    self.IsPlaying = false
    for _, cks in self._CKS do cks:Pause() end
end

function _prototype:Continue(speed, reverse)
    self._Speed = speed or self.Speed
    reverse = if self.Reverse ~= nil then self.Reverse else reverse
    self.IsPlaying = true
    for _, cks in self._CKS do
        cks:Continue(self._Speed * cks.Speed, reverse)
    end
end

function _prototype:Cancel()
    for _, cks in self._CKS do cks:Cancel() end
end

function _prototype:Stop()
    self.IsPlaying = false
    for i, cn in self._Completed do cn:Disconnect() end
    for i, cks in self._CKS do cks:Stop() end
end

return _prototype