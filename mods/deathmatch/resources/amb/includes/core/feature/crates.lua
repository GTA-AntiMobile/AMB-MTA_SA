-- ================================
-- AMB MTA:SA - Crate System Commands  
-- Migrated from SA-MP open.mp server
-- ================================

-- Crate delivery system for police/gang operations
local crateSystem = {
    crates = {},
    nextID = 1,
    maxCrates = 10,
    locations = {
        {x = 1544.5, y = -1630.7, z = 13.4, name = "Los Santos Police Department"},
        {x = 2281.0, y = -1140.3, z = 25.9, name = "Unity Station"},
        {x = -1605.6, y = 711.4, z = 13.9, name = "San Fierro Police Department"},
        {x = -2441.2, y = 524.4, z = 30.0, name = "San Fierro Docks"},
        {x = 2403.8, y = 1467.5, z = 10.8, name = "Las Venturas Police Department"}
    }
}

-- List all active crates
addCommandHandler("crates", function(player)
    if not hasPermission(player, "police") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("Danh sach cac thung se duoc van chuyen (GIOI HAN: " .. crateSystem.maxCrates .. "):", player, 0, 255, 0)
    
    local count = 0
    for id, crate in pairs(crateSystem.crates) do
        count = count + 1
        local x, y, z = getElementPosition(crate.object)
        local zone = getZoneName(x, y, z)
        
        local status = "Dang cho"
        if crate.inVehicle then
            status = "Dang van chuyen (Xe: " .. getElementModel(crate.inVehicle) .. ")"
        end
        
        outputChatBox(string.format("ID %d: %s - %s - Vu khi: %d", 
            id, zone, status, crate.gunQuantity), player, 200, 200, 200)
    end
    
    if count == 0 then
        outputChatBox("Khong co thung nao dang hoat dong", player, 255, 255, 0)
    end
end)

-- Create/destroy crates (admin only)
addCommandHandler("destroycrate", function(player, _, crateID)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not crateID then
        outputChatBox("Su dung: /destroycrate [ID]", player, 255, 255, 255)
        return
    end
    
    local id = tonumber(crateID)
    if not id or not crateSystem.crates[id] then
        outputChatBox("ID thung khong ton tai!", player, 255, 0, 0)
        return
    end
    
    -- Destroy the crate
    if crateSystem.crates[id].object then
        destroyElement(crateSystem.crates[id].object)
    end
    if crateSystem.crates[id].marker then
        destroyElement(crateSystem.crates[id].marker)
    end
    
    crateSystem.crates[id] = nil
    outputChatBox("Da xoa thung ID " .. id, player, 0, 255, 0)
    
    -- Log the action
    local message = string.format("[CRATES] %s destroyed crate ID %d", getPlayerName(player), id)
    print(message)
end)

-- Admin destroy all crates
addCommandHandler("adestroycrate", function(player)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    local count = 0
    for id, crate in pairs(crateSystem.crates) do
        if crate.object then
            destroyElement(crate.object)
        end
        if crate.marker then
            destroyElement(crate.marker)
        end
        count = count + 1
    end
    
    crateSystem.crates = {}
    outputChatBox("Da xoa tat ca " .. count .. " thung", player, 0, 255, 0)
    
    -- Log the action
    local message = string.format("[CRATES] %s destroyed all crates (%d total)", getPlayerName(player), count)
    print(message)
end)

-- Go to speedcam/crate location
addCommandHandler("gotospeedcam", function(player, _, locationID)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not locationID then
        outputChatBox("Su dung: /gotospeedcam [1-5]", player, 255, 255, 255)
        outputChatBox("Cac dia diem:", player, 255, 255, 255)
        for i, loc in ipairs(crateSystem.locations) do
            outputChatBox(i .. ". " .. loc.name, player, 200, 200, 200)
        end
        return
    end
    
    local id = tonumber(locationID)
    if not id or id < 1 or id > #crateSystem.locations then
        outputChatBox("ID dia diem khong hop le! (1-5)", player, 255, 0, 0)
        return
    end
    
    local loc = crateSystem.locations[id]
    setElementPosition(player, loc.x, loc.y, loc.z)
    outputChatBox("Da dich chuyen den " .. loc.name, player, 0, 255, 0)
end)

-- Go to crate
addCommandHandler("gotocrate", function(player, _, crateID)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not crateID then
        outputChatBox("Su dung: /gotocrate [ID]", player, 255, 255, 255)
        return
    end
    
    local id = tonumber(crateID)
    if not id or not crateSystem.crates[id] then
        outputChatBox("ID thung khong ton tai!", player, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(crateSystem.crates[id].object)
    setElementPosition(player, x + 2, y, z)
    outputChatBox("Da dich chuyen den thung ID " .. id, player, 0, 255, 0)
end)

-- Cargo operations
addCommandHandler("cargo", function(player, _, action)
    if not hasPermission(player, "police") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not action then
        outputChatBox("Su dung: /cargo [create/list/info]", player, 255, 255, 255)
        return
    end
    
    if action == "create" then
        if table.size(crateSystem.crates) >= crateSystem.maxCrates then
            outputChatBox("Da dat gioi han toi da " .. crateSystem.maxCrates .. " thung!", player, 255, 0, 0)
            return
        end
        
        local x, y, z = getElementPosition(player)
        local interior = getElementInterior(player)
        local dimension = getElementDimension(player)
        
        -- Create crate object
        local crateObj = createObject(964, x, y, z, 0, 0, 0)
        setElementInterior(crateObj, interior)
        setElementDimension(crateObj, dimension)
        
        -- Create marker
        local marker = createMarker(x, y, z - 1, "cylinder", 2, 255, 255, 0, 150)
        setElementInterior(marker, interior)
        setElementDimension(marker, dimension)
        
        -- Store crate data
        local id = crateSystem.nextID
        crateSystem.crates[id] = {
            object = crateObj,
            marker = marker,
            gunQuantity = 50,
            createdBy = getPlayerName(player),
            createTime = getRealTime().timestamp,
            inVehicle = false,
            x = x, y = y, z = z,
            interior = interior,
            dimension = dimension
        }
        
        crateSystem.nextID = crateSystem.nextID + 1
        
        outputChatBox("Da tao thung ID " .. id .. " tai vi tri hien tai", player, 0, 255, 0)
        outputChatBox("Vu khi: 50 | Tao boi: " .. getPlayerName(player), player, 200, 200, 200)
        
    elseif action == "list" then
        executeCommandHandler("crates", player)
        
    elseif action == "info" then
        local nearestCrate = nil
        local nearestDist = 999999
        local px, py, pz = getElementPosition(player)
        
        for id, crate in pairs(crateSystem.crates) do
            local cx, cy, cz = getElementPosition(crate.object)
            local dist = getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz)
            if dist < nearestDist and dist <= 5 then
                nearestDist = dist
                nearestCrate = {id = id, data = crate}
            end
        end
        
        if nearestCrate then
            local crate = nearestCrate.data
            outputChatBox("Thong tin thung ID " .. nearestCrate.id .. ":", player, 0, 255, 0)
            outputChatBox("Vu khi: " .. crate.gunQuantity, player, 255, 255, 255)
            outputChatBox("Tao boi: " .. crate.createdBy, player, 255, 255, 255)
            outputChatBox("Trang thai: " .. (crate.inVehicle and "Dang van chuyen" or "Dang cho"), player, 255, 255, 255)
        else
            outputChatBox("Khong co thung nao gan day (5m)", player, 255, 0, 0)
        end
    end
end)

-- Delivery operations
addCommandHandler("delivercrate", function(player)
    if not hasPermission(player, "police") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Ban can o trong xe!", player, 255, 0, 0)
        return
    end
    
    -- Check if vehicle has crates
    local hasCrates = getElementData(vehicle, "vehicle.crates") or {}
    if #hasCrates == 0 then
        outputChatBox("Xe nay khong co thung nao!", player, 255, 0, 0)
        return
    end
    
    -- Check if near delivery location
    local px, py, pz = getElementPosition(player)
    local nearLocation = false
    
    for _, loc in ipairs(crateSystem.locations) do
        local dist = getDistanceBetweenPoints3D(px, py, pz, loc.x, loc.y, loc.z)
        if dist <= 10 then
            nearLocation = loc
            break
        end
    end
    
    if not nearLocation then
        outputChatBox("Ban can o gan dia diem giao hang!", player, 255, 0, 0)
        outputChatBox("Cac dia diem giao hang:", player, 255, 255, 255)
        for i, loc in ipairs(crateSystem.locations) do
            outputChatBox("- " .. loc.name, player, 200, 200, 200)
        end
        return
    end
    
    -- Deliver crates
    local delivered = 0
    local totalReward = 0
    
    for _, crateID in ipairs(hasCrates) do
        if crateSystem.crates[crateID] then
            local gunQuantity = crateSystem.crates[crateID].gunQuantity
            local reward = gunQuantity * 100 -- $100 per gun
            totalReward = totalReward + reward
            delivered = delivered + 1
            
            -- Remove crate
            if crateSystem.crates[crateID].object then
                destroyElement(crateSystem.crates[crateID].object)
            end
            if crateSystem.crates[crateID].marker then
                destroyElement(crateSystem.crates[crateID].marker)
            end
            crateSystem.crates[crateID] = nil
        end
    end
    
    -- Clear vehicle crates
    setElementData(vehicle, "vehicle.crates", {})
    
    -- Give reward
    givePlayerMoney(player, totalReward)
    
    outputChatBox("Da giao " .. delivered .. " thung tai " .. nearLocation.name, player, 0, 255, 0)
    outputChatBox("Thuong: $" .. totalReward, player, 0, 255, 0)
    
    -- Log the delivery
    local message = string.format("[CRATES] %s delivered %d crates at %s for $%d", 
        getPlayerName(player), delivered, nearLocation.name, totalReward)
    print(message)
end)

-- Load/unload crates
addCommandHandler("loadcrate", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Ban can o trong xe!", player, 255, 0, 0)
        return
    end
    
    -- Find nearest crate
    local nearestCrate = nil
    local nearestDist = 999999
    local px, py, pz = getElementPosition(player)
    
    for id, crate in pairs(crateSystem.crates) do
        if not crate.inVehicle then
            local cx, cy, cz = getElementPosition(crate.object)
            local dist = getDistanceBetweenPoints3D(px, py, pz, cx, cy, cz)
            if dist < nearestDist and dist <= 5 then
                nearestDist = dist
                nearestCrate = {id = id, data = crate}
            end
        end
    end
    
    if not nearestCrate then
        outputChatBox("Khong co thung nao gan day (5m) hoac thung da duoc tai!", player, 255, 0, 0)
        return
    end
    
    -- Check vehicle capacity
    local currentCrates = getElementData(vehicle, "vehicle.crates") or {}
    if #currentCrates >= 3 then
        outputChatBox("Xe da tai toi da 3 thung!", player, 255, 0, 0)
        return
    end
    
    -- Load crate
    table.insert(currentCrates, nearestCrate.id)
    setElementData(vehicle, "vehicle.crates", currentCrates)
    
    crateSystem.crates[nearestCrate.id].inVehicle = vehicle
    
    -- Hide crate object
    setElementAlpha(nearestCrate.data.object, 0)
    destroyElement(nearestCrate.data.marker)
    
    outputChatBox("Da tai thung ID " .. nearestCrate.id .. " len xe", player, 0, 255, 0)
    outputChatBox("Xe hien tai: " .. #currentCrates .. "/3 thung", player, 255, 255, 255)
end)

addCommandHandler("unloadcrate", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Ban can o trong xe!", player, 255, 0, 0)
        return
    end
    
    local currentCrates = getElementData(vehicle, "vehicle.crates") or {}
    if #currentCrates == 0 then
        outputChatBox("Xe khong co thung nao!", player, 255, 0, 0)
        return
    end
    
    -- Unload last crate
    local crateID = currentCrates[#currentCrates]
    table.remove(currentCrates, #currentCrates)
    setElementData(vehicle, "vehicle.crates", currentCrates)
    
    if crateSystem.crates[crateID] then
        local x, y, z = getElementPosition(vehicle)
        local interior = getElementInterior(vehicle)
        local dimension = getElementDimension(vehicle)
        
        -- Place crate behind vehicle
        setElementPosition(crateSystem.crates[crateID].object, x - 3, y, z)
        setElementAlpha(crateSystem.crates[crateID].object, 255)
        
        -- Recreate marker
        crateSystem.crates[crateID].marker = createMarker(x - 3, y, z - 1, "cylinder", 2, 255, 255, 0, 150)
        setElementInterior(crateSystem.crates[crateID].marker, interior)
        setElementDimension(crateSystem.crates[crateID].marker, dimension)
        
        crateSystem.crates[crateID].inVehicle = false
        
        outputChatBox("Da xa thung ID " .. crateID .. " ra khoi xe", player, 0, 255, 0)
        outputChatBox("Xe hien tai: " .. #currentCrates .. "/3 thung", player, 255, 255, 255)
    end
end)

-- Vehicle destroyed - drop crates
addEventHandler("onVehicleExplode", root, function()
    local crates = getElementData(source, "vehicle.crates") or {}
    if #crates > 0 then
        local x, y, z = getElementPosition(source)
        
        for _, crateID in ipairs(crates) do
            if crateSystem.crates[crateID] then
                -- Drop crate at vehicle location
                setElementPosition(crateSystem.crates[crateID].object, x + math.random(-3, 3), y + math.random(-3, 3), z)
                setElementAlpha(crateSystem.crates[crateID].object, 255)
                
                -- Recreate marker  
                crateSystem.crates[crateID].marker = createMarker(x, y, z - 1, "cylinder", 2, 255, 255, 0, 150)
                crateSystem.crates[crateID].inVehicle = false
            end
        end
        
        print("[CRATES] Vehicle destroyed, dropped " .. #crates .. " crates")
    end
end)

-- Helper function to get table size
function table.size(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

print("Crate System loaded: crates, destroycrate, adestroycrate, gotocrate, cargo, delivercrate, loadcrate, unloadcrate")
