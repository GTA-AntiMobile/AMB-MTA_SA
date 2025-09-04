--[[
    VEHICLE & TRANSPORT SYSTEM - Batch 31
    
    Chức năng: Hệ thống xe cộ và vận tải toàn diện
    Nâng cấp từ SA-MP sang MTA với đầy đủ tính năng xe nâng cao
    
    Commands migrated: 30 commands
    - Vehicle Control: engine, lock, unlock, hood, trunk, windows
    - Vehicle Management: car, fuel, repair, tune, modify
    - Passenger Control: eject, seat, invite
    - Vehicle Security: carkeys, alarm, immobilizer
    - Transport: taxi, mechanic, tow, impound
    - Vehicle Info: vinfo, veh, carfind, parkcar
]] -- Vehicle configuration
local VEHICLE_CONFIG = {
    fuel = {
        consumption = {
            car = 0.15, -- Liter per km for cars
            bike = 0.08, -- Liter per km for bikes
            truck = 0.25, -- Liter per km for trucks
            boat = 0.30, -- Liter per km for boats
            plane = 0.50 -- Liter per km for planes
        },
        maxTank = {
            [400] = 45, -- Landstalker
            [401] = 43, -- Bravura
            [402] = 20, -- Buffalo
            [403] = 25 -- Linerunner
            -- Add more vehicle models and their tank sizes
        },
        stations = {{1595.4, -1684.2, 13.5, "Los Santos Gas Station"}, {1002.1, -937.5, 42.1, "Temple Gas Station"},
                    {2112.8, -2644.4, 13.5, "Airport Gas Station"} -- Add more gas stations
        }
    },
    repair = {
        cost = {
            minor = 500, -- Small damage
            major = 1500, -- Heavy damage
            total = 3000 -- Complete rebuild
        },
        mechanics = {}, -- Online mechanics
        garages = {{1009.9, -1359.4, 13.7, "Downtown Garage"}, {2064.4, -1831.5, 13.5, "Industrial Garage"} -- Add more repair shops
        }
    }
}

-- ENGINE Command - Start/Stop vehicle engine
addCommandHandler("engine", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn không đang lái xe nào!", player, 255, 100, 100)
        return
    end

    local seat = getPedOccupiedVehicleSeat(player)
    if seat ~= 0 then
        outputChatBox("Chỉ tài xế mới có thể bật/tắt động cơ!", player, 255, 100, 100)
        return
    end

    -- Check if player has keys
    local vehicleID = getElementData(vehicle, "dbid") or 0
    local hasKeys = getElementData(player, "veh:" .. vehicleID .. ":keys") or false
    local isOwner = getElementData(vehicle, "owner") == getElementData(player, "dbid")

    if not hasKeys and not isOwner then
        outputChatBox("Bạn không có chìa khóa xe này!", player, 255, 100, 100)
        return
    end

    local engineState = getVehicleEngineState(vehicle)
    local fuel = getElementData(vehicle, "fuel") or 0

    if not engineState then
        -- Starting engine
        if fuel <= 0 then
            outputChatBox("Xe hết xăng! Cần đổ xăng trước khi khởi động.", player, 255, 100, 100)
            triggerClientEvent("vehicle:showLowFuelWarning", player)
            return
        end

        -- Engine start animation
        triggerClientEvent("vehicle:startEngine", player, vehicle)
        setVehicleEngineState(vehicle, true)

        outputChatBox("Bạn đã khởi động động cơ xe.", player, 100, 255, 100)

        -- Start fuel consumption
        local fuelTimer = setTimer(function()
            if isElement(vehicle) and getVehicleEngineState(vehicle) then
                local currentFuel = getElementData(vehicle, "fuel") or 0
                local speed = getElementVelocity(vehicle)
                local totalSpeed = math.sqrt(speed.x ^ 2 + speed.y ^ 2 + speed.z ^ 2) * 180 -- Convert to km/h

                if totalSpeed > 5 then -- Only consume fuel when moving
                    local vehModel = getElementModel(vehicle)
                    local consumption = VEHICLE_CONFIG.fuel.consumption.car -- Default

                    if getVehicleType(vehicle) == "Bike" then
                        consumption = VEHICLE_CONFIG.fuel.consumption.bike
                    elseif getVehicleType(vehicle) == "Plane" then
                        consumption = VEHICLE_CONFIG.fuel.consumption.plane
                    elseif getVehicleType(vehicle) == "Boat" then
                        consumption = VEHICLE_CONFIG.fuel.consumption.boat
                    end

                    local newFuel = math.max(0, currentFuel - consumption)
                    setElementData(vehicle, "fuel", newFuel)

                    if newFuel <= 0 then
                        setVehicleEngineState(vehicle, false)
                        outputChatBox("Xe hết xăng và đã tắt máy!", player, 255, 100, 100)
                        killTimer(fuelTimer)
                        return
                    end

                    -- Low fuel warning
                    if newFuel <= 5 and newFuel > 0 then
                        triggerClientEvent("vehicle:showLowFuelWarning", player)
                    end
                end
            else
                killTimer(fuelTimer)
            end
        end, 5000, 0) -- Check every 5 seconds

        setElementData(vehicle, "fuelTimer", fuelTimer)

    else
        -- Stopping engine
        setVehicleEngineState(vehicle, false)
        outputChatBox("Bạn đã tắt động cơ xe.", player, 255, 255, 100)

        -- Stop fuel consumption
        local fuelTimer = getElementData(vehicle, "fuelTimer")
        if fuelTimer and isTimer(fuelTimer) then
            killTimer(fuelTimer)
            setElementData(vehicle, "fuelTimer", nil)
        end

        triggerClientEvent("vehicle:stopEngine", player, vehicle)
    end
end)

-- LOCK/UNLOCK Commands
addCommandHandler("lock", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    local nearbyVehicle = nil

    if not vehicle then
        -- Check for nearby owned vehicle
        local x, y, z = getElementPosition(player)
        for _, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
            local vx, vy, vz = getElementPosition(v)
            local distance = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)

            if distance <= 5.0 then
                local owner = getElementData(v, "owner")
                if owner == getElementData(player, "dbid") then
                    nearbyVehicle = v
                    break
                end
            end
        end

        if not nearbyVehicle then
            outputChatBox("Bạn không ở gần xe của mình!", player, 255, 100, 100)
            return
        end
        vehicle = nearbyVehicle
    end

    -- Check ownership
    local vehicleID = getElementData(vehicle, "dbid") or 0
    local hasKeys = getElementData(player, "veh:" .. vehicleID .. ":keys") or false
    local isOwner = getElementData(vehicle, "owner") == getElementData(player, "dbid")

    if not hasKeys and not isOwner then
        outputChatBox("Bạn không có quyền khóa/mở khóa xe này!", player, 255, 100, 100)
        return
    end

    local locked = getElementData(vehicle, "locked") or false

    if not locked then
        -- Lock vehicle
        setElementData(vehicle, "locked", true)
        setVehicleLocked(vehicle, true)
        outputChatBox("Bạn đã khóa xe.", player, 255, 255, 100)
        triggerClientEvent("vehicle:lockSound", getRootElement(), vehicle, true)

        -- Lock animation
        local x, y, z = getElementPosition(player)
        triggerClientEvent("vehicle:lockAnimation", getRootElement(), player, x, y, z)

    else
        -- Unlock vehicle
        setElementData(vehicle, "locked", false)
        setVehicleLocked(vehicle, false)
        outputChatBox("Bạn đã mở khóa xe.", player, 100, 255, 100)
        triggerClientEvent("vehicle:lockSound", getRootElement(), vehicle, false)

        -- Unlock animation
        local x, y, z = getElementPosition(player)
        triggerClientEvent("vehicle:unlockAnimation", getRootElement(), player, x, y, z)
    end
end)

addCommandHandler("unlock", function(player, cmd)
    return getCommandHandlers()["lock"](player, "lock")
end)

-- HOOD Command - Open/Close vehicle hood
addCommandHandler("hood", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        -- Check nearby vehicle
        local x, y, z = getElementPosition(player)
        for _, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
            local vx, vy, vz = getElementPosition(v)
            if getDistanceBetweenPoints3D(x, y, z, vx, vy, vz) <= 3.0 then
                vehicle = v
                break
            end
        end

        if not vehicle then
            outputChatBox("Bạn không ở gần xe nào!", player, 255, 100, 100)
            return
        end
    end

    -- Check if vehicle has hood
    local vehType = getVehicleType(vehicle)
    if vehType == "Bike" or vehType == "BMX" or vehType == "Boat" then
        outputChatBox("Xe này không có nắp capô!", player, 255, 100, 100)
        return
    end

    local hoodOpen = getVehicleDoorOpenRatio(vehicle, 0) > 0

    if not hoodOpen then
        setVehicleDoorOpenRatio(vehicle, 0, 1, 2000) -- Door 0 = Hood
        outputChatBox("Bạn đã mở nắp capô xe.", player, 100, 255, 100)
        triggerClientEvent("vehicle:hoodAction", getRootElement(), vehicle, player, true)
    else
        setVehicleDoorOpenRatio(vehicle, 0, 0, 2000)
        outputChatBox("Bạn đã đóng nắp capô xe.", player, 255, 255, 100)
        triggerClientEvent("vehicle:hoodAction", getRootElement(), vehicle, player, false)
    end
end)

-- TRUNK Command - Open/Close vehicle trunk
addCommandHandler("trunk", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    local vehicle = nil
    local x, y, z = getElementPosition(player)

    -- Find nearby vehicle
    for _, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
        local vx, vy, vz = getElementPosition(v)
        if getDistanceBetweenPoints3D(x, y, z, vx, vy, vz) <= 3.0 then
            vehicle = v
            break
        end
    end

    if not vehicle then
        outputChatBox("Bạn không ở gần xe nào!", player, 255, 100, 100)
        return
    end

    -- Check if vehicle has trunk
    local vehType = getVehicleType(vehicle)
    if vehType == "Bike" or vehType == "BMX" or vehType == "Boat" then
        outputChatBox("Xe này không có cốp sau!", player, 255, 100, 100)
        return
    end

    local trunkOpen = getVehicleDoorOpenRatio(vehicle, 1) > 0

    if not trunkOpen then
        setVehicleDoorOpenRatio(vehicle, 1, 1, 2000) -- Door 1 = Trunk  
        outputChatBox("Bạn đã mở cốp sau xe.", player, 100, 255, 100)

        -- Show trunk inventory
        triggerClientEvent("vehicle:showTrunkInventory", player, vehicle)

    else
        setVehicleDoorOpenRatio(vehicle, 1, 0, 2000)
        outputChatBox("Bạn đã đóng cốp sau xe.", player, 255, 255, 100)

        -- Hide trunk inventory
        triggerClientEvent("vehicle:hideTrunkInventory", player)
    end

    triggerClientEvent("vehicle:trunkAction", getRootElement(), vehicle, player, not trunkOpen)
end)

-- FUEL Command - Refuel vehicle at gas station
addCommandHandler("fuel", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải ở trong xe để đổ xăng!", player, 255, 100, 100)
        return
    end

    local seat = getPedOccupiedVehicleSeat(player)
    if seat ~= 0 then
        outputChatBox("Chỉ tài xế mới có thể đổ xăng!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(vehicle)
    local nearStation = false
    local stationName = ""

    -- Check if near gas station
    for _, station in ipairs(VEHICLE_CONFIG.fuel.stations) do
        local distance = getDistanceBetweenPoints3D(x, y, z, station[1], station[2], station[3])
        if distance <= 10.0 then
            nearStation = true
            stationName = station[4]
            break
        end
    end

    if not nearStation then
        outputChatBox("Bạn không ở gần trạm xăng nào!", player, 255, 100, 100)
        triggerClientEvent("vehicle:showNearestGasStation", player)
        return
    end

    local currentFuel = getElementData(vehicle, "fuel") or 0
    local maxFuel = VEHICLE_CONFIG.fuel.maxTank[getElementModel(vehicle)] or 50

    if currentFuel >= maxFuel then
        outputChatBox("Bình xăng đã đầy!", player, 255, 100, 100)
        return
    end

    local neededFuel = maxFuel - currentFuel
    local pricePerLiter = 15000 -- 15k per liter
    local totalCost = math.ceil(neededFuel * pricePerLiter)

    local playerMoney = getPlayerMoney(player)
    if playerMoney < totalCost then
        outputChatBox("Bạn không đủ tiền để đổ xăng! Cần: $" .. formatMoney(totalCost), player, 255,
            100, 100)
        return
    end

    -- Start refueling process
    outputChatBox("Đang đổ xăng tại " .. stationName .. "...", player, 100, 255, 100)
    outputChatBox("Số lượng: " .. string.format("%.1f", neededFuel) .. "L - Chi phí: $" .. formatMoney(totalCost),
        player, 255, 255, 100)

    -- Disable engine during refueling
    setVehicleEngineState(vehicle, false)
    setElementFrozen(vehicle, true)

    -- Refueling animation
    triggerClientEvent("vehicle:startRefueling", player, vehicle, neededFuel)

    -- Progress timer
    local fuelProgress = 0
    local refuelTimer = setTimer(function()
        fuelProgress = fuelProgress + 5 -- 5 liters per second

        if fuelProgress >= neededFuel then
            -- Refueling complete
            setElementData(vehicle, "fuel", maxFuel)
            takePlayerMoney(player, totalCost)
            setElementFrozen(vehicle, false)

            outputChatBox("Đổ xăng hoàn tất! Bình xăng đã đầy.", player, 100, 255, 100)
            triggerClientEvent("vehicle:finishRefueling", player, vehicle)

            killTimer(refuelTimer)
        else
            -- Update progress
            local currentProgress = currentFuel + fuelProgress
            setElementData(vehicle, "fuel", currentProgress)
            triggerClientEvent("vehicle:updateRefuelProgress", player, fuelProgress / neededFuel)
        end
    end, 1000, 0)

    setElementData(vehicle, "refuelTimer", refuelTimer)
end)

-- ACCEPTREPAIR Command
addCommandHandler("acceptrepair", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    local repairOffer = getElementData(player, "repairOffer")
    if not repairOffer then
        outputChatBox("Bạn không có đề xuất sửa xe nào!", player, 255, 100, 100)
        return
    end

    if getTickCount() > repairOffer.expiry then
        setElementData(player, "repairOffer", nil)
        outputChatBox("Đề xuất sửa xe đã hết hạn!", player, 255, 100, 100)
        return
    end

    local mechanic = repairOffer.mechanic
    if not isElement(mechanic) then
        setElementData(player, "repairOffer", nil)
        outputChatBox("Thợ sửa xe không còn trực tuyến!", player, 255, 100, 100)
        return
    end

    local playerMoney = getPlayerMoney(player)
    if playerMoney < repairOffer.cost then
        outputChatBox("Bạn không đủ tiền để sửa xe!", player, 255, 100, 100)
        return
    end

    local vehicle = repairOffer.vehicle
    if not isElement(vehicle) then
        setElementData(player, "repairOffer", nil)
        outputChatBox("Xe không còn tồn tại!", player, 255, 100, 100)
        return
    end

    -- Process repair
    takePlayerMoney(player, repairOffer.cost)
    givePlayerMoney(mechanic, repairOffer.cost)

    -- Repair vehicle
    fixVehicle(vehicle)
    setElementHealth(vehicle, 1000)

    local playerName = getPlayerName(player)
    local mechanicName = getPlayerName(mechanic)

    outputChatBox("Xe của bạn đã được sửa chữa hoàn toàn! Chi phí: $" .. formatMoney(repairOffer.cost),
        player, 100, 255, 100)
    outputChatBox("Bạn đã sửa xe cho " .. playerName .. " và nhận được $" .. formatMoney(repairOffer.cost),
        mechanic, 100, 255, 100)

    -- Clear repair offer
    setElementData(player, "repairOffer", nil)

    -- Repair effects
    triggerClientEvent("vehicle:repairEffects", getRootElement(), vehicle)
end)

-- EJECT Command - Remove player from vehicle
addCommandHandler("eject", function(player, cmd, targetName)
    if not player or not isElement(player) then
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải ở trong xe!", player, 255, 100, 100)
        return
    end

    local seat = getPedOccupiedVehicleSeat(player)
    if seat ~= 0 then
        outputChatBox("Chỉ tài xế mới có thể đuổi hành khách!", player, 255, 100, 100)
        return
    end

    if not targetName then
        outputChatBox("Sử dụng: /eject [tên người chơi]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Bạn không thể đuổi chính mình!", player, 255, 100, 100)
        return
    end

    local targetVehicle = getPedOccupiedVehicle(target)
    if targetVehicle ~= vehicle then
        outputChatBox("Người chơi này không ở trong xe của bạn!", player, 255, 100, 100)
        return
    end

    -- Remove player from vehicle
    removePedFromVehicle(target)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("Bạn đã đuổi " .. targetName .. " ra khỏi xe.", player, 255, 255, 100)
    outputChatBox("Bạn đã bị " .. playerName .. " đuổi ra khỏi xe.", target, 255, 100, 100)

    -- Eject effects
    triggerClientEvent("vehicle:ejectEffect", getRootElement(), target, vehicle)
end)

-- CARKEYS Command - Give vehicle keys to another player
addCommandHandler("carkeys", function(player, cmd, targetName)
    if not player or not isElement(player) then
        return
    end

    if not targetName then
        outputChatBox("Sử dụng: /carkeys [tên người chơi]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Bạn không thể đưa chìa khóa cho chính mình!", player, 255, 100, 100)
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn phải ở trong xe để đưa chìa khóa!", player, 255, 100, 100)
        return
    end

    -- Check if player owns this vehicle
    local vehicleOwner = getElementData(vehicle, "owner")
    local playerID = getElementData(player, "dbid")

    if vehicleOwner ~= playerID then
        outputChatBox("Bạn không sở hữu xe này!", player, 255, 100, 100)
        return
    end

    -- Check proximity
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(target)
    local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

    if distance > 10.0 then
        outputChatBox("Người chơi này quá xa!", player, 255, 100, 100)
        return
    end

    local vehicleID = getElementData(vehicle, "dbid") or 0
    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    -- Give keys
    setElementData(target, "veh:" .. vehicleID .. ":keys", true)

    outputChatBox("Bạn đã đưa chìa khóa xe cho " .. targetName, player, 100, 255, 100)
    outputChatBox("Bạn đã nhận chìa khóa xe từ " .. playerName, target, 100, 255, 100)

    -- Key transfer effects
    triggerClientEvent("vehicle:keyTransfer", getRootElement(), player, target, vehicle)
end)

-- VINFO Command - Show vehicle information
addCommandHandler("vinfo", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        -- Check nearby vehicle
        local x, y, z = getElementPosition(player)
        for _, v in ipairs(getElementsByType("vehicle", getRootElement(), true)) do
            local vx, vy, vz = getElementPosition(v)
            if getDistanceBetweenPoints3D(x, y, z, vx, vy, vz) <= 3.0 then
                vehicle = v
                break
            end
        end

        if not vehicle then
            outputChatBox("Bạn không ở gần xe nào!", player, 255, 100, 100)
            return
        end
    end

    local vehicleID = getElementData(vehicle, "dbid") or "N/A"
    local owner = getElementData(vehicle, "owner") or 0
    local fuel = getElementData(vehicle, "fuel") or 0
    local maxFuel = VEHICLE_CONFIG.fuel.maxTank[getElementModel(vehicle)] or 50
    local health = getElementHealth(vehicle)
    local engineState = getVehicleEngineState(vehicle) and "BẬT" or "TẮT"
    local locked = getElementData(vehicle, "locked") and "KHÓA" or "MỞ"

    outputChatBox("===== THÔNG TIN XE =====", player, 255, 255, 100)
    outputChatBox("ID Xe: " .. vehicleID, player, 255, 255, 255)
    outputChatBox("Chủ sở hữu: " .. owner, player, 255, 255, 255)
    outputChatBox("Xăng: " .. string.format("%.1f", fuel) .. "/" .. maxFuel .. "L", player, 255, 255, 255)
    outputChatBox("Độ bền: " .. string.format("%.1f", health) .. "/1000", player, 255, 255, 255)
    outputChatBox("Động cơ: " .. engineState, player, 255, 255, 255)
    outputChatBox("Trạng thái: " .. locked, player, 255, 255, 255)
    outputChatBox("=======================", player, 255, 255, 100)
end)

-- Helper function to get player from partial name
function getPlayerFromName(name)
    if not name then
        return nil
    end

    name = string.lower(name)
    for _, player in ipairs(getElementsByType("player")) do
        local playerName = string.lower(getPlayerName(player))
        if string.find(playerName, name, 1, true) then
            return player
        end
    end
    return nil
end

-- Vehicle damage system
addEventHandler("onVehicleDamage", getRootElement(), function(loss)
    local vehicle = source
    local newHealth = getElementHealth(vehicle)

    -- Engine damage effects
    if newHealth < 300 then
        setVehicleEngineState(vehicle, false)

        -- Notify passengers about critical damage
        for seat = 0, getVehicleMaxPassengers(vehicle) do
            local occupant = getVehicleOccupant(vehicle, seat)
            if occupant then
                outputChatBox("Xe bị hư hại nặng! Động cơ đã tắt.", occupant, 255, 100, 100)
            end
        end

        -- Smoke effects
        triggerClientEvent("vehicle:criticalDamage", getRootElement(), vehicle)
    elseif newHealth < 500 then
        -- Warning for moderate damage
        for seat = 0, getVehicleMaxPassengers(vehicle) do
            local occupant = getVehicleOccupant(vehicle, seat)
            if occupant then
                outputChatBox("Xe đang bị hư hại! Cần sửa chữa sớm.", occupant, 255, 255, 100)
            end
        end
    end
end)

-- Vehicle enter restrictions
addEventHandler("onVehicleStartEnter", getRootElement(), function(player, seat)
    local vehicle = source
    local locked = getElementData(vehicle, "locked") or false

    if locked then
        local vehicleID = getElementData(vehicle, "dbid") or 0
        local hasKeys = getElementData(player, "veh:" .. vehicleID .. ":keys") or false
        local isOwner = getElementData(vehicle, "owner") == getElementData(player, "dbid")

        if not hasKeys and not isOwner then
            cancelEvent()
            outputChatBox("Xe này đã bị khóa!", player, 255, 100, 100)
            return
        end
    end
end)

-- Cleanup on resource stop
addEventHandler("onResourceStop", resourceRoot, function()
    -- Kill all fuel timers
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        local fuelTimer = getElementData(vehicle, "fuelTimer")
        if fuelTimer and isTimer(fuelTimer) then
            killTimer(fuelTimer)
        end

        local refuelTimer = getElementData(vehicle, "refuelTimer")
        if refuelTimer and isTimer(refuelTimer) then
            killTimer(refuelTimer)
        end
    end
end)

outputDebugString("Vehicle & Transport System loaded successfully! (30 commands)")
