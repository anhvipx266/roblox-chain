export type Chain = {

}

local __prototype = {}
local Chain = {}
Chain.__index = Chain
Chain.__tostring = function(self) return self.ClassName end
Chain.__prototype = __prototype
Chain.ClassName = 'Chain'
Chain.ShortName = 'm'
Chain.all = {}

local strs = "run spawn try defer delay"
--/utils
-- tìm chuỗi - Chain với tên nếu cần
function Chain:find(chain)
    if type(chain) == "string" then
        chain = self.all[chain]
    end
    return chain
end
function Chain:new()
    local new = setmetatable({}, getmetatable(self))
    new.List = {}
    return new
end
-- trả lại hoặc tạo mới
function Chain:get(...):Chain
    if self ~= self.__prototype then return self end
    return self:new()
end
-- bắt đầu Chain
function Chain:start()
    -- khởi động các Chain được kết nối đến
    for i, chain in self.List do
        chain:exec(self)
    end
end
-- biến đổi tham số về dạng chuẩn function, param...
function Chain:param(...):((any...)->(any...), any...)
    return ...
end
-- lưu trữ/kết nối Chain
function Chain:chain(class, tp, f, ...)
    -- tạo hoặc lấy chain hiện tại
    local chain = self:get()
    -- chain gần nhất được thêm vào
    local lastChain = chain.LastChain or chain
    class = class or lastChain
    -- tạo một Chain mới rồi thêm vào chuỗi
    local new = class:new()
    new.Params = {class:param(f, ...)}
    new.Type = tp
    table.insert(lastChain.List, new)
    chain.LastChain = new
    return chain, new
end
-- chạy Chain
function Chain:run(f, ...):Chain
    return self:chain(nil, 'run', f, ...)
end
function Chain:runBlend(blend, f, ...):Chain
    local class = self:find(blend)
    return self:chain(class, 'run', f, ...)
end
-- sinh - spawn Chain
function Chain:spawn(f, ...)
    return self:chain(nil, 'spawn', f, ...)
end
function Chain:spawnBlend(blend, f, ...):Chain
    local class = self:find(blend)
    return self:chain(class, 'spawn', f, ...)
end
-- hoãn lại - defer Chain
function Chain:defer(f, ...)
    return self:chain(nil, 'defer', f, ...)
end
function Chain:deferBlend(blend, f, ...):Chain
    local class = self:find(blend)
    return self:chain(class, 'defer', f, ...)
end
-- trì hoãn - delay Chain
function Chain:delay(sec, f, ...)
    local chain, new = self:chain(nil, 'delay', f, ...)
    new.Sec = sec -- lưu trữ thời gian delay
    return chain, new
end
function Chain:delayBlend(blend, sec, f, ...):Chain
    local class = self:find(blend)
    local chain, new = self:chain(class, 'delay', f, ...)
    new.Sec = sec -- lưu trữ thời gian delay
    return chain, new
end
-- thử - try Chain
function Chain:try(f, ...)
    return self:chain(nil, 'try', f, ...)
end
function Chain:tryBlend(blend, f, ...):Chain
    local class = self:find(blend)
    return self:chain(class, 'try', f, ...)
end
-- kết nối tín hiệu - event/Signal Chain
function Chain:event(signal, fcn, f, ...)
    local chain, new = self:chain(nil, 'event', f, ...)
	-- kết nối tín hiệu
	fcn(signal, function(...)
		local last = new.Last
		local lastResult = last.Result or {}
		local lastErr = last.Err
		local params = new.Params
		assert(type(f) == "function", "First params must be function, got " .. typeof(f))
        new.Result = {f(f, ..., unpack(params, 2), lastErr, unpack(lastResult))}
        new:start()
    end)
	return chain, new
end
function Chain:eventBlend(blend, signal, fcn, f, ...):Chain
    local class = self:find(blend)
    local chain, new = self:chain(class, 'event', f, ...)
	-- kết nối tín hiệu
	fcn(signal, function(...)
		local last = new.Last
		local lastResult = last.Result or {}
		local lastErr = last.Err
		local params = new.Params
		assert(type(f) == "function", "First params must be function, got " .. typeof(f))
        new.Result = {f(f, ..., unpack(params, 2), lastErr, unpack(lastResult))}
        new:start()
    end)
	return chain, new
end
-- thực thi Chain
function Chain:exec(last)
    local lastResult = last.Result or {}
    local lastErr = last.Err
    local params = self.Params
    local f = params[1]
    assert(type(f) == "function", "First params must be function, got " .. typeof(f))
    if self.Type == 'run' then
        self.Result = {f(f, unpack(params, 2), lastErr, unpack(lastResult))}
        self:start()
    elseif self.Type == 'spawn' then
        task.spawn(function()
            self.Result = {f(f, unpack(params, 2), lastErr, unpack(lastResult))}
            self:start()
        end)
    elseif self.Type == 'defer' then
        task.defer(function()
            self.Result = {f(f, unpack(params, 2), lastErr, unpack(lastResult))}
            self:start()
        end)
    elseif self.Type == 'delay' then
        task.delay(self.Sec, function()
            self.Result = {f(f, unpack(params, 2), lastErr, unpack(lastResult))}
            self:start()
        end)
    elseif self.Type == 'try' then
        local s, err = pcall(function()
            self.Result = {f(f, unpack(params, 2), lastErr, unpack(lastResult))}
        end)
        if not s then
            self.Err = err
            self.Result = {}
            warn(`Chain "{self.ClassName}" err: {err}`)
        end
        self:start()
    elseif self.Type == 'event' then
        self.Last = last
    end
end
--------------------------------------------------------------------------
-- short function
Chain.r = Chain.run
Chain.s = Chain.spawn
Chain.t = Chain.try
Chain.rb = Chain.runBlend
Chain.sb = Chain.spawnBlend
Chain.tb = Chain.tryBlend
Chain.dl = Chain.delay
Chain.df = Chain.defer
Chain.st = Chain.start
Chain.e = Chain.event
Chain.eb = Chain.eventBlend

return setmetatable(__prototype, Chain)