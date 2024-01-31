export type Chain = {

}

local Chain = {}
Chain.__index = Chain
Chain.__tostring = function(self) return self.ClassName end
Chain.ClassName = 'Chain'
Chain.ShortName = 'm'
Chain.all = {}

local strs = "run spawn try defer delay"
--/utils
-- tìm chuỗi - Chain với tên nếu cần
function Chain:chain(chain)
    if type(chain) == "string" then
        chain = self.all[chain]
    end
    return chain
end

function Chain:toRemember(chain)
    chain.nxts = {}
    for _, strf in strs:split(' ') do
        chain[strf] = function(self, ...)
            table.insert(chain.nxts, {strf, ...})
            return chain
        end
        local bstrf = strf..'Blend'
        chain[bstrf] = function(self, ...)
            table.insert(chain.nxts, {bstrf, ...})
            return chain
        end
    end
end

function Chain:pack(_chain, sp, _f, ...)
    local para = table.pack(...)
    local chain = table.clone(_chain)
    chain.err = nil
    chain.nxts = nil
    local result = {}
    if sp then
        -- chuyển thành Chuỗi ghi nhớ
        _chain:toRemember(chain)
    else
        -- trả về bao đóng kèm dữ liệu kết quả, lỗi
        for _, strf in strs:split(' ') do
            chain[strf] = function(self, f, ...)
                return _chain[strf](_chain, f, ..., chain.err, unpack(result))
            end
            local bstrf = strf..'Blend'
            chain[bstrf] = function(self, blend, f, ...)
                return _chain[bstrf](_chain, blend, f, ..., chain.err, unpack(result))
            end
        end
    end
    -- short function
    chain.r = chain.run
    chain.s = chain.spawn
    chain.t = chain.try
    chain.rb = chain.runBlend
    chain.sb = chain.spawnBlend
    chain.tb = chain.tryBlend
    chain.dl = chain.delay
    chain.df = chain.defer
    -- Chain và function được đóng gói
    return chain, function()
        result = table.pack(_f(_f, unpack(para)))
        if chain.nxts then
            -- thực thi lại chuỗi phía sau
            local nchain = _chain
            for i, nxt in chain.nxts do
                local fstr, f = nxt[1], nxt[2]
                nchain = nchain[fstr](nchain, f, unpack(nxt, 3), chain.err, unpack(result))
            end
        end
    end
end
-- can overwrite
function Chain:wrap(sp, f, ...)
    return self:pack(self, sp, self:param(f, ...))
end
function Chain:param(...)
    return ...
end
-- thực thi một Chuỗi - Chain
function Chain:run(...)
    -- Chuỗi - Chain được đóng gói lại
    local chain, _f = self:wrap(false, ...)
    _f()
    return chain
end
-- thực thi kết hợp một Chuỗi - Chain
function Chain:runBlend(blend, f, ...)
    blend = self:chain(blend)
    return blend:run(f, ...)
end
-- sinh một Chuỗi - Chain
function Chain:spawn(...)
    -- Chuỗi - Chain được đóng gói lại
    local chain, _f = self:wrap(true, ...)
    task.spawn(_f)
    return chain
end
-- sinh kết hợp một Chuỗi - Chain
function Chain:spawnBlend(blend, f, ...)
    blend = self:chain(blend)
    return blend:spawn(f, ...)
end
-- hoãn lại - defer một Chuỗi - Chain
function Chain:defer(...)
     -- Chuỗi - Chain được đóng gói lại
     local chain, _f = self:wrap(true, ...)
     task.defer(_f)
     return chain
end
-- hoãn lại kết hợp một Chuỗi - Chain
function Chain:deferBlend(blend, f, ...)
    blend = self:chain(blend)
    return blend:defer(f, ...)
end
-- trì hoãn - delay một Chuỗi - Chain
function Chain:delay(sec ,...)
    -- Chuỗi - Chain được đóng gói lại
    local chain, _f = self:wrap(true, ...)
    task.delay(sec, _f)
end
-- trì hoãn kết hợp một Chuỗi - Chain
function Chain:delayBlend(blend, sec, f, ...)
    blend = self:chain(blend)
    return blend:delay(sec, f, ...)
end
-- thử một Chuỗi - Chain
function Chain:try(...)
    -- Chuỗi - Chain được đóng gói lại
    local chain, _f = self:wrap(false, ...)
    local success, err = pcall(_f)
    if not success then warn("Chain err:\n", err) end
    chain.err = err
    return chain
end
-- thử kết hợp một Chuỗi - Chain
function Chain:tryBlend(blend, f, ...)
    blend = self:chain(blend)
    return blend:tryBlend(f, ...)
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

return setmetatable({}, Chain)