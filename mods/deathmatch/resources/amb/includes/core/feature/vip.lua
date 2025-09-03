-- ================================
-- AMB MTA:SA - VIP & Gift System
-- Migrated from SA-MP open.mp server
-- ================================

-- VIP and gift management systems
local vipSystem = {
    giftBoxes = {},
    rewards = {},
    vipPlayers = {},
    shopOrders = {},
    giftCodes = {},
    rewardPlay = false,
    doubleXP = false,
    giftLocations = {
        {x = 1481.0, y = -1749.2, z = 15.3, name = "Grove Street"},
        {x = 2495.2, y = -1691.3, z = 14.7, name = "Ganton"},
        {x = 1368.5, y = -1279.8, z = 13.5, name = "Jefferson"}
    },
    vipLevels = {
        bronze = {name = "Bronze VIP", price = 50000, benefits = {"Double XP", "VIP Chat", "Spawn Protection"}},
        silver = {name = "Silver VIP", price = 100000, benefits = {"Bronze + Free Repair", "VIP Vehicles", "No Ads"}},
        gold = {name = "Gold VIP", price = 200000, benefits = {"Silver + VIP House", "Exclusive Commands", "Priority Support"}},
        diamond = {name = "Diamond VIP", price = 500000, benefits = {"Gold + Admin Powers", "Custom Features", "Max Benefits"}}
    },
    orderTypes = {
        vehicle = {name = "Vehicle Order", minPrice = 10000},
        weapon = {name = "Weapon Order", minPrice = 1000},
        house = {name = "House Order", minPrice = 50000},
        business = {name = "Business Order", minPrice = 100000}
    }
}

-- VIP level management
addCommandHandler("newgvip", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin", 5) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /newgvip [player]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local accountName = getElementData(target, "account.name")
    vipSystem.vipPlayers[accountName] = {
        level = "gold",
        expiry = getRealTime().timestamp + (30 * 24 * 3600), -- 30 days
        grantedBy = getPlayerName(player)
    }
    
    setElementData(target, "player.vipLevel", "gold")
    setElementData(target, "player.vipExpiry", vipSystem.vipPlayers[accountName].expiry)
    
    outputChatBox(getPlayerName(player) .. " has set " .. getPlayerName(target) .. "'s VIP level to Gold", root, 255, 215, 0)
    outputChatBox("Chuc mung! Ban da duoc nang cap len Gold VIP!", target, 255, 215, 0)
    outputChatBox("Cac tinh nang VIP da duoc kich hoat", target, 255, 255, 255)
end)

addCommandHandler("renewgvip", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin", 5) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /renewgvip [player]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local accountName = getElementData(target, "account.name")
    if not vipSystem.vipPlayers[accountName] then
        vipSystem.vipPlayers[accountName] = {level = "gold"}
    end
    
    -- Extend by 30 days
    local currentExpiry = vipSystem.vipPlayers[accountName].expiry or getRealTime().timestamp
    vipSystem.vipPlayers[accountName].expiry = math.max(currentExpiry, getRealTime().timestamp) + (30 * 24 * 3600)
    
    setElementData(target, "player.vipLevel", "gold")
    setElementData(target, "player.vipExpiry", vipSystem.vipPlayers[accountName].expiry)
    
    outputChatBox(getPlayerName(player) .. " has renewed " .. getPlayerName(target) .. "'s Gold VIP for 30 days", root, 255, 215, 0)
    outputChatBox("Gold VIP cua ban da duoc gia han 30 ngay!", target, 255, 215, 0)
end)

addCommandHandler("sellvip", function(player, _, vipType)
    if not vipType then
        outputChatBox("Su dung: /sellvip [bronze/silver/gold/diamond]", player, 255, 255, 255)
        outputChatBox("=== VIP PACKAGES ===", player, 255, 255, 0)
        
        for levelId, level in pairs(vipSystem.vipLevels) do
            outputChatBox(level.name .. " - $" .. level.price, player, 255, 255, 255)
            for _, benefit in ipairs(level.benefits) do
                outputChatBox("  • " .. benefit, player, 200, 200, 200)
            end
        end
        return
    end
    
    if not vipSystem.vipLevels[vipType] then
        outputChatBox("VIP level khong hop le!", player, 255, 0, 0)
        return
    end
    
    local vipLevel = vipSystem.vipLevels[vipType]
    if getPlayerMoney(player) < vipLevel.price then
        outputChatBox("Ban khong du tien mua " .. vipLevel.name .. "! Can: $" .. vipLevel.price, player, 255, 0, 0)
        return
    end
    
    takePlayerMoney(player, vipLevel.price)
    
    local accountName = getElementData(player, "account.name")
    vipSystem.vipPlayers[accountName] = {
        level = vipType,
        expiry = getRealTime().timestamp + (30 * 24 * 3600), -- 30 days
        purchaseTime = getRealTime().timestamp
    }
    
    setElementData(player, "player.vipLevel", vipType)
    setElementData(player, "player.vipExpiry", vipSystem.vipPlayers[accountName].expiry)
    
    outputChatBox("Chuc mung! Ban da mua thanh cong " .. vipLevel.name .. "!", player, 0, 255, 0)
    outputChatBox("Gia: $" .. vipLevel.price .. " - Thoi han: 30 ngay", player, 255, 255, 255)
    outputChatBox(getPlayerName(player) .. " vua mua " .. vipLevel.name, root, 255, 215, 0)
end)

-- Gift box system
addCommandHandler("goldgiftbox", function(player)
    if not hasPermission(player, "admin", 3) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    -- Toggle gift box
    if vipSystem.giftBoxes.active then
        -- Remove gift box
        if vipSystem.giftBoxes.object then
            destroyElement(vipSystem.giftBoxes.object)
        end
        if vipSystem.giftBoxes.marker then
            destroyElement(vipSystem.giftBoxes.marker)
        end
        
        vipSystem.giftBoxes.active = false
        outputChatBox(getPlayerName(player) .. " has removed the reward gift box", root, 255, 255, 0)
    else
        -- Place gift box at random location
        local location = vipSystem.giftLocations[math.random(#vipSystem.giftLocations)]
        
        vipSystem.giftBoxes.object = createObject(1220, location.x, location.y, location.z) -- Gift box model
        vipSystem.giftBoxes.marker = createMarker(location.x, location.y, location.z - 1, "cylinder", 2, 255, 215, 0, 150)
        vipSystem.giftBoxes.location = location
        vipSystem.giftBoxes.active = true
        
        outputChatBox(getPlayerName(player) .. " has placed the reward gift box at " .. location.name, root, 255, 255, 0)
        outputChatBox("Tim gift box de nhan phan thuong!", root, 255, 215, 0)
    end
end)

addCommandHandler("getrewardgift", function(player)
    if not vipSystem.giftBoxes.active then
        outputChatBox("Khong co gift box nao dang hoat dong!", player, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local giftLocation = vipSystem.giftBoxes.location
    local distance = getDistanceBetweenPoints3D(x, y, z, giftLocation.x, giftLocation.y, giftLocation.z)
    
    if distance > 3 then
        outputChatBox("Ban can o gan gift box de nhan qua!", player, 255, 0, 0)
        return
    end
    
    -- Random rewards
    local rewards = {
        {type = "money", amount = math.random(10000, 50000), text = "tien mat"},
        {type = "vehicle", model = math.random(400, 600), text = "xe mien phi"},
        {type = "weapon", id = math.random(24, 31), ammo = 500, text = "vu khi"},
        {type = "vip", days = 7, text = "7 ngay VIP"},
        {type = "house", price = 100000, text = "nha mien phi"}
    }
    
    local reward = rewards[math.random(#rewards)]
    
    if reward.type == "money" then
        givePlayerMoney(player, reward.amount)
        outputChatBox("Ban nhan duoc $" .. reward.amount .. " tu gift box!", player, 0, 255, 0)
    elseif reward.type == "vehicle" then
        local x, y, z = getElementPosition(player)
        local vehicle = createVehicle(reward.model, x + 3, y, z)
        outputChatBox(getPlayerName(player) .. " was just gifted by the system and he won one free car", root, 255, 215, 0)
    elseif reward.type == "weapon" then
        giveWeapon(player, reward.id, reward.ammo)
        outputChatBox("Ban nhan duoc vu khi tu gift box!", player, 0, 255, 0)
    elseif reward.type == "vip" then
        local accountName = getElementData(player, "account.name")
        local currentExpiry = (vipSystem.vipPlayers[accountName] and vipSystem.vipPlayers[accountName].expiry) or getRealTime().timestamp
        
        vipSystem.vipPlayers[accountName] = {
            level = "gold",
            expiry = math.max(currentExpiry, getRealTime().timestamp) + (reward.days * 24 * 3600)
        }
        setElementData(player, "player.vipLevel", "gold")
        outputChatBox("Ban nhan duoc " .. reward.days .. " ngay Gold VIP!", player, 0, 255, 0)
    elseif reward.type == "house" then
        outputChatBox(getPlayerName(player) .. " was just gifted by the system and he won a free house", root, 255, 215, 0)
    end
    
    outputChatBox(getPlayerName(player) .. " da nhan qua tu gift box: " .. reward.text, root, 255, 255, 0)
    
    -- Remove gift box after someone claims it
    if vipSystem.giftBoxes.object then destroyElement(vipSystem.giftBoxes.object) end
    if vipSystem.giftBoxes.marker then destroyElement(vipSystem.giftBoxes.marker) end
    vipSystem.giftBoxes.active = false
end)

-- Reward play system
addCommandHandler("rewardplay", function(player)
    if not hasPermission(player, "admin", 4) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    vipSystem.rewardPlay = not vipSystem.rewardPlay
    local status = vipSystem.rewardPlay and "enabled" or "disabled"
    
    outputChatBox(getPlayerName(player) .. " has " .. status .. " Reward Play", root, 255, 255, 0)
    
    if vipSystem.rewardPlay then
        outputChatBox("Reward Play ACTIVE: Tat ca action deu co reward bonus!", root, 0, 255, 0)
    else
        outputChatBox("Reward Play da tat", root, 255, 255, 0)
    end
end)

addCommandHandler("doublexp", function(player)
    if not hasPermission(player, "admin", 4) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    vipSystem.doubleXP = not vipSystem.doubleXP
    local status = vipSystem.doubleXP and "enabled" or "disabled"
    
    if vipSystem.doubleXP then
        outputChatBox(getPlayerName(player) .. " has enabled Double XP", root, 255, 255, 0)
        outputChatBox("DOUBLE XP ACTIVE: Tat ca EXP nhan duoc x2!", root, 0, 255, 0)
    else
        outputChatBox(getPlayerName(player) .. " has ended the Double XP", root, 255, 255, 0)
        outputChatBox("Double XP da ket thuc", root, 255, 255, 0)
    end
end)

-- Shop order system
addCommandHandler("shoporder", function(player, _, orderType, ...)
    if not orderType or not ... then
        outputChatBox("Su dung: /shoporder [vehicle/weapon/house/business] [details]", player, 255, 255, 255)
        outputChatBox("Vi du: /shoporder vehicle Infernus", player, 255, 255, 255)
        return
    end
    
    if not vipSystem.orderTypes[orderType] then
        outputChatBox("Loai order khong hop le! (vehicle/weapon/house/business)", player, 255, 0, 0)
        return
    end
    
    local details = table.concat({...}, " ")
    local orderInfo = vipSystem.orderTypes[orderType]
    
    if getPlayerMoney(player) < orderInfo.minPrice then
        outputChatBox("Ban khong du tien dat order " .. orderInfo.name .. "! Toi thieu: $" .. orderInfo.minPrice, player, 255, 0, 0)
        return
    end
    
    local orderId = #vipSystem.shopOrders + 1
    vipSystem.shopOrders[orderId] = {
        player = player,
        playerName = getPlayerName(player),
        type = orderType,
        details = details,
        price = orderInfo.minPrice,
        status = "pending",
        time = getRealTime().timestamp
    }
    
    takePlayerMoney(player, orderInfo.minPrice)
    
    outputChatBox("Order #" .. orderId .. " da duoc dat thanh cong!", player, 0, 255, 0)
    outputChatBox("Loai: " .. orderInfo.name .. " - Chi tiet: " .. details, player, 255, 255, 255)
    outputChatBox("Admin se xu ly order som nhat co the", player, 255, 255, 255)
    
    -- Notify admins
    for _, admin in ipairs(getElementsByType("player")) do
        if hasPermission(admin, "admin", 2) then
            outputChatBox("Order moi #" .. orderId .. " tu " .. getPlayerName(player) .. ": " .. orderInfo.name, admin, 255, 215, 0)
            outputChatBox("Su dung /orders de xem tat ca orders", admin, 200, 200, 200)
        end
    end
end)

addCommandHandler("orders", function(player)
    if not hasPermission(player, "admin", 2) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("=== SHOP ORDERS ===", player, 255, 255, 0)
    local pendingCount = 0
    
    for orderId, order in pairs(vipSystem.shopOrders) do
        if order.status == "pending" then
            outputChatBox("#" .. orderId .. " - " .. order.playerName .. " - " .. vipSystem.orderTypes[order.type].name, player, 255, 255, 255)
            outputChatBox("    Chi tiet: " .. order.details .. " - Gia: $" .. order.price, player, 200, 200, 200)
            pendingCount = pendingCount + 1
        end
    end
    
    if pendingCount == 0 then
        outputChatBox("Khong co order nao dang cho xu ly", player, 255, 255, 255)
    else
        outputChatBox("Commands: /processorder [id] | /denyorder [id]", player, 255, 255, 255)
    end
end)

addCommandHandler("processorder", function(player, _, orderId)
    if not hasPermission(player, "admin", 2) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not orderId then
        outputChatBox("Su dung: /processorder [order ID]", player, 255, 255, 255)
        return
    end
    
    orderId = tonumber(orderId)
    local order = vipSystem.shopOrders[orderId]
    
    if not order then
        outputChatBox("Order ID khong ton tai!", player, 255, 0, 0)
        return
    end
    
    if order.status ~= "pending" then
        outputChatBox("Order nay da duoc xu ly roi!", player, 255, 0, 0)
        return
    end
    
    order.status = "processed"
    order.processedBy = getPlayerName(player)
    
    outputChatBox(getPlayerName(player) .. " has processed shop order ID " .. orderId .. " from " .. order.playerName, root, 255, 255, 0)
    
    -- Try to notify the customer if online
    local customer = getPlayerFromNameOrId(order.playerName)
    if customer then
        outputChatBox("Order #" .. orderId .. " cua ban da duoc xu ly boi " .. getPlayerName(player), customer, 0, 255, 0)
        outputChatBox("Admin se lien he voi ban de giao hang", customer, 255, 255, 255)
    end
end)

addCommandHandler("denyorder", function(player, _, orderId)
    if not hasPermission(player, "admin", 2) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not orderId then
        outputChatBox("Su dung: /denyorder [order ID]", player, 255, 255, 255)
        return
    end
    
    orderId = tonumber(orderId)
    local order = vipSystem.shopOrders[orderId]
    
    if not order then
        outputChatBox("Order ID khong ton tai!", player, 255, 0, 0)
        return
    end
    
    if order.status ~= "pending" then
        outputChatBox("Order nay da duoc xu ly roi!", player, 255, 0, 0)
        return
    end
    
    order.status = "denied"
    order.deniedBy = getPlayerName(player)
    
    outputChatBox(getPlayerName(player) .. " has denied shop order ID " .. orderId .. " from " .. order.playerName, root, 255, 255, 0)
    
    -- Refund customer if online
    local customer = getPlayerFromNameOrId(order.playerName)
    if customer then
        givePlayerMoney(customer, order.price)
        outputChatBox("Order #" .. orderId .. " cua ban da bi tu choi", customer, 255, 0, 0)
        outputChatBox("Tien da duoc hoan lai: $" .. order.price, customer, 255, 255, 0)
    end
end)

addCommandHandler("cancelorder", function(player, _, orderId)
    if not orderId then
        outputChatBox("Su dung: /cancelorder [order ID]", player, 255, 255, 255)
        return
    end
    
    orderId = tonumber(orderId)
    local order = vipSystem.shopOrders[orderId]
    
    if not order then
        outputChatBox("Order ID khong ton tai!", player, 255, 0, 0)
        return
    end
    
    if order.playerName ~= getPlayerName(player) then
        outputChatBox("Day khong phai order cua ban!", player, 255, 0, 0)
        return
    end
    
    if order.status ~= "pending" then
        outputChatBox("Order da duoc xu ly, khong the huy!", player, 255, 0, 0)
        return
    end
    
    -- Refund 90% (10% cancellation fee)
    local refund = math.floor(order.price * 0.9)
    givePlayerMoney(player, refund)
    
    order.status = "cancelled"
    
    outputChatBox("Order #" .. orderId .. " da bi huy", player, 255, 255, 0)
    outputChatBox("Hoan lai: $" .. refund .. " (phi huy: 10%)", player, 255, 255, 255)
end)

-- Gift codes system
addCommandHandler("giftcode", function(player, _, code)
    if not code then
        outputChatBox("Su dung: /giftcode [code]", player, 255, 255, 255)
        return
    end
    
    if not vipSystem.giftCodes[code] then
        outputChatBox("Gift code khong hop le hoac da het han!", player, 255, 0, 0)
        return
    end
    
    local giftInfo = vipSystem.giftCodes[code]
    local accountName = getElementData(player, "account.name")
    
    -- Check if already used
    if giftInfo.usedBy and giftInfo.usedBy[accountName] then
        outputChatBox("Ban da su dung gift code nay roi!", player, 255, 0, 0)
        return
    end
    
    -- Check expiry
    if getRealTime().timestamp > giftInfo.expiry then
        outputChatBox("Gift code da het han!", player, 255, 0, 0)
        return
    end
    
    -- Apply gift
    if giftInfo.type == "money" then
        givePlayerMoney(player, giftInfo.amount)
        outputChatBox("Ban nhan duoc $" .. giftInfo.amount .. " tu gift code!", player, 0, 255, 0)
    elseif giftInfo.type == "vip" then
        local currentExpiry = (vipSystem.vipPlayers[accountName] and vipSystem.vipPlayers[accountName].expiry) or getRealTime().timestamp
        vipSystem.vipPlayers[accountName] = {
            level = giftInfo.level,
            expiry = math.max(currentExpiry, getRealTime().timestamp) + (giftInfo.days * 24 * 3600)
        }
        setElementData(player, "player.vipLevel", giftInfo.level)
        outputChatBox("Ban nhan duoc " .. giftInfo.days .. " ngay " .. giftInfo.level .. " VIP!", player, 0, 255, 0)
    end
    
    -- Mark as used
    if not giftInfo.usedBy then giftInfo.usedBy = {} end
    giftInfo.usedBy[accountName] = true
    
    outputChatBox("Gift code '" .. code .. "' da duoc su dung thanh cong!", player, 255, 255, 0)
end)

-- Admin command to create gift codes
addCommandHandler("dathopqua", function(player, _, code, type, amount, days)
    if not hasPermission(player, "admin", 4) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not code or not type then
        outputChatBox("Su dung: /dathopqua [code] [money/vip] [amount/level] [days]", player, 255, 255, 255)
        outputChatBox("Vi du: /dathopqua WELCOME2025 money 50000", player, 255, 255, 255)
        outputChatBox("Vi du: /dathopqua VIP7DAYS vip gold 7", player, 255, 255, 255)
        return
    end
    
    if type == "money" then
        amount = tonumber(amount) or 10000
        vipSystem.giftCodes[code] = {
            type = "money",
            amount = amount,
            expiry = getRealTime().timestamp + (30 * 24 * 3600), -- 30 days
            creator = getPlayerName(player)
        }
        outputChatBox("Da tao gift code '" .. code .. "' voi $" .. amount, player, 0, 255, 0)
    elseif type == "vip" then
        local level = amount or "bronze"
        days = tonumber(days) or 7
        vipSystem.giftCodes[code] = {
            type = "vip",
            level = level,
            days = days,
            expiry = getRealTime().timestamp + (30 * 24 * 3600), -- 30 days
            creator = getPlayerName(player)
        }
        outputChatBox("Da tao VIP gift code '" .. code .. "' voi " .. days .. " ngay " .. level .. " VIP", player, 0, 255, 0)
    else
        outputChatBox("Type khong hop le! (money/vip)", player, 255, 0, 0)
        return
    end
    
    outputChatBox(getPlayerName(player) .. " da dat gift code: " .. code, root, 255, 215, 0)
end)

-- VIP benefits
function applyVIPBenefits(player, action)
    local vipLevel = getElementData(player, "player.vipLevel")
    if not vipLevel then return 1 end -- No VIP
    
    local multiplier = 1
    if vipLevel == "bronze" then multiplier = 1.25
    elseif vipLevel == "silver" then multiplier = 1.5
    elseif vipLevel == "gold" then multiplier = 2.0
    elseif vipLevel == "diamond" then multiplier = 3.0
    end
    
    -- Apply double XP if active
    if vipSystem.doubleXP then
        multiplier = multiplier * 2
    end
    
    -- Apply reward play bonus
    if vipSystem.rewardPlay then
        multiplier = multiplier * 1.5
    end
    
    return multiplier
end

-- VIP chat command
addCommandHandler("v", function(player, _, ...)
    local vipLevel = getElementData(player, "player.vipLevel")
    if not vipLevel then
        outputChatBox("Ban khong co VIP de su dung chat nay!", player, 255, 0, 0)
        return
    end
    
    if not ... then
        outputChatBox("Su dung: /v [message]", player, 255, 255, 255)
        return
    end
    
    local message = table.concat({...}, " ")
    
    -- Send to all VIP players
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "player.vipLevel") then
            outputChatBox("[VIP Chat] " .. getPlayerName(player) .. ": " .. message, p, 255, 215, 0)
        end
    end
    
    -- Send to admins
    for _, admin in ipairs(getElementsByType("player")) do
        if hasPermission(admin, "admin", 1) and not getElementData(admin, "player.vipLevel") then
            outputChatBox("[VIP Chat] " .. getPlayerName(player) .. ": " .. message, admin, 200, 200, 200)
        end
    end
end)

-- Check VIP expiry on join
addEventHandler("onPlayerJoin", root, function()
    local accountName = getElementData(source, "account.name")
    if accountName and vipSystem.vipPlayers[accountName] then
        local vipInfo = vipSystem.vipPlayers[accountName]
        if getRealTime().timestamp < vipInfo.expiry then
            setElementData(source, "player.vipLevel", vipInfo.level)
            setElementData(source, "player.vipExpiry", vipInfo.expiry)
            outputChatBox("Chao mung " .. vipInfo.level .. " VIP!", source, 255, 215, 0)
        else
            -- VIP expired
            vipSystem.vipPlayers[accountName] = nil
            setElementData(source, "player.vipLevel", nil)
            outputChatBox("VIP cua ban da het han. Su dung /sellvip de gia han", source, 255, 255, 0)
        end
    end
end)

print("VIP & Gift System loaded: VIP levels, gift boxes, shop orders, gift codes, VIP chat")
