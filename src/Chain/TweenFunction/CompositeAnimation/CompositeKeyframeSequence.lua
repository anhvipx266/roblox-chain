local KeyframeSequence = require(script.Parent.KeyframeSequence)
local Signal = require(script.Parent.Signal)

export type CompositeKeyframeSequence = {
    _KS:{KeyframeSequence.KeyframeSequence}
}

local _prototype = {}
_prototype.__index = _prototype
_prototype.__tostring = function(self)
    return `{string.rep('-', 35)} {self.ClassName} {string.rep('-', 35)}`
end
_prototype.ClassName = 'CompositeKeyframeSequence'
_prototype.Loop = 0
_prototype.Speed = 1

function _prototype.new(keyframesequences, loop, speed, reverse)
    local self = setmetatable({}, _prototype)

    self._KS = keyframesequences
    self._KS = self._KS
    self.Loop = loop
    self.Speed = speed
    self.Reverse = reverse
    -- tính toán độ dài
    self.Length = 0
    for _, ks in self._KS do
        self.Length = math.max(self.Length, ks.Length)
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
    for i, ks in self._KS do
        local cn
        cn = ks.Completed:Once(function()
            self._Completed[i] = cn
            if #self._Completed == #self._KS then
                self.IsPlaying = false
                self._loop -= 1
                self.ReachedEnd:Fire()
                if self._loop ~= -1 then
                    self:_Play(self._Speed * ks.Speed, reverse)
                else
                    self.Completed:Fire()
                end
            end
        end)
        self._cn[i] = cn
        ks:Play(self._Speed * ks.Speed, reverse)
    end
end

function _prototype:Pause()
    self.IsPlaying = false
    for _, ks in self._KS do ks:Pause() end
end

function _prototype:Continue(speed, reverse)
    self._Speed = speed or self.Speed
    reverse = if self.Reverse ~= nil then self.Reverse else reverse
    self.IsPlaying = true
    for _, ks in self._KS do
        ks:Continue(self._Speed * ks.Speed, reverse)
    end
end

function _prototype:Cancel()
    for _, ks in self._KS do ks:Cancel() end
end

function _prototype:Stop()
    self.IsPlaying = false
    for i, cn in self._cn do cn:Disconnect() end
    for i, ks in self._KS do ks:Stop() end
end

local CompositeKeyframeSequence = _prototype
return CompositeKeyframeSequence