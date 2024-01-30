export type Chain = {

}

local Chain = {}
Chain.__index = Chain
Chain.__tostring = function(self) return self.ClassName end
Chain.ClassName = 'Chain'
Chain.ShortName = 'm'
Chain.all = {}
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
    function chain:run(...)
        table.insert(chain.nxts, {'run', ...})
        return chain
    end
    function chain:spawn(...)
        table.insert(chain.nxts, {'spawn', ...})
        return chain
    end
    function chain:try(...)
        table.insert(chain.nxts, {'try', ...})
        return chain
    end
    function chain:runBlend(...)
        table.insert(chain.nxts, {'runBlend', ...})
        return chain
    end
    function chain:spawnBlend(...)
        table.insert(chain.nxts, {'spawnBlend', ...})
        return chain
    end
    function chain:tryBlend(...)
        table.insert(chain.nxts, {'tryBlend', ...})
        return chain
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
        function chain:run(f, ...)
            return _chain:run(f, ..., chain.err, unpack(result))
        end
        function chain:spawn(f, ...)
            return _chain:spawn(f, ..., chain.err, unpack(result))
        end
        function chain:try(f, ...)
            return _chain:try(f, ..., chain.err, unpack(result))
        end
        function chain:runBlend(blend, f, ...)
            return _chain:runBlend(blend, f, ..., chain.err, unpack(result))
        end
        function chain:spawnBlend(blend, f, ...)
            return _chain:spawnBlend(blend, f, ..., chain.err, unpack(result))
        end
        function chain:tryBlend(blend, f, ...)
            return _chain:tryBlend(blend, f, ..., chain.err, unpack(result))
        end
    end
    -- short function
    chain.r = chain.run
    chain.s = chain.spawn
    chain.t = chain.try
    chain.rb = chain.runBlend
    chain.sb = chain.spawnBlend
    chain.tb = chain.tryBlend

    return chain, function()
        result = table.pack(_f(_f, unpack(para)))
        if chain.nxts then
            -- thực thi lại chuỗi phía sau
            local nchain = _chain
            for i, nxt in chain.nxts do
                local fstr, f = nxt[1], nxt[2]
                nchain = nchain[fstr](f, unpack(nxt, 3), chain.err, unpack(result))
            end
        end
    end
end
-- can overwrite
function Chain:wrap(sp, f, ...)
    return self:pack(self, sp, f, ...)
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
    local chain, _f = Chain:wrap(true, ...)
    task.spawn(_f)
    return chain
end
-- sinh kết hợp một Chuỗi - Chain
function Chain:spawnBlend(blend, f, ...)
    blend = self:chain(blend)
    return blend:spawn(f, ...)
end
-- thử một Chuỗi - Chain
function Chain:try(f, ...)
    -- Chuỗi - Chain được đóng gói lại
    local chain, _f = Chain:wrap(false, ...)
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

return setmetatable({}, Chain)