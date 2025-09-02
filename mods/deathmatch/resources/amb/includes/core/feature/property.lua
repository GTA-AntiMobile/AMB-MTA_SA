-- ================================
-- AMB MTA:SA - Property & Business System
-- Migrated from SA-MP open.mp server
-- ================================

-- Property and business management system
local propertySystem = {
    houses = {},
    rentals = {},
    businesses = {},
    auctions = {},
    mailboxes = {},
    nextHouseID = 1,
    nextBusinessID = 1,
    nextMailID = 1
}

-- House buying system
addCommandHandler("buyhouse", function(player, _, houseID)
    if not houseID then
        outputChatBox("Su dung: /buyhouse [ID]", player, 255, 255, 255)
        outputChatBox("Hoac dung trong checkpoint cua nha de mua", player, 255, 255, 255)
        return
    end
    
    local id = tonumber(houseID)
    if not id or not propertySystem.houses[id] then
        outputChatBox("ID nha khong ton tai!", player, 255, 0, 0)
        return
    end
    
    local house = propertySystem.houses[id]
    
    if house.owner then
        outputChatBox("Nha nay da co chu! Chu nha: " .. house.owner, player, 255, 0, 0)
        return
    end
    
    local money = getPlayerMoney(player)
    if money < house.price then
        outputChatBox("Ban khong co du tien! Can: $" .. house.price, player, 255, 0, 0)
        return
    end
    
    -- Check if player already owns a house
    for _, h in pairs(propertySystem.houses) do
        if h.owner == getPlayerName(player) then
            outputChatBox("Ban da co nha roi! Chi duoc so huu 1 nha!", player, 255, 0, 0)
            return
        end
    end
    
    -- Buy house
    takePlayerMoney(player, house.price)
    house.owner = getPlayerName(player)
    house.locked = true
    
    outputChatBox("Chuc mung! Ban da mua nha ID " .. id .. " voi gia $" .. house.price, player, 0, 255, 0)
    outputChatBox("Su dung /spawnathome de spawn tai nha", player, 255, 255, 255)
    
    -- Update house pickup
    if house.pickup then
        destroyElement(house.pickup)
    end
    house.pickup = createPickup(house.x, house.y, house.z, 3, 1273) -- House pickup
    
    -- Log purchase
    local message = string.format("[PROPERTY] %s bought house ID %d for $%d", 
        getPlayerName(player), id, house.price)
    print(message)
end)

-- Vietnamese house rental
addCommandHandler("thuenha", function(player, _, action, ...)
    if not action then
        outputChatBox("Su dung: /thuenha [thue/traphong/listroom]", player, 255, 255, 255)
        return
    end
    
    if action == "thue" then
        executeCommandHandler("rentroom", player, "rentroom", ...)
    elseif action == "traphong" then
        executeCommandHandler("unrent", player)
    elseif action == "listroom" then
        outputChatBox("=== Cac phong co the thue ===", player, 255, 255, 0)
        local count = 0
        for id, rental in pairs(propertySystem.rentals) do
            if not rental.tenant then
                outputChatBox(string.format("ID %d: %s - $%d/day", 
                    id, rental.name, rental.price), player, 255, 255, 255)
                count = count + 1
            end
        end
        if count == 0 then
            outputChatBox("Khong co phong nao trong!", player, 255, 255, 0)
        end
    end
end)

-- Rent room system
addCommandHandler("rentroom", function(player, _, roomID)
    if not roomID then
        outputChatBox("Su dung: /rentroom [ID]", player, 255, 255, 255)
        return
    end
    
    local id = tonumber(roomID)
    if not id or not propertySystem.rentals[id] then
        outputChatBox("ID phong khong ton tai!", player, 255, 0, 0)
        return
    end
    
    local rental = propertySystem.rentals[id]
    
    if rental.tenant then
        outputChatBox("Phong nay da co nguoi thue! Nguoi thue: " .. rental.tenant, player, 255, 0, 0)
        return
    end
    
    local money = getPlayerMoney(player)
    if money < rental.price then
        outputChatBox("Ban khong co du tien! Can: $" .. rental.price .. "/ngay", player, 255, 0, 0)
        return
    end
    
    -- Check if player already renting
    for _, r in pairs(propertySystem.rentals) do
        if r.tenant == getPlayerName(player) then
            outputChatBox("Ban da thue phong roi! Chi duoc thue 1 phong!", player, 255, 0, 0)
            return
        end
    end
    
    -- Rent room
    takePlayerMoney(player, rental.price)
    rental.tenant = getPlayerName(player)
    rental.rentTime = getRealTime().timestamp
    
    outputChatBox("Ban da thue phong " .. rental.name .. " voi gia $" .. rental.price .. "/ngay", player, 0, 255, 0)
    outputChatBox("Su dung /spawnathome de spawn tai phong thue", player, 255, 255, 255)
    
    -- Log rental
    local message = string.format("[RENTAL] %s rented room %s (ID %d) for $%d/day", 
        getPlayerName(player), rental.name, id, rental.price)
    print(message)
end)

-- Unrent room
addCommandHandler("unrent", function(player)
    local playerName = getPlayerName(player)
    local found = false
    
    for id, rental in pairs(propertySystem.rentals) do
        if rental.tenant == playerName then
            rental.tenant = nil
            rental.rentTime = nil
            outputChatBox("Ban da tra phong " .. rental.name, player, 255, 255, 0)
            found = true
            break
        end
    end
    
    if not found then
        outputChatBox("Ban khong thue phong nao!", player, 255, 0, 0)
    end
end)

-- Spawn at home
addCommandHandler("spawnathome", function(player)
    local playerName = getPlayerName(player)
    local spawned = false
    
    -- Check owned house
    for id, house in pairs(propertySystem.houses) do
        if house.owner == playerName then
            setElementPosition(player, house.interiorX, house.interiorY, house.interiorZ)
            setElementInterior(player, house.interior)
            setElementDimension(player, id)
            outputChatBox("Da spawn tai nha cua ban", player, 0, 255, 0)
            spawned = true
            break
        end
    end
    
    -- Check rented room
    if not spawned then
        for id, rental in pairs(propertySystem.rentals) do
            if rental.tenant == playerName then
                setElementPosition(player, rental.x, rental.y, rental.z)
                setElementInterior(player, rental.interior or 0)
                setElementDimension(player, 1000 + id)
                outputChatBox("Da spawn tai phong thue cua ban", player, 0, 255, 0)
                spawned = true
                break
            end
        end
    end
    
    if not spawned then
        outputChatBox("Ban khong co nha hoac phong thue nao!", player, 255, 0, 0)
    end
end)

-- Business system
addCommandHandler("businesshelp", function(player)
    outputChatBox("=== Business Commands ===", player, 255, 255, 0)
    outputChatBox("/shop - Mua do tai cua hang", player, 255, 255, 255)
    outputChatBox("/bhelp - Giup do ve business", player, 255, 255, 255)
    outputChatBox("/auctions - Xem cac cuoc dau gia", player, 255, 255, 255)
    outputChatBox("/editauctions - Admin: Chinh sua dau gia", player, 255, 255, 255)
    outputChatBox("/mua [item] - Mua do tai cua hang", player, 255, 255, 255)
end)

addCommandHandler("bhelp", function(player)
    outputChatBox("=== Business Help ===", player, 255, 255, 0)
    outputChatBox("Cac loai business:", player, 255, 255, 255)
    outputChatBox("1. Cua hang tong hop - Ban thuc pham, nuoc", player, 255, 255, 255)
    outputChatBox("2. Cua hang vu khi - Ban vu khi, dan", player, 255, 255, 255)
    outputChatBox("3. Garage - Sua xe, tuning", player, 255, 255, 255)
    outputChatBox("4. Nha hang - Ban thuc an", player, 255, 255, 255)
    outputChatBox("5. Bar - Ban ruou bia", player, 255, 255, 255)
end)

-- Shop system
addCommandHandler("shop", function(player)
    -- Find nearest business
    local nearestBiz = nil
    local nearestDist = 999999
    local px, py, pz = getElementPosition(player)
    
    for id, biz in pairs(propertySystem.businesses) do
        local dist = getDistanceBetweenPoints3D(px, py, pz, biz.x, biz.y, biz.z)
        if dist < nearestDist and dist <= 5 then
            nearestDist = dist
            nearestBiz = {id = id, data = biz}
        end
    end
    
    if not nearestBiz then
        outputChatBox("Ban khong o gan cua hang nao!", player, 255, 0, 0)
        return
    end
    
    local biz = nearestBiz.data
    local items = ""
    
    if biz.type == "general" then
        items = "Food ($50)|Water ($30)|Cigarettes ($20)|Phone Card ($100)"
    elseif biz.type == "weapon" then
        items = "Pistol ($500)|Shotgun ($1000)|SMG ($1500)|Rifle ($2000)"
    elseif biz.type == "restaurant" then
        items = "Burger ($25)|Pizza ($30)|Chicken ($35)|Drink ($15)"
    elseif biz.type == "bar" then
        items = "Beer ($40)|Wine ($60)|Whiskey ($80)|Vodka ($100)"
    else
        items = "Basic Item ($10)|Premium Item ($50)"
    end
    
    showDialog(player, "BUSINESS_SHOP", "Cua hang: " .. biz.name, 
        "Chon item ban muon mua:\n\n" .. string.gsub(items, "|", "\n"), 
        "Mua", "Huy")
end)

-- Vietnamese buy command
addCommandHandler("mua", function(player, _, ...)
    local item = table.concat({...}, " ")
    if not item or item == "" then
        outputChatBox("Su dung: /mua [ten item]", player, 255, 255, 255)
        outputChatBox("Vi du: /mua food, /mua water, /mua phone", player, 255, 255, 255)
        return
    end
    
    executeCommandHandler("buy", player, "buy", ...)
end)

addCommandHandler("buy", function(player, _, ...)
    local item = table.concat({...}, " "):lower()
    
    local items = {
        food = {price = 50, name = "Food"},
        water = {price = 30, name = "Water"},
        cigarettes = {price = 20, name = "Cigarettes"},
        phone = {price = 100, name = "Phone Card"},
        beer = {price = 40, name = "Beer"},
        wine = {price = 60, name = "Wine"}
    }
    
    if not items[item] then
        outputChatBox("Item khong ton tai! Cac item co the mua:", player, 255, 0, 0)
        for itemName, itemData in pairs(items) do
            outputChatBox("- " .. itemData.name .. " ($" .. itemData.price .. ")", player, 200, 200, 200)
        end
        return
    end
    
    local itemData = items[item]
    local money = getPlayerMoney(player)
    
    if money < itemData.price then
        outputChatBox("Ban khong co du tien! Can: $" .. itemData.price, player, 255, 0, 0)
        return
    end
    
    takePlayerMoney(player, itemData.price)
    
    -- Add item to inventory (simplified)
    local currentItems = getElementData(player, "player.inventory") or {}
    currentItems[item] = (currentItems[item] or 0) + 1
    setElementData(player, "player.inventory", currentItems)
    
    outputChatBox("Ban da mua " .. itemData.name .. " voi gia $" .. itemData.price, player, 0, 255, 0)
end)

-- Mail system
addCommandHandler("mailhelp", function(player)
    outputChatBox("=== Mail System ===", player, 255, 255, 0)
    outputChatBox("/sendmail [player] [message] - Gui thu", player, 255, 255, 255)
    outputChatBox("/getmail - Xem thu den", player, 255, 255, 255)
    outputChatBox("/guithu [player] [message] - Gui thu (tieng Viet)", player, 255, 255, 255)
end)

addCommandHandler("guithu", function(player, _, playerIdOrName, ...)
    local message = table.concat({...}, " ")
    if not playerIdOrName or not message or message == "" then
        outputChatBox("Su dung: /guithu [player] [noi dung]", player, 255, 255, 255)
        return
    end
    
    executeCommandHandler("sendmail", player, "sendmail", playerIdOrName, message)
end)

addCommandHandler("sendmail", function(player, _, playerIdOrName, ...)
    local message = table.concat({...}, " ")
    if not playerIdOrName or not message or message == "" then
        outputChatBox("Su dung: /sendmail [player] [message]", player, 255, 255, 255)
        return
    end
    
    local money = getPlayerMoney(player)
    if money < 50 then
        outputChatBox("Ban can $50 de gui thu!", player, 255, 0, 0)
        return
    end
    
    takePlayerMoney(player, 50)
    
    -- Store mail
    local mailID = propertySystem.nextMailID
    propertySystem.mailboxes[mailID] = {
        to = playerIdOrName,
        from = getPlayerName(player),
        message = message,
        timestamp = getRealTime().timestamp,
        read = false
    }
    propertySystem.nextMailID = propertySystem.nextMailID + 1
    
    outputChatBox("Da gui thu cho " .. playerIdOrName .. " ($50)", player, 0, 255, 0)
    
    -- Notify recipient if online
    local target = getPlayerFromName(playerIdOrName)
    if target then
        outputChatBox("Ban co thu moi tu " .. getPlayerName(player), target, 255, 255, 0)
        outputChatBox("Su dung /getmail de doc thu", target, 255, 255, 255)
    end
end)

addCommandHandler("getmail", function(player)
    local playerName = getPlayerName(player)
    local mails = {}
    
    for id, mail in pairs(propertySystem.mailboxes) do
        if mail.to == playerName then
            table.insert(mails, {id = id, data = mail})
        end
    end
    
    if #mails == 0 then
        outputChatBox("Ban khong co thu nao!", player, 255, 255, 0)
        return
    end
    
    outputChatBox("=== Thu cua ban ===", player, 255, 255, 0)
    for i, mail in ipairs(mails) do
        local status = mail.data.read and "Da doc" or "Chua doc"
        local time = os.date("%d/%m/%Y %H:%M", mail.data.timestamp)
        
        outputChatBox(string.format("%d. Tu %s (%s) - %s", 
            i, mail.data.from, time, status), player, 255, 255, 255)
        outputChatBox("   " .. mail.data.message, player, 200, 200, 200)
        
        -- Mark as read
        mail.data.read = true
    end
end)

-- Initialize some default properties
local function initializeProperties()
    -- Add some sample houses
    propertySystem.houses[1] = {
        x = 2495.0, y = -1687.5, z = 13.5,
        interiorX = 2496.0, interiorY = -1692.0, interiorZ = 1014.7,
        interior = 3,
        price = 50000,
        owner = nil,
        locked = false,
        pickup = createPickup(2495.0, -1687.5, 13.5, 3, 1273)
    }
    
    propertySystem.houses[2] = {
        x = 2454.7, y = -1700.8, z = 13.5,
        interiorX = 266.5, interiorY = -301.0, interiorZ = 1.5,
        interior = 4,
        price = 75000,
        owner = nil,
        locked = false,
        pickup = createPickup(2454.7, -1700.8, 13.5, 3, 1273)
    }
    
    -- Add sample rentals
    propertySystem.rentals[1] = {
        name = "Motel Room A",
        x = 2233.6, y = -1159.9, z = 25.9,
        price = 200,
        tenant = nil,
        interior = 2
    }
    
    propertySystem.rentals[2] = {
        name = "Motel Room B", 
        x = 2218.2, y = -1150.5, z = 25.9,
        price = 250,
        tenant = nil,
        interior = 1
    }
    
    -- Add sample businesses
    propertySystem.businesses[1] = {
        name = "24/7 Store",
        type = "general",
        x = 1352.3, y = -1759.2, z = 13.5,
        owner = "State"
    }
    
    propertySystem.businesses[2] = {
        name = "Ammunation",
        type = "weapon", 
        x = 1368.6, y = -1279.9, z = 13.5,
        owner = "State"
    }
end

-- Initialize on resource start
addEventHandler("onResourceStart", resourceRoot, function()
    initializeProperties()
    print("Property System initialized with sample houses, rentals, and businesses")
end)

print("Property System loaded: house buying, rentals, businesses, mail system")
