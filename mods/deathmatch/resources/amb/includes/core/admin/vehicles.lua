-- ================================
-- AMB Vehicle Admin Commands
-- Migrated from SA-MP commands.pwn
-- ================================

-- Global vehicle tracking
local CreatedCars = {}
local MAX_CREATED_VEHICLES = 50

-- Initialize created cars array
for i = 1, MAX_CREATED_VEHICLES do
    CreatedCars[i] = nil
end

-- Vehicle fuel system (from SA-MP VehicleFuel array)
local VehicleFuel = {}

-- Train vehicle IDs (from SA-MP IsATrain function)
local trainVehicles = {
    [537] = true, -- Freight
    [538] = true, -- Streak
    [569] = true, -- Freight Flat
    [570] = true, -- Streak Carriage
    [590] = true  -- Freight Box
}

-- Custom vehicle validation (30001-40000 range from SA-MP)
function IsValidCustomVehicle(modelID)
    -- In MTA, we need to check if custom vehicle model is loaded
    -- For now, return false as custom vehicles need special handling
    return false
end

-- Check if vehicle is a train
function IsATrain(modelID)
    return trainVehicles[modelID] or false
end

-- Reset vehicle data (from SA-MP Vehicle_ResetData function)
function Vehicle_ResetData(vehicle)
    if not vehicle or not isElement(vehicle) then return end
    
    -- Reset vehicle to default state
    setVehicleDamageProof(vehicle, false)
    setVehicleEngineState(vehicle, true)
    setVehicleLocked(vehicle, false)
    
    -- Set default fuel
    local modelID = getElementModel(vehicle)
    VehicleFuel[vehicle] = 100.0
    setElementData(vehicle, "fuel", 100.0)
    
    outputDebugString("[VEHICLE] Reset data for vehicle model " .. modelID)
end

-- /veh command - Create admin vehicle (migrated from SA-MP)
addCommandHandler("veh", function(player, _, vehicleModel, color1, color2)
    -- Check admin level (pAdmin >= 4 in SA-MP) using global isPlayerAdmin function
    if not isPlayerAdmin(player, 4) then
        outputChatBox("❌ Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    -- Validate parameters
    if not vehicleModel or not color1 or not color2 then
        outputChatBox("📝 SU DUNG: /veh [model ID] [color 1] [color 2]", player, 255, 255, 100)
        return
    end
    
    -- Convert to numbers
    local iVehicle = tonumber(vehicleModel)
    local iColor1 = tonumber(color1)
    local iColor2 = tonumber(color2)
    
    if not iVehicle or not iColor1 or not iColor2 then
        outputChatBox("❌ Invalid parameters. Use numbers only.", player, 255, 100, 100)
        return
    end
    
    -- Check vehicle model range (400-611 for GTA vehicles, 30001-40000 for custom)
    if not ((iVehicle >= 400 and iVehicle <= 611) or (iVehicle >= 30001 and iVehicle <= 40000)) then
        outputChatBox("❌ ID xe phai tu 400-611 (xe goc) hoac 30001-40000 (xe custom)", player, 255, 100, 100)
        return
    end
    
    -- Check custom vehicle range
    if iVehicle >= 30001 and iVehicle <= 40000 then
        if not IsValidCustomVehicle(iVehicle) then
            outputChatBox("❌ Custom vehicle model ID nay chua duoc load hoac khong ton tai!", player, 255, 100, 100)
            return
        end
    end
    
    -- Check if it's a train
    if IsATrain(iVehicle) then
        outputChatBox("❌ Trains cannot be spawned during runtime.", player, 255, 100, 100)
        return
    end
    
    -- Check color range (0-255)
    if not (iColor1 >= 0 and iColor1 <= 255 and iColor2 >= 0 and iColor2 <= 255) then
        outputChatBox("❌ ID mau xe phai tu 0 den 255.", player, 255, 100, 100)
        return
    end
    
    -- Find empty slot in CreatedCars array
    local foundSlot = nil
    for i = 1, MAX_CREATED_VEHICLES do
        if not CreatedCars[i] or not isElement(CreatedCars[i]) then
            foundSlot = i
            break
        end
    end
    
    if not foundSlot then
        outputChatBox("❌ Da dat gioi han toi da " .. MAX_CREATED_VEHICLES .. " xe duoc tao ra.", player, 255, 100, 100)
        return
    end
    
    -- Get player position and rotation
    local x, y, z = getElementPosition(player)
    local _, _, rotation = getElementRotation(player)
    
    -- Get player's virtual world and interior
    local virtualWorld = getElementDimension(player)
    local interior = getElementInterior(player)
    
    -- Create vehicle
    local vehicle = createVehicle(iVehicle, x + 2, y, z + 1, 0, 0, rotation)
    
    if vehicle then
        -- Store in CreatedCars array
        CreatedCars[foundSlot] = vehicle
        
        -- Set vehicle colors
        setVehicleColor(vehicle, iColor1, iColor2, iColor1, iColor2)
        
        -- Set fuel to 100%
        VehicleFuel[vehicle] = 100.0
        setElementData(vehicle, "fuel", 100.0)
        
        -- Reset vehicle data
        Vehicle_ResetData(vehicle)
        
        -- Set virtual world and interior
        setElementDimension(vehicle, virtualWorld)
        setElementInterior(vehicle, interior)
        
        -- Set as admin vehicle
        setElementData(vehicle, "adminVehicle", true)
        setElementData(vehicle, "createdBy", getPlayerName(player))
        setElementData(vehicle, "createdTime", getRealTime().timestamp)
        
        -- Success message
        outputChatBox("✅ Xe da duoc tao ra! (Model: " .. iVehicle .. ", Slot: " .. foundSlot .. ")", player, 100, 255, 100)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " created vehicle " .. iVehicle .. " (slot " .. foundSlot .. ")")
    else
        outputChatBox("❌ Khong the tao xe. Model ID khong hop le?", player, 255, 100, 100)
    end
end)

-- /deleteveh command - Delete admin vehicles
addCommandHandler("deleteveh", function(player, _, slotID)
    if not isPlayerAdmin(player, 4) then
        outputChatBox("❌ Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not slotID then
        outputChatBox("📝 SU DUNG: /deleteveh [slot ID] (1-" .. MAX_CREATED_VEHICLES .. ")", player, 255, 255, 100)
        return
    end
    
    local slot = tonumber(slotID)
    if not slot or slot < 1 or slot > MAX_CREATED_VEHICLES then
        outputChatBox("❌ Slot ID phai tu 1 den " .. MAX_CREATED_VEHICLES, player, 255, 100, 100)
        return
    end
    
    if not CreatedCars[slot] or not isElement(CreatedCars[slot]) then
        outputChatBox("❌ Khong co xe nao trong slot " .. slot, player, 255, 100, 100)
        return
    end
    
    -- Delete vehicle
    local vehicle = CreatedCars[slot]
    local modelID = getElementModel(vehicle)
    
    destroyElement(vehicle)
    CreatedCars[slot] = nil
    VehicleFuel[vehicle] = nil
    
    outputChatBox("✅ Da xoa xe model " .. modelID .. " tu slot " .. slot, player, 100, 255, 100)
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " deleted vehicle from slot " .. slot)
end)

-- /listveh command - List created vehicles
addCommandHandler("listveh", function(player)
    if not isPlayerAdmin(player, 4) then
        outputChatBox("❌ Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    outputChatBox("📋 ===== ADMIN VEHICLES =====", player, 255, 255, 100)
    
    local count = 0
    for i = 1, MAX_CREATED_VEHICLES do
        if CreatedCars[i] and isElement(CreatedCars[i]) then
            local vehicle = CreatedCars[i]
            local modelID = getElementModel(vehicle)
            local createdBy = getElementData(vehicle, "createdBy") or "Unknown"
            local fuel = VehicleFuel[vehicle] or 0
            
            outputChatBox("Slot " .. i .. ": Model " .. modelID .. " | Fuel: " .. math.floor(fuel) .. "% | By: " .. createdBy, player, 200, 200, 200)
            count = count + 1
        end
    end
    
    if count == 0 then
        outputChatBox("❌ Khong co xe admin nao duoc tao ra", player, 255, 100, 100)
    else
        outputChatBox("📊 Total: " .. count .. "/" .. MAX_CREATED_VEHICLES .. " vehicles", player, 255, 255, 100)
    end
end)

-- /deleteallveh command - Delete all admin vehicles
addCommandHandler("deleteallveh", function(player)
    if not isPlayerAdmin(player, 5) then -- Higher admin level required
        outputChatBox("❌ Can Admin level 5+ to use this command.", player, 255, 100, 100)
        return
    end
    
    local count = 0
    for i = 1, MAX_CREATED_VEHICLES do
        if CreatedCars[i] and isElement(CreatedCars[i]) then
            destroyElement(CreatedCars[i])
            VehicleFuel[CreatedCars[i]] = nil
            CreatedCars[i] = nil
            count = count + 1
        end
    end
    
    if count > 0 then
        outputChatBox("✅ Da xoa " .. count .. " admin vehicles", player, 100, 255, 100)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " deleted all admin vehicles (" .. count .. " vehicles)")
    else
        outputChatBox("❌ Khong co xe nao de xoa", player, 255, 100, 100)
    end
end)

-- Cleanup vehicles when they're destroyed
addEventHandler("onVehicleDestroy", root, function()
    local vehicle = source
    
    -- Remove from CreatedCars array
    for i = 1, MAX_CREATED_VEHICLES do
        if CreatedCars[i] == vehicle then
            CreatedCars[i] = nil
            break
        end
    end
    
    -- Remove fuel data
    VehicleFuel[vehicle] = nil
end)

outputDebugString("[ADMIN] Vehicle admin commands loaded (/veh, /deleteveh, /listveh, /deleteallveh)")
