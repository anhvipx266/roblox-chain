local Settings = require(script.Settings)
local MainChain = require(script.Chain)

local Chain = {}

local function load(v: ModuleScript)
	if not v:IsA("ModuleScript") then return end
	local class = require(v)
	Chain[v.Name] = class
    MainChain.all[v.Name] = class
    if class.ShortName then
        Chain[class.ShortName] = class
        MainChain.all[class.ShortName] = class
    end
end

-- tải các lớp bên trong
script.DescendantAdded:Connect(load)
for k, v in pairs(script:GetDescendants()) do load(v) end

function Chain.new(className: string, ...)
	return Chain[className].new(...)
end
function Chain.init(className: string)
	return setmetatable({}, Chain[className])
end

function Chain.wait(className: string)
	while not Chain[className] do task.wait(0.1) end
	return Chain[className]
end
-- đợi đến khi tải xong các Chain được yêu cầu
while true do
    local loadedAll = true
    for _, className in pairs(Settings.RequiredList) do
        if not Chain[className] then
            loadedAll = false
            break
        end
    end
    if loadedAll then break end
end

return Chain
