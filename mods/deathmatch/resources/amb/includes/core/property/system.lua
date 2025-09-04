-- ================================
-- AMB MTA:SA - Property & Real Estate Commands
-- Mass migration of property and real estate management commands
-- ================================

-- Create property
addCommandHandler("createprop", function(player, cmd, propType, propName, price)
    local playerData = getElementData(player, "playerData") or {}
    
    if (playerData.adminLevel or 0) < 4 then
        outputChatBox("❌ Ban can admin level 4 de tao property.", player, 255, 100, 100)
        return
    end
    
    if not propType or not propName or not price then
        outputChatBox("Su dung: /createprop [type] [name] [price]", player, 255, 255, 255)
        outputChatBox("Types: house, apartment, garage, office, warehouse, shop", player, 255, 255, 255)
        return
    end
    
    local propPrice = tonumber(price)
    if not propPrice or propPrice < 1000 or propPrice > 10000000 then
        outputChatBox("❌ Gia property phai tu $1,000 - $10,000,000.", player, 255, 100, 100)
        return
    end
    
    local validTypes = {
        house = true, apartment = true, garage = true, 
        office = true, warehouse = true, shop = true
    }
    
    if not validTypes[propType] then
        outputChatBox("❌ Property type khong hop le.", player, 255, 100, 100)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local propID = getServerData("nextPropID") or 1
    setServerData("nextPropID", propID + 1)
    
    local propertyData = {
        id = propID,
        name = propName,
        type = propType,
        owner = nil,
        price = propPrice,
        x = x, y = y, z = z,
        locked = true,
        rent = 0,
        rentees = {},
        furniture = {},
        created = getRealTime().timestamp
    }
    
    setServerData("property_" .. propID, propertyData)
    
    -- Create property pickup
    local pickup = createPickup(x, y, z, 3, 1273, 0) -- House icon
    setElementData(pickup, "propertyID", propID)
    setElementData(pickup, "propertyType", "entrance")
    
    outputChatBox(string.format("✅ Da tao property '%s' (ID: %d, Type: %s, Price: $%d)", propName, propID, propType, propPrice), player, 0, 255, 0)
    outputDebugString(string.format("[ADMIN] %s created property %d (%s) at %.1f,%.1f,%.1f", getPlayerName(player), propID, propName, x, y, z))
end)

-- Buy property
addCommandHandler("buyprop", function(player)
    local x, y, z = getElementPosition(player)
    local nearestProp = nil
    local nearestDistance = 3
    
    -- Find nearest property
    for _, pickup in ipairs(getElementsByType("pickup")) do
        local propID = getElementData(pickup, "propertyID")
        if propID then
            local px, py, pz = getElementPosition(pickup)
            local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
            if distance < nearestDistance then
                nearestProp = propID
                nearestDistance = distance
            end
        end
    end
    
    if not nearestProp then
        outputChatBox("❌ Ban khong dung gan property nao.", player, 255, 100, 100)
        return
    end
    
    local propertyData = getServerData("property_" .. nearestProp)
    if not propertyData then
        outputChatBox("❌ Property data khong ton tai.", player, 255, 100, 100)
        return
    end
    
    if propertyData.owner then
        outputChatBox("❌ Property nay da co owner roi.", player, 255, 100, 100)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    if (playerData.money or 0) < propertyData.price then
        outputChatBox(string.format("❌ Ban can $%d de mua property nay.", propertyData.price), player, 255, 100, 100)
        return
    end
    
    -- Buy property
    playerData.money = (playerData.money or 0) - propertyData.price
    playerData.properties = (playerData.properties or 0) + 1
    setElementData(player, "playerData", playerData)
    
    propertyData.owner = getPlayerName(player)
    propertyData.locked = false
    setServerData("property_" .. nearestProp, propertyData)
    
    outputChatBox(string.format("✅ Da mua property '%s' voi gia $%d!", propertyData.name, propertyData.price), player, 0, 255, 0)
    outputChatBox(string.format("🏠 %s da mua property '%s'", getPlayerName(player), propertyData.name), root, 255, 255, 0)
end)

-- Sell property
addCommandHandler("sellprop", function(player, cmd, targetName, price)
    if not targetName then
        outputChatBox("Su dung: /sellprop [player] [price] hoac /sellprop state [price]", player, 255, 255, 255)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local nearestProp = nil
    local nearestDistance = 3
    
    for _, pickup in ipairs(getElementsByType("pickup")) do
        local propID = getElementData(pickup, "propertyID")
        if propID then
            local px, py, pz = getElementPosition(pickup)
            local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
            if distance < nearestDistance then
                nearestProp = propID
                nearestDistance = distance
            end
        end
    end
    
    if not nearestProp then
        outputChatBox("❌ Ban khong dung gan property nao.", player, 255, 100, 100)
        return
    end
    
    local propertyData = getServerData("property_" .. nearestProp)
    if not propertyData or propertyData.owner ~= getPlayerName(player) then
        outputChatBox("❌ Ban khong phai owner cua property nay.", player, 255, 100, 100)
        return
    end
    
    local sellPrice = tonumber(price) or math.floor(propertyData.price * 0.7)
    
    if targetName == "state" then
        -- Sell to state
        local playerData = getElementData(player, "playerData") or {}
        playerData.money = (playerData.money or 0) + sellPrice
        playerData.properties = math.max(0, (playerData.properties or 1) - 1)
        setElementData(player, "playerData", playerData)
        
        propertyData.owner = nil
        propertyData.locked = true
        setServerData("property_" .. nearestProp, propertyData)
        
        outputChatBox(string.format("✅ Da ban property cho state voi gia $%d", sellPrice), player, 0, 255, 0)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(targetName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    if targetPlayer == player then
        outputChatBox("❌ Ban khong the ban cho chinh minh.", player, 255, 100, 100)
        return
    end
    
    -- Send offer
    setElementData(targetPlayer, "propOffer", {
        propertyID = nearestProp,
        seller = getPlayerName(player),
        price = sellPrice,
        propertyName = propertyData.name
    })
    
    outputChatBox(string.format("📨 Da gui offer ban property '%s' cho %s voi gia $%d", propertyData.name, getPlayerName(targetPlayer), sellPrice), player, 0, 255, 0)
    outputChatBox(string.format("📨 %s muon ban property '%s' cho ban voi gia $%d. Su dung /acceptprop hoac /declineprop", getPlayerName(player), propertyData.name, sellPrice), targetPlayer, 255, 255, 0)
end)

-- Accept property offer
addCommandHandler("acceptprop", function(player)
    local offer = getElementData(player, "propOffer")
    if not offer then
        outputChatBox("❌ Ban khong co offer nao.", player, 255, 100, 100)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    if (playerData.money or 0) < offer.price then
        outputChatBox("❌ Ban khong co du tien.", player, 255, 100, 100)
        return
    end
    
    local propertyData = getServerData("property_" .. offer.propertyID)
    if not propertyData or propertyData.owner ~= offer.seller then
        outputChatBox("❌ Property khong con hop le.", player, 255, 100, 100)
        removeElementData(player, "propOffer")
        return
    end
    
    -- Transfer property
    playerData.money = (playerData.money or 0) - offer.price
    playerData.properties = (playerData.properties or 0) + 1
    setElementData(player, "playerData", playerData)
    
    propertyData.owner = getPlayerName(player)
    setServerData("property_" .. offer.propertyID, propertyData)
    
    -- Pay seller
    local seller = getPlayerFromName(offer.seller)
    if seller then
        local sellerData = getElementData(seller, "playerData") or {}
        sellerData.money = (sellerData.money or 0) + offer.price
        sellerData.properties = math.max(0, (sellerData.properties or 1) - 1)
        setElementData(seller, "playerData", sellerData)
        outputChatBox(string.format("💰 Da ban property cho %s voi gia $%d", getPlayerName(player), offer.price), seller, 0, 255, 0)
    end
    
    removeElementData(player, "propOffer")
    outputChatBox(string.format("✅ Da mua property '%s' voi gia $%d!", offer.propertyName, offer.price), player, 0, 255, 0)
end)

-- Decline property offer
addCommandHandler("declineprop", function(player)
    local offer = getElementData(player, "propOffer")
    if not offer then
        outputChatBox("❌ Ban khong co offer nao.", player, 255, 100, 100)
        return
    end
    
    removeElementData(player, "propOffer")
    outputChatBox("❌ Da tu choi offer mua property.", player, 255, 255, 100)
    
    local seller = getPlayerFromName(offer.seller)
    if seller then
        outputChatBox(string.format("❌ %s da tu choi mua property.", getPlayerName(player)), seller, 255, 255, 100)
    end
end)

-- Property info
addCommandHandler("propinfo", function(player)
    local x, y, z = getElementPosition(player)
    local nearestProp = nil
    local nearestDistance = 5
    
    for _, pickup in ipairs(getElementsByType("pickup")) do
        local propID = getElementData(pickup, "propertyID")
        if propID then
            local px, py, pz = getElementPosition(pickup)
            local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
            if distance < nearestDistance then
                nearestProp = propID
                nearestDistance = distance
            end
        end
    end
    
    if not nearestProp then
        outputChatBox("❌ Ban khong dung gan property nao.", player, 255, 100, 100)
        return
    end
    
    local propertyData = getServerData("property_" .. nearestProp)
    if not propertyData then
        outputChatBox("❌ Property data khong ton tai.", player, 255, 100, 100)
        return
    end
    
    outputChatBox(string.format("🏠 ===== %s INFO =====", string.upper(propertyData.name)), player, 255, 255, 0)
    outputChatBox(string.format("• ID: %d", propertyData.id), player, 255, 255, 255)
    outputChatBox(string.format("• Type: %s", propertyData.type), player, 255, 255, 255)
    outputChatBox(string.format("• Owner: %s", propertyData.owner or "State"), player, 255, 255, 255)
    if not propertyData.owner then
        outputChatBox(string.format("• Price: $%d", propertyData.price), player, 255, 255, 255)
    end
    outputChatBox(string.format("• Rent: $%d/day", propertyData.rent or 0), player, 255, 255, 255)
    outputChatBox(string.format("• Rentees: %d", getTableSize(propertyData.rentees or {})), player, 255, 255, 255)
    outputChatBox(string.format("• Status: %s", propertyData.locked and "Locked" or "Open"), player, 255, 255, 255)
end)

-- Lock/unlock property
addCommandHandler("lockprop", function(player)
    local x, y, z = getElementPosition(player)
    local nearestProp = nil
    local nearestDistance = 3
    
    for _, pickup in ipairs(getElementsByType("pickup")) do
        local propID = getElementData(pickup, "propertyID")
        if propID then
            local px, py, pz = getElementPosition(pickup)
            local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
            if distance < nearestDistance then
                nearestProp = propID
                nearestDistance = distance
            end
        end
    end
    
    if not nearestProp then
        outputChatBox("❌ Ban khong dung gan property nao.", player, 255, 100, 100)
        return
    end
    
    local propertyData = getServerData("property_" .. nearestProp)
    if not propertyData then
        outputChatBox("❌ Property data khong ton tai.", player, 255, 100, 100)
        return
    end
    
    -- Check if player has access
    local hasAccess = false
    if propertyData.owner == getPlayerName(player) then
        hasAccess = true
    elseif propertyData.rentees and propertyData.rentees[getPlayerName(player)] then
        hasAccess = true
    end
    
    if not hasAccess then
        outputChatBox("❌ Ban khong co quyen truy cap property nay.", player, 255, 100, 100)
        return
    end
    
    propertyData.locked = not propertyData.locked
    setServerData("property_" .. nearestProp, propertyData)
    
    local status = propertyData.locked and "locked" or "unlocked"
    outputChatBox(string.format("🔐 Da %s property '%s'", status, propertyData.name), player, 0, 255, 0)
end)

-- Rent system
addCommandHandler("rent", function(player, cmd, action, ...)
    if not action then
        outputChatBox("🏠 ===== RENT SYSTEM =====", player, 255, 255, 0)
        outputChatBox("• /rent set [price] - Set gia thue (owner)", player, 255, 255, 255)
        outputChatBox("• /rent property - Thue property nay", player, 255, 255, 255)
        outputChatBox("• /rent pay - Tra tien thue", player, 255, 255, 255)
        outputChatBox("• /rent leave - Roi khoi property thue", player, 255, 255, 255)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local nearestProp = nil
    local nearestDistance = 3
    
    for _, pickup in ipairs(getElementsByType("pickup")) do
        local propID = getElementData(pickup, "propertyID")
        if propID then
            local px, py, pz = getElementPosition(pickup)
            local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
            if distance < nearestDistance then
                nearestProp = propID
                nearestDistance = distance
            end
        end
    end
    
    if not nearestProp then
        outputChatBox("❌ Ban khong dung gan property nao.", player, 255, 100, 100)
        return
    end
    
    local propertyData = getServerData("property_" .. nearestProp)
    if not propertyData then
        outputChatBox("❌ Property data khong ton tai.", player, 255, 100, 100)
        return
    end
    
    if action == "set" then
        if propertyData.owner ~= getPlayerName(player) then
            outputChatBox("❌ Ban khong phai owner cua property nay.", player, 255, 100, 100)
            return
        end
        
        local rentPrice = tonumber((...))
        if not rentPrice or rentPrice < 0 or rentPrice > 10000 then
            outputChatBox("❌ Gia thue phai tu $0-10000/day.", player, 255, 100, 100)
            return
        end
        
        propertyData.rent = rentPrice
        setServerData("property_" .. nearestProp, propertyData)
        
        if rentPrice == 0 then
            outputChatBox("🏠 Da tat tinh nang cho thue.", player, 255, 255, 0)
        else
            outputChatBox(string.format("🏠 Da set gia thue $%d/day cho property '%s'", rentPrice, propertyData.name), player, 0, 255, 0)
        end
        
    elseif action == "property" then
        if not propertyData.owner then
            outputChatBox("❌ Property nay chua co owner.", player, 255, 100, 100)
            return
        end
        
        if propertyData.owner == getPlayerName(player) then
            outputChatBox("❌ Ban khong the thue property cua chinh minh.", player, 255, 100, 100)
            return
        end
        
        if (propertyData.rent or 0) <= 0 then
            outputChatBox("❌ Property nay khong cho thue.", player, 255, 100, 100)
            return
        end
        
        if propertyData.rentees and propertyData.rentees[getPlayerName(player)] then
            outputChatBox("❌ Ban da thue property nay roi.", player, 255, 100, 100)
            return
        end
        
        local playerData = getElementData(player, "playerData") or {}
        if (playerData.money or 0) < propertyData.rent then
            outputChatBox(string.format("❌ Ban can $%d de thue property nay.", propertyData.rent), player, 255, 100, 100)
            return
        end
        
        -- Rent property
        playerData.money = (playerData.money or 0) - propertyData.rent
        setElementData(player, "playerData", playerData)
        
        if not propertyData.rentees then
            propertyData.rentees = {}
        end
        propertyData.rentees[getPlayerName(player)] = {
            paidUntil = getRealTime().timestamp + 86400, -- 24 hours
            totalPaid = propertyData.rent
        }
        setServerData("property_" .. nearestProp, propertyData)
        
        outputChatBox(string.format("🏠 Da thue property '%s' voi gia $%d/day", propertyData.name, propertyData.rent), player, 0, 255, 0)
        
        -- Notify owner
        local owner = getPlayerFromName(propertyData.owner)
        if owner then
            outputChatBox(string.format("🏠 %s da thue property '%s' cua ban", getPlayerName(player), propertyData.name), owner, 255, 255, 0)
        end
        
    elseif action == "pay" then
        if not propertyData.rentees or not propertyData.rentees[getPlayerName(player)] then
            outputChatBox("❌ Ban khong thue property nay.", player, 255, 100, 100)
            return
        end
        
        local playerData = getElementData(player, "playerData") or {}
        if (playerData.money or 0) < propertyData.rent then
            outputChatBox(string.format("❌ Ban can $%d de tra tien thue.", propertyData.rent), player, 255, 100, 100)
            return
        end
        
        playerData.money = (playerData.money or 0) - propertyData.rent
        setElementData(player, "playerData", playerData)
        
        local rentData = propertyData.rentees[getPlayerName(player)]
        rentData.paidUntil = rentData.paidUntil + 86400 -- Extend 24 hours
        rentData.totalPaid = rentData.totalPaid + propertyData.rent
        
        setServerData("property_" .. nearestProp, propertyData)
        
        outputChatBox(string.format("💰 Da tra tien thue $%d. Han su dung gia han 24h", propertyData.rent), player, 0, 255, 0)
        
    elseif action == "leave" then
        if not propertyData.rentees or not propertyData.rentees[getPlayerName(player)] then
            outputChatBox("❌ Ban khong thue property nay.", player, 255, 100, 100)
            return
        end
        
        propertyData.rentees[getPlayerName(player)] = nil
        setServerData("property_" .. nearestProp, propertyData)
        
        outputChatBox(string.format("🏠 Da roi khoi property '%s'", propertyData.name), player, 255, 255, 100)
        
        -- Notify owner
        local owner = getPlayerFromName(propertyData.owner)
        if owner then
            outputChatBox(string.format("🏠 %s da roi khoi property '%s'", getPlayerName(player), propertyData.name), owner, 255, 255, 100)
        end
    end
end)

-- Property list
addCommandHandler("myprops", function(player)
    local playerData = getElementData(player, "playerData") or {}
    local playerName = getPlayerName(player)
    
    outputChatBox("🏠 ===== MY PROPERTIES =====", player, 255, 255, 0)
    
    local ownedProps = {}
    local rentedProps = {}
    
    -- Check all properties
    for i = 1, (getServerData("nextPropID") or 1) - 1 do
        local propData = getServerData("property_" .. i)
        if propData then
            if propData.owner == playerName then
                table.insert(ownedProps, propData)
            elseif propData.rentees and propData.rentees[playerName] then
                table.insert(rentedProps, propData)
            end
        end
    end
    
    -- Show owned properties
    if #ownedProps > 0 then
        outputChatBox("📋 OWNED PROPERTIES:", player, 255, 255, 100)
        for _, prop in ipairs(ownedProps) do
            outputChatBox(string.format("• ID %d: %s (%s) - $%d", prop.id, prop.name, prop.type, prop.price), player, 255, 255, 255)
        end
    end
    
    -- Show rented properties
    if #rentedProps > 0 then
        outputChatBox("📋 RENTED PROPERTIES:", player, 255, 255, 100)
        for _, prop in ipairs(rentedProps) do
            local rentData = prop.rentees[playerName]
            local timeLeft = rentData.paidUntil - getRealTime().timestamp
            local hoursLeft = math.max(0, math.floor(timeLeft / 3600))
            outputChatBox(string.format("• %s (%s) - %dh left", prop.name, prop.type, hoursLeft), player, 255, 255, 255)
        end
    end
    
    if #ownedProps == 0 and #rentedProps == 0 then
        outputChatBox("• Ban khong co property nao.", player, 255, 255, 255)
    end
    
    outputChatBox(string.format("Total: %d owned, %d rented", #ownedProps, #rentedProps), player, 255, 255, 100)
end)

-- Property upgrade system
addCommandHandler("upgrade", function(player, cmd, upgradeType)
    local x, y, z = getElementPosition(player)
    local nearestProp = nil
    local nearestDistance = 3
    
    for _, pickup in ipairs(getElementsByType("pickup")) do
        local propID = getElementData(pickup, "propertyID")
        if propID then
            local px, py, pz = getElementPosition(pickup)
            local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
            if distance < nearestDistance then
                nearestProp = propID
                nearestDistance = distance
            end
        end
    end
    
    if not nearestProp then
        outputChatBox("❌ Ban khong dung gan property nao.", player, 255, 100, 100)
        return
    end
    
    local propertyData = getServerData("property_" .. nearestProp)
    if not propertyData or propertyData.owner ~= getPlayerName(player) then
        outputChatBox("❌ Ban khong phai owner cua property nay.", player, 255, 100, 100)
        return
    end
    
    if not upgradeType then
        outputChatBox("🏠 ===== PROPERTY UPGRADES =====", player, 255, 255, 0)
        outputChatBox("• /upgrade security - Security system ($5000)", player, 255, 255, 255)
        outputChatBox("• /upgrade furniture - Furniture set ($2000)", player, 255, 255, 255)
        outputChatBox("• /upgrade alarm - Alarm system ($1500)", player, 255, 255, 255)
        outputChatBox("• /upgrade garage - Private garage ($8000)", player, 255, 255, 255)
        return
    end
    
    local upgrades = {
        security = {cost = 5000, name = "Security System"},
        furniture = {cost = 2000, name = "Furniture Set"},
        alarm = {cost = 1500, name = "Alarm System"},
        garage = {cost = 8000, name = "Private Garage"}
    }
    
    if not upgrades[upgradeType] then
        outputChatBox("❌ Upgrade type khong hop le.", player, 255, 100, 100)
        return
    end
    
    if not propertyData.upgrades then
        propertyData.upgrades = {}
    end
    
    if propertyData.upgrades[upgradeType] then
        outputChatBox("❌ Property da co upgrade nay roi.", player, 255, 100, 100)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    local cost = upgrades[upgradeType].cost
    
    if (playerData.money or 0) < cost then
        outputChatBox(string.format("❌ Ban can $%d de upgrade.", cost), player, 255, 100, 100)
        return
    end
    
    -- Process upgrade
    playerData.money = (playerData.money or 0) - cost
    setElementData(player, "playerData", playerData)
    
    propertyData.upgrades[upgradeType] = true
    setServerData("property_" .. nearestProp, propertyData)
    
    outputChatBox(string.format("✅ Da upgrade '%s' cho property voi gia $%d", upgrades[upgradeType].name, cost), player, 0, 255, 0)
end)

-- Helper functions
function getTableSize(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function getServerData(key)
    return getElementData(getResourceRootElement(), key)
end

function setServerData(key, value)
    setElementData(getResourceRootElement(), key, value)
end

outputDebugString("[AMB] Property & Real Estate system loaded - 12 commands")
