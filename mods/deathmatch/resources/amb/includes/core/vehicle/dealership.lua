-- ================================
-- AMB MTA:SA - Vehicle Dealership System
-- Based on original SA-MP dealership structure
-- ================================

-- Dealership locations and data (from original cardealerships.json)
local dealerships = {
    [1] = {
        name = "San Fierro Marina Dealership",
        location = {x = -2975.834228, y = 507.075683, z = 2.429687},
        owner = "Scott_Reed", 
        type = "marine",
        vehicles = {
            {model = 473, name = "Dinghy", price = 50000},
            {model = 595, name = "Launch", price = 350000},
            {model = 452, name = "Speeder", price = 500000},
            {model = 454, name = "Tropic", price = 1000000}
        }
    },
    [2] = {
        name = "Grotti Dealership", 
        location = {x = 531.315734, y = -1292.747192, z = 17.242187},
        owner = "Nick",
        type = "sports",
        vehicles = {
            {model = 475, name = "Sabre", price = 250000},
            {model = 603, name = "Phoenix", price = 525000},
            {model = 480, name = "Comet", price = 950000},
            {model = 560, name = "Sultan", price = 1400000}
        }
    },
    [3] = {
        name = "Wang Cars",
        location = {x = -1957.033081, y = 284.379852, z = 35.468750},
        owner = "Michael_Jordan",
        type = "general",
        vehicles = {
            {model = 400, name = "Landstalker", price = 250000},
            {model = 409, name = "Stretch", price = 250000},
            {model = 477, name = "ZR-350", price = 500000},
            {model = 489, name = "Rancher", price = 350000}
        }
    }
}

-- Vehicle dealership main command
addCommandHandler("dealership", function(player, cmd)
    local x, y, z = getElementPosition(player)
    local nearDealership = nil
    
    -- Check if player is near any dealership
    for id, dealership in pairs(dealerships) do
        local distance = getDistanceBetweenPoints3D(x, y, z, dealership.location.x, dealership.location.y, dealership.location.z)
        if distance < 50 then
            nearDealership = dealership
            break
        end
    end
    
    if not nearDealership then
        outputChatBox("Ban khong o gan showroom xe nao!", player, 255, 0, 0)
        outputChatBox("Su dung /dealerships de xem danh sach showroom", player, 255, 255, 255)
        return
    end
    
    -- Show dealership info
    outputChatBox("=== " .. nearDealership.name .. " ===", player, 255, 255, 0)
    outputChatBox("Chu so huu: " .. nearDealership.owner, player, 255, 255, 255)
    outputChatBox("Loai xe: " .. nearDealership.type, player, 255, 255, 255)
    outputChatBox("=== Danh sach xe ===", player, 255, 255, 0)
    
    for i, vehicle in ipairs(nearDealership.vehicles) do
        local priceStr = formatMoney(vehicle.price)
        outputChatBox(i .. ". " .. vehicle.name .. " - $" .. priceStr, player, 255, 255, 255)
    end
    
    outputChatBox("Su dung /buyvehicle [so_thu_tu] de mua xe", player, 255, 255, 0)
    
    incrementCommandStat("vehicleCommands")
end)

-- List all dealerships
addCommandHandler("dealerships", function(player, cmd)
    outputChatBox("=== DANH SACH SHOWROOM XE ===", player, 255, 255, 0)
    
    for id, dealership in pairs(dealerships) do
        outputChatBox(id .. ". " .. dealership.name, player, 255, 255, 255)
        outputChatBox("   Vi tri: " .. math.floor(dealership.location.x) .. ", " .. math.floor(dealership.location.y), player, 200, 200, 200)
        outputChatBox("   Chu so huu: " .. dealership.owner, player, 200, 200, 200)
    end
    
    outputChatBox("Den gan showroom va su dung /dealership de xem xe", player, 255, 255, 0)
    
    incrementCommandStat("vehicleCommands")
end)

-- Buy vehicle from dealership
addCommandHandler("buyvehicle", function(player, cmd, vehicleIndex)
    if not vehicleIndex then
        outputChatBox("USAGE: /buyvehicle [so_thu_tu]", player, 255, 255, 255)
        outputChatBox("Su dung /dealership de xem danh sach xe", player, 255, 255, 255)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local nearDealership = nil
    
    -- Find nearby dealership
    for id, dealership in pairs(dealerships) do
        local distance = getDistanceBetweenPoints3D(x, y, z, dealership.location.x, dealership.location.y, dealership.location.z)
        if distance < 50 then
            nearDealership = dealership
            break
        end
    end
    
    if not nearDealership then
        outputChatBox("Ban khong o gan showroom xe nao!", player, 255, 0, 0)
        return
    end
    
    local index = tonumber(vehicleIndex)
    if not index or index < 1 or index > #nearDealership.vehicles then
        outputChatBox("So thu tu xe khong hop le!", player, 255, 0, 0)
        return
    end
    
    local vehicle = nearDealership.vehicles[index]
    local playerMoney = getPlayerMoney(player)
    
    if playerMoney < vehicle.price then
        outputChatBox("Ban khong du tien! Can: $" .. formatMoney(vehicle.price), player, 255, 0, 0)
        outputChatBox("Ban co: $" .. formatMoney(playerMoney), player, 255, 255, 0)
        return
    end
    
    -- Check vehicle limit
    local ownedVehicles = getElementData(player, "ownedVehicles") or {}
    if #ownedVehicles >= 3 then
        outputChatBox("Ban chi co the so huu toi da 3 xe!", player, 255, 0, 0)
        return
    end
    
    -- Create vehicle
    local spawnX = nearDealership.location.x + math.random(-10, 10)
    local spawnY = nearDealership.location.y + math.random(-10, 10)
    local spawnZ = nearDealership.location.z + 1
    
    local newVehicle = createVehicle(vehicle.model, spawnX, spawnY, spawnZ, 0, 0, 0)
    
    if newVehicle then
        -- Take money
        takePlayerMoney(player, vehicle.price)
        
        -- Set vehicle ownership
        setElementData(newVehicle, "owner", getPlayerName(player))
        setElementData(newVehicle, "ownerSerial", getPlayerSerial(player))
        setElementData(newVehicle, "locked", true)
        setElementData(newVehicle, "purchasePrice", vehicle.price)
        
        -- Add to owned vehicles
        table.insert(ownedVehicles, {
            vehicle = newVehicle,
            model = vehicle.model,
            name = vehicle.name,
            price = vehicle.price
        })
        setElementData(player, "ownedVehicles", ownedVehicles)
        
        outputChatBox("Chuc mung! Ban da mua " .. vehicle.name .. " voi gia $" .. formatMoney(vehicle.price), player, 0, 255, 0)
        outputChatBox("Xe da duoc tao o gan day. Su dung /lock de khoa xe.", player, 255, 255, 0)
        
        -- Log purchase
        logVehiclePurchase(player, vehicle, nearDealership.name)
    else
        outputChatBox("Loi khi tao xe! Tien da duoc hoan lai.", player, 255, 0, 0)
        givePlayerMoney(player, vehicle.price)
    end
    
    incrementCommandStat("vehicleCommands")
end)

-- Sell vehicle command
addCommandHandler("sellvehicle", function(player, cmd)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Ban phai ngoi trong xe de ban!", player, 255, 0, 0)
        return
    end
    
    local owner = getElementData(vehicle, "owner")
    if owner ~= getPlayerName(player) then
        outputChatBox("Day khong phai xe cua ban!", player, 255, 0, 0)
        return
    end
    
    local purchasePrice = getElementData(vehicle, "purchasePrice") or 100000
    local sellPrice = math.floor(purchasePrice * 0.7) -- 70% of original price
    
    -- Remove from owned vehicles
    local ownedVehicles = getElementData(player, "ownedVehicles") or {}
    for i, veh in ipairs(ownedVehicles) do
        if veh.vehicle == vehicle then
            table.remove(ownedVehicles, i)
            break
        end
    end
    setElementData(player, "ownedVehicles", ownedVehicles)
    
    -- Give money and destroy vehicle
    givePlayerMoney(player, sellPrice)
    destroyElement(vehicle)
    
    outputChatBox("Ban da ban xe va nhan duoc $" .. formatMoney(sellPrice), player, 0, 255, 0)
    
    incrementCommandStat("vehicleCommands")
end)

-- Vehicle info command
addCommandHandler("vinfo", function(player, cmd)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Ban phai ngoi trong xe!", player, 255, 0, 0)
        return
    end
    
    local owner = getElementData(vehicle, "owner") or "Khong co"
    local purchasePrice = getElementData(vehicle, "purchasePrice") or 0
    local locked = getElementData(vehicle, "locked") and "Co" or "Khong"
    local model = getElementModel(vehicle)
    local vehicleName = getVehicleName(vehicle)
    
    outputChatBox("=== THONG TIN XE ===", player, 255, 255, 0)
    outputChatBox("Ten xe: " .. vehicleName .. " (ID: " .. model .. ")", player, 255, 255, 255)
    outputChatBox("Chu so huu: " .. owner, player, 255, 255, 255)
    outputChatBox("Gia mua: $" .. formatMoney(purchasePrice), player, 255, 255, 255)
    outputChatBox("Trang thai khoa: " .. locked, player, 255, 255, 255)
    
    incrementCommandStat("vehicleCommands")
end)

-- Vehicle dealership system loaded
registerCommandSystem("Vehicle Dealership", 6, true)
