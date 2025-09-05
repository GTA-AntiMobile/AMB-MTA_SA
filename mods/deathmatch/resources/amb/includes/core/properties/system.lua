-- ================================
-- AMB MTA:SA - Property/House System Commands
-- Mass migration of property-related commands
-- ================================

-- Buy house command
addCommandHandler("buyhouse", function(player)
    local playerData = getElementData(player, "playerData") or {}
    local x, y, z = getElementPosition(player)
    
    -- Check if player is near a house for sale
    local nearestHouse = nil
    local houses = getElementData(getResourceRootElement(), "houses") or {}
    
    for houseID, house in pairs(houses) do
        if not house.owner or house.owner == "" then
            local distance = getDistanceBetweenPoints3D(x, y, z, house.x, house.y, house.z)
            if distance < 3 then
                nearestHouse = {id = houseID, data = house}
                break
            end
        end
    end
    
    if not nearestHouse then
        outputChatBox("❌ Ban khong o gan nha nao dang ban.", player, 255, 100, 100)
        return
    end
    
    local house = nearestHouse.data
    local price = house.price or 50000
    
    if (playerData.money or 0) < price then
        outputChatBox(string.format("❌ Ban can $%d de mua nha nay.", price), player, 255, 100, 100)
        return
    end
    
    if playerData.house and playerData.house > 0 then
        outputChatBox("❌ Ban da co nha roi. Sell nha cu truoc.", player, 255, 100, 100)
        return
    end
    
    -- Buy house
    playerData.money = (playerData.money or 0) - price
    playerData.house = nearestHouse.id
    house.owner = getPlayerName(player)
    house.locked = true
    
    setElementData(player, "playerData", playerData)
    houses[nearestHouse.id] = house
    setElementData(getResourceRootElement(), "houses", houses)
    
    outputChatBox(string.format("🏠 Da mua nha voi gia $%d!", price), player, 0, 255, 0)
    outputChatBox("Su dung /househelp de xem cac lenh nha.", player, 255, 255, 100)
end)

-- Sell house command
addCommandHandler("sellhouse", function(player, cmd, targetName)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.house or playerData.house <= 0 then
        outputChatBox("❌ Ban khong co nha.", player, 255, 100, 100)
        return
    end
    
    local houses = getElementData(getResourceRootElement(), "houses") or {}
    local house = houses[playerData.house]
    
    if not house then
        outputChatBox("❌ Khong tim thay nha cua ban.", player, 255, 100, 100)
        return
    end
    
    if targetName then
        -- Sell to player
        local targetPlayer = getPlayerFromNameOrId(targetName)
        if not targetPlayer then
            outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
            return
        end
        
        local targetData = getElementData(targetPlayer, "playerData") or {}
        if targetData.house and targetData.house > 0 then
            outputChatBox("❌ Nguoi choi da co nha roi.", player, 255, 100, 100)
            return
        end
        
        local price = math.floor((house.price or 50000) * 0.8) -- 80% of original price
        if (targetData.money or 0) < price then
            outputChatBox(string.format("❌ Nguoi choi khong co du tien ($%d).", price), player, 255, 100, 100)
            return
        end
        
        -- Transfer ownership
        targetData.money = (targetData.money or 0) - price
        playerData.money = (playerData.money or 0) + price
        targetData.house = playerData.house
        playerData.house = 0
        
        house.owner = getPlayerName(targetPlayer)
        
        setElementData(player, "playerData", playerData)
        setElementData(targetPlayer, "playerData", targetData)
        houses[playerData.house] = house
        setElementData(getResourceRootElement(), "houses", houses)
        
        outputChatBox(string.format("✅ Da ban nha cho %s voi gia $%d.", getPlayerName(targetPlayer), price), player, 0, 255, 0)
        outputChatBox(string.format("🏠 Da mua nha tu %s voi gia $%d!", getPlayerName(player), price), targetPlayer, 0, 255, 0)
    else
        -- Sell to server
        local sellPrice = math.floor((house.price or 50000) * 0.5) -- 50% of original price
        
        playerData.money = (playerData.money or 0) + sellPrice
        playerData.house = 0
        house.owner = ""
        house.locked = false
        
        setElementData(player, "playerData", playerData)
        houses[playerData.house] = house
        setElementData(getResourceRootElement(), "houses", houses)
        
        outputChatBox(string.format("✅ Da ban nha cho server voi gia $%d.", sellPrice), player, 0, 255, 0)
    end
end)

-- House lock/unlock
addCommandHandler("lock", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.house or playerData.house <= 0 then
        outputChatBox("❌ Ban khong co nha.", player, 255, 100, 100)
        return
    end
    
    local houses = getElementData(getResourceRootElement(), "houses") or {}
    local house = houses[playerData.house]
    
    if not house then
        outputChatBox("❌ Khong tim thay nha cua ban.", player, 255, 100, 100)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local distance = getDistanceBetweenPoints3D(x, y, z, house.x, house.y, house.z)
    
    if distance > 5 then
        outputChatBox("❌ Ban qua xa nha cua ban.", player, 255, 100, 100)
        return
    end
    
    house.locked = not (house.locked or false)
    houses[playerData.house] = house
    setElementData(getResourceRootElement(), "houses", houses)
    
    if house.locked then
        outputChatBox("🔒 Da khoa nha.", player, 255, 255, 100)
    else
        outputChatBox("🔓 Da mo khoa nha.", player, 255, 255, 100)
    end
end)

-- Enter house
addCommandHandler("enter", function(player)
    local x, y, z = getElementPosition(player)
    
    -- Find nearest house
    local nearestHouse = nil
    local houses = getElementData(getResourceRootElement(), "houses") or {}
    
    for houseID, house in pairs(houses) do
        local distance = getDistanceBetweenPoints3D(x, y, z, house.x, house.y, house.z)
        if distance < 3 then
            nearestHouse = {id = houseID, data = house}
            break
        end
    end
    
    if not nearestHouse then
        outputChatBox("❌ Ban khong o gan nha nao.", player, 255, 100, 100)
        return
    end
    
    local house = nearestHouse.data
    local playerData = getElementData(player, "playerData") or {}
    
    -- Check if house is locked and player is not owner
    if house.locked and house.owner ~= getPlayerName(player) then
        outputChatBox("❌ Nha nay da bi khoa.", player, 255, 100, 100)
        return
    end
    
    -- Teleport to house interior
    local interiorX = house.interiorX or 2196.8
    local interiorY = house.interiorY or -1204.4
    local interiorZ = house.interiorZ or 1049.0
    local interior = house.interior or 6
    
    setElementPosition(player, interiorX, interiorY, interiorZ)
    setElementInterior(player, interior)
    
    playerData.inHouse = nearestHouse.id
    setElementData(player, "playerData", playerData)
    
    outputChatBox("🏠 Da vao nha.", player, 255, 255, 100)
end)

-- Exit house
addCommandHandler("exit", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.inHouse then
        outputChatBox("❌ Ban khong o trong nha.", player, 255, 100, 100)
        return
    end
    
    local houses = getElementData(getResourceRootElement(), "houses") or {}
    local house = houses[playerData.inHouse]
    
    if not house then
        outputChatBox("❌ Khong tim thay nha.", player, 255, 100, 100)
        return
    end
    
    -- Teleport outside
    setElementPosition(player, house.x, house.y, house.z)
    setElementInterior(player, 0)
    
    playerData.inHouse = nil
    setElementData(player, "playerData", playerData)
    
    outputChatBox("🏠 Da ra khoi nha.", player, 255, 255, 100)
end)

-- House info
addCommandHandler("houseinfo", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.house or playerData.house <= 0 then
        outputChatBox("❌ Ban khong co nha.", player, 255, 100, 100)
        return
    end
    
    local houses = getElementData(getResourceRootElement(), "houses") or {}
    local house = houses[playerData.house]
    
    if not house then
        outputChatBox("❌ Khong tim thay nha cua ban.", player, 255, 100, 100)
        return
    end
    
    outputChatBox("🏠 ===== HOUSE INFO =====", player, 255, 255, 0)
    outputChatBox(string.format("• Owner: %s", house.owner), player, 255, 255, 255)
    outputChatBox(string.format("• Price: $%d", house.price or 50000), player, 255, 255, 255)
    outputChatBox(string.format("• Status: %s", house.locked and "Locked" or "Unlocked"), player, 255, 255, 255)
    outputChatBox(string.format("• Location: %.1f, %.1f, %.1f", house.x, house.y, house.z), player, 255, 255, 255)
end)

-- Rent system
addCommandHandler("rent", function(player, cmd, targetName, amount)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.house or playerData.house <= 0 then
        outputChatBox("❌ Ban khong co nha de cho thue.", player, 255, 100, 100)
        return
    end
    
    if not targetName or not amount then
        outputChatBox("Su dung: /rent [player_name] [price_per_day]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(targetName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local rentPrice = tonumber(amount)
    if not rentPrice or rentPrice < 1 then
        outputChatBox("❌ Gia thue khong hop le.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    
    -- Send rent offer
    targetData.rentOffer = {
        house = playerData.house,
        owner = player,
        price = rentPrice,
        time = getRealTime().timestamp
    }
    setElementData(targetPlayer, "playerData", targetData)
    
    outputChatBox(string.format("✅ Da gui rent offer den %s ($%d/day).", getPlayerName(targetPlayer), rentPrice), player, 0, 255, 0)
    outputChatBox(string.format("🏠 %s muon cho ban thue nha voi gia $%d/day. Su dung /acceptrent.", getPlayerName(player), rentPrice), targetPlayer, 255, 255, 100)
end)

-- Accept rent
addCommandHandler("acceptrent", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.rentOffer then
        outputChatBox("❌ Ban khong co rent offer nao.", player, 255, 100, 100)
        return
    end
    
    local offer = playerData.rentOffer
    if not isElement(offer.owner) then
        outputChatBox("❌ Rent offer da expired.", player, 255, 100, 100)
        playerData.rentOffer = nil
        setElementData(player, "playerData", playerData)
        return
    end
    
    if (playerData.money or 0) < offer.price then
        outputChatBox(string.format("❌ Ban can $%d de thue nha.", offer.price), player, 255, 100, 100)
        return
    end
    
    -- Pay first day rent
    playerData.money = (playerData.money or 0) - offer.price
    playerData.rentedHouse = offer.house
    playerData.rentPrice = offer.price
    playerData.rentExpiry = getRealTime().timestamp + (24 * 3600) -- 1 day
    playerData.rentOffer = nil
    
    local ownerData = getElementData(offer.owner, "playerData") or {}
    ownerData.money = (ownerData.money or 0) + offer.price
    
    setElementData(player, "playerData", playerData)
    setElementData(offer.owner, "playerData", ownerData)
    
    outputChatBox(string.format("✅ Da thue nha voi gia $%d/day!", offer.price), player, 0, 255, 0)
    outputChatBox(string.format("💰 %s da thue nha cua ban. Nhan $%d!", getPlayerName(player), offer.price), offer.owner, 0, 255, 0)
end)

-- House upgrade system
addCommandHandler("upgrade", function(player, cmd, upgradeType)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.house or playerData.house <= 0 then
        outputChatBox("❌ Ban khong co nha.", player, 255, 100, 100)
        return
    end
    
    if not playerData.inHouse or playerData.inHouse ~= playerData.house then
        outputChatBox("❌ Ban can o trong nha de upgrade.", player, 255, 100, 100)
        return
    end
    
    if not upgradeType then
        outputChatBox("Su dung: /upgrade [security/furniture/garage]", player, 255, 255, 255)
        return
    end
    
    local houses = getElementData(getResourceRootElement(), "houses") or {}
    local house = houses[playerData.house]
    
    if not house then
        outputChatBox("❌ Khong tim thay nha cua ban.", player, 255, 100, 100)
        return
    end
    
    house.upgrades = house.upgrades or {}
    
    if upgradeType == "security" then
        if house.upgrades.security then
            outputChatBox("❌ Nha da co security system roi.", player, 255, 100, 100)
            return
        end
        
        local cost = 5000
        if (playerData.money or 0) < cost then
            outputChatBox(string.format("❌ Ban can $%d de upgrade security.", cost), player, 255, 100, 100)
            return
        end
        
        playerData.money = (playerData.money or 0) - cost
        house.upgrades.security = true
        
        outputChatBox("🔒 Da upgrade security system!", player, 0, 255, 0)
        
    elseif upgradeType == "furniture" then
        if house.upgrades.furniture then
            outputChatBox("❌ Nha da co furniture upgrade roi.", player, 255, 100, 100)
            return
        end
        
        local cost = 8000
        if (playerData.money or 0) < cost then
            outputChatBox(string.format("❌ Ban can $%d de upgrade furniture.", cost), player, 255, 100, 100)
            return
        end
        
        playerData.money = (playerData.money or 0) - cost
        house.upgrades.furniture = true
        
        outputChatBox("🛋️ Da upgrade furniture!", player, 0, 255, 0)
        
    elseif upgradeType == "garage" then
        if house.upgrades.garage then
            outputChatBox("❌ Nha da co garage roi.", player, 255, 100, 100)
            return
        end
        
        local cost = 15000
        if (playerData.money or 0) < cost then
            outputChatBox(string.format("❌ Ban can $%d de upgrade garage.", cost), player, 255, 100, 100)
            return
        end
        
        playerData.money = (playerData.money or 0) - cost
        house.upgrades.garage = true
        
        outputChatBox("🚗 Da upgrade garage!", player, 0, 255, 0)
    end
    
    setElementData(player, "playerData", playerData)
    houses[playerData.house] = house
    setElementData(getResourceRootElement(), "houses", houses)
end)

-- House help
addCommandHandler("househelp", function(player)
    outputChatBox("🏠 ===== HOUSE COMMANDS =====", player, 255, 255, 0)
    outputChatBox("• /buyhouse - Mua nha", player, 255, 255, 255)
    outputChatBox("• /sellhouse [player] - Ban nha", player, 255, 255, 255)
    outputChatBox("• /lock - Khoa/mo nha", player, 255, 255, 255)
    outputChatBox("• /enter - Vao nha", player, 255, 255, 255)
    outputChatBox("• /exit - Ra khoi nha", player, 255, 255, 255)
    outputChatBox("• /houseinfo - Thong tin nha", player, 255, 255, 255)
    outputChatBox("• /rent [player] [price] - Cho thue nha", player, 255, 255, 255)
    outputChatBox("• /acceptrent - Chap nhan thue nha", player, 255, 255, 255)
    outputChatBox("• /upgrade [type] - Upgrade nha", player, 255, 255, 255)
end)

outputDebugString("[AMB] Property/House system loaded - 11 commands")
