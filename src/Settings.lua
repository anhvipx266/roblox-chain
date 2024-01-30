export type ChainSettings = {
    RequiredList:{string}, -- danh sách các Chain cần được tải ngay
}

local Settings:ChainSettings = {
    RequiredList = {
        -- 'Chain' -- luôn luôn được yêu cầu
    }
}

return Settings