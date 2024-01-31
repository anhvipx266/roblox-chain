--[[
    Chuỗi tạo, chạy TweenUI Instance
    Lưu ý: Tween sẽ cố gắng khớp tham số cuối theo thứ tự
    Cẩn thận với tham số hàm callback
]]
local ts = game:GetService("TweenService")

local Chain = require(script.Parent.Chain)
export type TweenUI = Chain.Chain & {
    param:(gui:GuiObject, strf:string, any...)->(any, any...),
}

local __prototype = {}
local TweenUI = table.clone(getmetatable(Chain))
TweenUI.__index = TweenUI
TweenUI.__prototype = __prototype
TweenUI.__tostring = function(self) return self.ClassName end
TweenUI.ClassName = 'TweenUI'
TweenUI.ShortName = 'twui'

function TweenUI:getEnumItem(enum:Enum, v)
    if typeof(v) ~= 'string' and typeof(v) ~= 'EnumItem' then return end
    for _, item in pairs(enum:GetEnumItems()) do
        if item.Name == v or item == v then
            return item
        end
    end
end
-- phân tích và định chuẩn tham số
-- @return Position Size dir style time overide callback ...
function TweenUI:_param(...)
    local params = table.pack(...)
    params.n = nil
    local idx, info:TweenInfo
    -- tìm kiếm Info
    for i, v in params do
        if typeof(v) == "TweenInfo" then info = v; table.remove(params, i); break; end
    end
    -- tham số tổng hợp
    local size, pos, dir, style, t, override, callback, err
    local lastPara, result, isize, ipos
    -- tìm và xác định Size, Pos
    for i, v in params do
        if size and pos then break end
        if typeof(v) == "UDim2" then
            if not size then isize = i; size = v;
            elseif not pos then ipos = i; pos = v; end
        end
    end
    -- xóa đối số size, pos
    if isize then table.remove(params, isize) end
    if ipos then table.remove(params, ipos) end
    if info then
       dir = info.EasingDirection; style = info.EasingStyle; t = info.Time;
    else
        -- tìm kiếm và khớp Dir
        for i, v in params do
            dir = self:getEnumItem(Enum.EasingDirection, v)
            if dir then idx = i; break; end
        end
        if dir then table.remove(params, idx) end
        -- tìm kiếm và khớp style
        for i, v in params do
            style = self:getEnumItem(Enum.EasingStyle, v)
            if style then idx = i; break; end
        end
        if style then table.remove(params, idx) end
        -- tìm kiếm và khớp time
        for i, v in params do
            if typeof(v) == "number" then t = v; table.remove(params, i); break; end
        end
        -- tìm kiếm và khớp overwrite
        for i, v in params do
            if typeof(v) == "boolean" then override = v; table.remove(params, i); break; end
        end
        -- tìm kiếm và khớp callback
        -- 1 là this function
        for i = 2, #params do
            if typeof(params[i]) == "function" then
                callback = params[i]; table.remove(params, i); break;
            end
        end
        -- bọc callback nếu có
        if callback then
            local _callback = callback
            callback = function() _callback(table.unpack(params)) end
        end
    end
    if not t then t = 1 end
    if pos and size then
        result = {size, pos, dir, t, override, callback}
    elseif size then
        result = {size, dir, t, override, callback}
    end
    result.t = t
    return result
end
--/main
function TweenUI:param(gui:GuiObject, strf:string, ...)
    local para = table.pack(...)
    assert(typeof(strf) == "string", "string function must be string, got " .. typeof(strf))
    -- khớp lại strf nếu thiếu Tween ở đầu
    if not strf:find("Tween") then strf = "Tween" .. strf end
    -- khớp hàm viết tắt
    if table.find({'size', 'Size', 's'}, strf) then
        strf = 'TweenSize'
    elseif table.find({'pos', 'Position', 'p', 'position'}, strf) then
        strf = 'TweenPosition'
    elseif table.find({'sizeAndPos', 'sizeAndPosition', 'sizePos', 'sp',
            'ps', 'posSize', 'positionAndSize', 'posAndSize'}, strf) then
        strf = 'TweenSizeAndPosition'
    end
    assert(string.find("TweenSize TweenPosition TweenSizeAndPosition", strf), "string Tween function invalid, got: " .. strf)
    local function f(this, ...)
        local params = self:_param(...)
        gui[strf](gui, table.unpack(params))
        task.wait(params.t)
    end
    return f, ...
end

return setmetatable(__prototype, TweenUI)::TweenUI