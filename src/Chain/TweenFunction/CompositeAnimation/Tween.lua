local Keyframe = require(script.Parent.Keyframe)
local Transition = require(script.Parent.Transition)

export type Tween = {
    StartKeyframe:Keyframe.Keyframe,
    EndKeyframe:Keyframe.Keyframe,
    Start:any,
    End:any,
    Transition:Transition.Transition,
    Middles:{any}
}
-- value, origin, alpha, time, length, reverse
local _propFunction = function(v, ori, alpha, t, len, rev, seed:Random)
    return ori * v
end
_propFunction = function(v, ori, alpha, t, len, rev, seed:Random) return ori * v end

local Tween = {}
Tween.__index = Tween
Tween.__tostring = function(self)
    return `{string.rep('-', 35)} {self.ClassName} {string.rep('-', 35)}`
end
Tween.ClassName = 'Tween'
Tween.IsPlaying = false
Tween.Loop = 0
Tween.Speed = 1
Tween.Reverse = false

local ANIMATION_SMOOTHNESS = 0.03
--/constructors
function Tween.new(obj, startKeyfrane, endKeyframe, length, transition, middles_props, loop, speed, reverse, propFunctions, seed)
    local self = setmetatable({}, Tween)

    self.Object = obj
    self.StartKeyframe = startKeyfrane
    self.EndKeyframe = endKeyframe
    self.Start = startKeyfrane.Props
    self.End = endKeyframe.Props
    self.Length = length
    self.Transition = transition
    self.Middles = middles_props or {}
    self.Loop = loop
    self.Speed = speed
    self.Reverse = reverse
    self.Seed = seed or Random.new(tick())

    self.PropFunctions = propFunctions or {}
    self.OriginProps = {}

    self.Points = {}
    self.Points[1] = self.Start
    for _, props in self.Middles do
        table.insert(self.Points, props)
    end
    table.insert(self.Points, self.End)

    self.Transition:InitLerp(self.Start)
    self:InitSetProps(self.Start)

    return self
end
-- tạo từ tham số đơn giản
function Tween.fromSimple(obj, start_props, end_props, start_time, length, ptransition, middles_props, loop, speed, reverse, propFunctions, seed)
    local startKeyfrane = Keyframe.new(start_time, start_props)
    local endKeyframe = Keyframe.new(start_time + length, end_props)
    local transition = Transition.new(table.unpack(ptransition))
    return Tween.new(obj, startKeyfrane, endKeyframe, length, transition, middles_props, loop, speed, reverse, propFunctions, seed)
end
-- lấy thông tin giá trị theo thời gian
function Tween:GetProps(t:number, reverse:boolean)
    self._alpha = self.Transition:GetAlpha(t / self.Length)
    -- nội suy chuỗi điểm
    local points = self.Points
    -- nghịch đảo chuỗi điểm nếu cần
    if reverse then
        points = {}
        local len = #self.Points
        for i = 1, len do
            points[len - i + 1] = self.Points[i]
        end
    end
    if self._alpha == 0 then return points[1] end
    if self._alpha == 1 then return points[#self.Points] end
    
    repeat
        local currentPoints = {}

        for i = 1, #points - 1 do
            currentPoints[i] = {}
            for k, v in points[i] do
                local v2 = points[i + 1][k]
                currentPoints[i][k] = self.Transition.Lerp[k](v, v2, self._alpha)
            end
        end

        points = currentPoints
    until #points == 1
    return points[1]
end

function Tween:SetProps(props, reverse)
    for k, v in props do
        self.Object[k] = self.PropFunctions[k](v, self.OriginProps[k], self._alpha, self._t, self.Length, reverse, self.Seed)
    end
end

function Tween:InitSetProps(props)
    for k, _v in props do
        if self.PropFunctions[k] then continue end
        local tp = typeof(_v)
        if tp == "boolean" or tp == 'number' then
            self.PropFunctions[k] = function(v, ori, alpha, t, len, rev) return v end
        elseif tp == 'CFrame' then
            self.PropFunctions[k] = function(v, ori, alpha, t, len, rev) return ori * v end
        elseif tp == 'Vector3' or tp == 'Vector2' then
            self.PropFunctions[k] = function(v, ori, alpha, t, len, rev) return ori + v end
        else
            self.PropFunctions[k] = function(v, ori, alpha, t, len, rev) return v end
        end
    end
end

function Tween:MakeKeypoints(currentProps, oriProps, t, len, rev)
    if self.StartKeyframe.StartFunction then
        self.Start = self.StartKeyframe.StartFunction(self.StartKeyframe.Props, self.EndKeyframe.Props, self.currentProps, oriProps, t, len, rev, self.Seed)
    end
    if self.EndKeyframe.EndFunction then
        self.End = self.EndKeyframe.StartFunction(self.StartKeyframe.Props, self.EndKeyframe.Props, self.currentProps, oriProps, t, len, rev, self.Seed)
    end
end
-- phát sự nới lỏng
function Tween:Play(speed, reverse)
    if self.IsPlaying then return end
    -- ghi nhớ thông tin gốc
    for k, v in self.Start do self.OriginProps[k] = self.Object[k] end
    self._t = 0
    -- số vòng còn lại, dừng khi số vòng chạm -1, hoặc vô hạn khi nhỏ hơn -1
    self._loop = self.Loop
    self:Continue(speed, reverse)
end
-- tạm dừng
function Tween:Pause()
    self.IsPlaying = false
    self.Paused = true
end

function Tween:GoForward()
    local props, reverse
    if self.Reverse then
        if self._t > self.Length * 2 then return true end
        if self._t <= self.Length then
            props = self:GetProps(self._t)
        else
            props = self:GetProps(self._t - self.Length, self.Reverse)
            reverse = true
        end
    else
        if self._t > self.Length then return true end
        props = self:GetProps(self._t)
    end
    self:SetProps(props, reverse)
end
-- chỉ có chiều nghịch và time > Length
function Tween:GoReverse()
    local props
    if self._t > self.Length * 2 then return true end
    props = self:GetProps(self._t - self.Length, true)
    self:SetProps(props, true)
end

function Tween:Continue(speed, reverse)
    self._Speed = speed or self.Speed
    self._s = tick() - (self._t)
    self.IsPlaying = true
    self.Paused = false
    repeat
        while self.IsPlaying do
            task.wait(ANIMATION_SMOOTHNESS)
            self._t = (tick() - self._s) * self._Speed
            if reverse and self._t > self.Length then
                if self:GoReverse() then break end
            else
                if self:GoForward() then break end
            end
        end
        self._loop -= 1
        if self._loop ~= -1 then
            self._s = tick()
            self:Cancel()
        end
    until self._loop == -1 or (not self.IsPlaying)
    self.IsPlaying = false
end
-- kết thúc
function Tween:Stop()
    self:Pause()
    self:Cancel()
end
-- đưa dữ liệu về ban đầu
function Tween:Cancel()
    for k, v in self.OriginProps do
        self.Object[k] = v
    end
end

return Tween