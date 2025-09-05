-- ================================
-- AMB MTA:SA - Miscellaneous & Utility Commands
-- Mass migration of misc utility commands
-- ================================
-- Save position
addCommandHandler("save", function(player)
    local x, y, z = getElementPosition(player)
    local playerData = getElementData(player, "playerData") or {}

    playerData.savedPosition = {
        x = x,
        y = y,
        z = z
    }
    setElementData(player, "playerData", playerData)

    outputChatBox(string.format("💾 Da save position: %.2f, %.2f, %.2f", x, y, z), player, 0, 255, 0)
end)

-- Load saved position
addCommandHandler("load", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.savedPosition then
        outputChatBox("❌ Khong co saved position nao.", player, 255, 100, 100)
        return
    end

    local pos = playerData.savedPosition
    setElementPosition(player, pos.x, pos.y, pos.z)

    outputChatBox(string.format("📍 Da load position: %.2f, %.2f, %.2f", pos.x, pos.y, pos.z), player, 0, 255, 0)
end)

-- Flip vehicle
addCommandHandler("flip", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban khong o trong xe.", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(vehicle)
    setElementRotation(vehicle, 0, 0, 0)
    setElementPosition(vehicle, x, y, z + 1)

    outputChatBox("🔄 Da flip vehicle!", player, 0, 255, 0)
end)

-- Get coordinates
addCommandHandler("getpos", function(player)
    local x, y, z = getElementPosition(player)
    local rx, ry, rz = getElementRotation(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)

    outputChatBox("📍 ===== POSITION INFO =====", player, 255, 255, 0)
    outputChatBox(string.format("• Position: %.4f, %.4f, %.4f", x, y, z), player, 255, 255, 255)
    outputChatBox(string.format("• Rotation: %.4f, %.4f, %.4f", rx, ry, rz), player, 255, 255, 255)
    outputChatBox(string.format("• Interior: %d", interior), player, 255, 255, 255)
    outputChatBox(string.format("• Dimension: %d", dimension), player, 255, 255, 255)
end)

-- Teleport to coordinates
addCommandHandler("goto", function(player, cmd, x, y, z)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 1 then
        outputChatBox("❌ Chi admins moi co the su dung lenh nay.", player, 255, 100, 100)
        return
    end

    if not x or not y then
        outputChatBox("Su dung: /goto [x] [y] [z]", player, 255, 255, 255)
        return
    end

    local gotoX = tonumber(x)
    local gotoY = tonumber(y)
    local gotoZ = tonumber(z) or 10

    if not gotoX or not gotoY or not gotoZ then
        outputChatBox("❌ Toa do khong hop le.", player, 255, 100, 100)
        return
    end

    setElementPosition(player, gotoX, gotoY, gotoZ)
    outputChatBox(string.format("📍 Da teleport den %.2f, %.2f, %.2f", gotoX, gotoY, gotoZ), player, 0, 255, 0)
    
    -- Save position to database after teleport
    if dbSavePlayer then 
        dbSavePlayer(player)
    end
end)

-- Time command
addCommandHandler("time", function(player, cmd, hour, minute)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 3 then
        outputChatBox("❌ Chi admin level 3+ moi co the thay doi time.", player, 255, 100, 100)
        return
    end

    if not hour then
        local currentHour, currentMinute = getTime()
        outputChatBox(string.format("🕐 Current time: %02d:%02d", currentHour, currentMinute), player, 255, 255, 100)
        outputChatBox("Su dung: /time [hour] [minute]", player, 255, 255, 255)
        return
    end

    local newHour = tonumber(hour)
    local newMinute = tonumber(minute) or 0

    if not newHour or newHour < 0 or newHour > 23 then
        outputChatBox("❌ Hour phai tu 0-23.", player, 255, 100, 100)
        return
    end

    if newMinute < 0 or newMinute > 59 then
        outputChatBox("❌ Minute phai tu 0-59.", player, 255, 100, 100)
        return
    end

    setTime(newHour, newMinute)
    outputChatBox(string.format("🕐 Da thay doi time thanh %02d:%02d.", newHour, newMinute), player, 0, 255, 0)

    -- Notify all players
    for _, p in ipairs(getElementsByType("player")) do
        if p ~= player then
            outputChatBox(string.format("🕐 Admin %s da thay doi time.", getPlayerName(player)), p, 255, 255, 100)
        end
    end
end)

-- Gravity command
addCommandHandler("gravity", function(player, cmd, gravityValue)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 4 then
        outputChatBox("❌ Chi admin level 4+ moi co the thay doi gravity.", player, 255, 100, 100)
        return
    end

    if not gravityValue then
        outputChatBox("Su dung: /gravity [value] (default: 0.008)", player, 255, 255, 255)
        return
    end

    local newGravity = tonumber(gravityValue)
    if not newGravity then
        outputChatBox("❌ Gravity value khong hop le.", player, 255, 100, 100)
        return
    end

    setGravity(newGravity)
    outputChatBox(string.format("🌍 Da thay doi gravity thanh %.3f.", newGravity), player, 0, 255, 0)

    -- Notify all players
    for _, p in ipairs(getElementsByType("player")) do
        if p ~= player then
            outputChatBox(string.format("🌍 Admin %s da thay doi gravity.", getPlayerName(player)), p, 255, 255, 100)
        end
    end
end)

-- Spawn vehicle
addCommandHandler("veh", function(player, cmd, vehicleID)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 1 then
        outputChatBox("❌ Chi admins moi co the spawn vehicle.", player, 255, 100, 100)
        return
    end

    if not vehicleID then
        outputChatBox("Su dung: /veh [vehicle_id]", player, 255, 255, 255)
        return
    end

    local vehID = tonumber(vehicleID)
    if not vehID or vehID < 400 or vehID > 611 then
        outputChatBox("❌ Vehicle ID phai tu 400-611.", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local vehicle = createVehicle(vehID, x + 3, y, z)

    if vehicle then
        outputChatBox(string.format("🚗 Da spawn vehicle ID %d.", vehID), player, 0, 255, 0)
    else
        outputChatBox("❌ Khong the spawn vehicle.", player, 255, 100, 100)
    end
end)

-- Destroy vehicle
addCommandHandler("destroyveh", function(player, cmd, radius)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 2 then
        outputChatBox("❌ Chi admin level 2+ moi co the destroy vehicles.", player, 255, 100, 100)
        return
    end

    local destroyRadius = tonumber(radius) or 10
    local x, y, z = getElementPosition(player)
    local destroyed = 0

    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        local vx, vy, vz = getElementPosition(vehicle)
        if getDistanceBetweenPoints3D(x, y, z, vx, vy, vz) <= destroyRadius then
            -- Check if anyone is in vehicle
            local hasOccupants = false
            for seat = 0, getVehicleMaxPassengers(vehicle) do
                if getVehicleOccupant(vehicle, seat) then
                    hasOccupants = true
                    break
                end
            end

            if not hasOccupants then
                destroyElement(vehicle)
                destroyed = destroyed + 1
            end
        end
    end

    outputChatBox(string.format("🚗 Da destroy %d vehicles trong %dm radius.", destroyed, destroyRadius), player, 0,
        255, 0)
end)

-- Clear chat
addCommandHandler("clearchat", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 2 then
        outputChatBox("❌ Chi admin level 2+ moi co the clear chat.", player, 255, 100, 100)
        return
    end

    -- Clear chat for all players
    for i = 1, 50 do
        for _, p in ipairs(getElementsByType("player")) do
            outputChatBox(" ", p, 255, 255, 255)
        end
    end

    for _, p in ipairs(getElementsByType("player")) do
        outputChatBox(string.format("🧹 Chat da duoc clear boi admin %s.", getPlayerName(player)), p, 255, 255, 0)
    end
end)

-- Fix vehicle
addCommandHandler("fix", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban khong o trong xe.", player, 255, 100, 100)
        return
    end

    fixVehicle(vehicle)
    outputChatBox("🔧 Da fix vehicle!", player, 0, 255, 0)
end)

-- Tune vehicle
addCommandHandler("tune", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban khong o trong xe.", player, 255, 100, 100)
        return
    end

    -- Add basic tuning
    local tuningParts = {1010, 1087, 1085, 1025, 1073, 1074, 1075, 1076}
    local added = 0

    for _, part in ipairs(tuningParts) do
        if addVehicleUpgrade(vehicle, part) then
            added = added + 1
        end
    end

    outputChatBox(string.format("🔧 Da add %d tuning parts!", added), player, 0, 255, 0)
end)

-- Jetpack command
addCommandHandler("jetpack", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 1 then
        outputChatBox("❌ Chi admins moi co the su dung jetpack.", player, 255, 100, 100)
        return
    end

    if doesPedHaveJetPack(player) then
        removePedJetPack(player)
        outputChatBox("🚀 Da remove jetpack.", player, 255, 255, 100)
    else
        givePedJetPack(player)
        outputChatBox("🚀 Da give jetpack!", player, 0, 255, 0)
    end
end)

-- Invisible mode
addCommandHandler("invisible", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 3 then
        outputChatBox("❌ Chi admin level 3+ moi co the invisible.", player, 255, 100, 100)
        return
    end

    local isInvisible = getElementAlpha(player) == 0

    if isInvisible then
        setElementAlpha(player, 255)
        outputChatBox("👁️ Da tat invisible mode.", player, 255, 255, 100)
    else
        setElementAlpha(player, 0)
        outputChatBox("👻 Da bat invisible mode.", player, 255, 255, 100)
    end
end)

-- Noclip mode
addCommandHandler("noclip", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 3 then
        outputChatBox("❌ Chi admin level 3+ moi co the noclip.", player, 255, 100, 100)
        return
    end

    local isNoclip = getElementData(player, "noclip") or false

    if isNoclip then
        setElementCollisionsEnabled(player, true)
        setElementData(player, "noclip", false)
        outputChatBox("🚫 Da tat noclip mode.", player, 255, 255, 100)
    else
        setElementCollisionsEnabled(player, false)
        setElementData(player, "noclip", true)
        outputChatBox("👻 Da bat noclip mode.", player, 255, 255, 100)
    end
end)

-- Get vehicle info
addCommandHandler("vehinfo", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban khong o trong xe.", player, 255, 100, 100)
        return
    end

    local model = getElementModel(vehicle)
    local health = getElementHealth(vehicle)
    local x, y, z = getElementPosition(vehicle)
    local fuel = getElementData(vehicle, "fuel") or 100
    local owner = getElementData(vehicle, "owner") or "Server"

    outputChatBox("🚗 ===== VEHICLE INFO =====", player, 255, 255, 0)
    outputChatBox(string.format("• Model: %d", model), player, 255, 255, 255)
    outputChatBox(string.format("• Health: %.1f", health), player, 255, 255, 255)
    outputChatBox(string.format("• Position: %.2f, %.2f, %.2f", x, y, z), player, 255, 255, 255)
    outputChatBox(string.format("• Fuel: %.1f%%", fuel), player, 255, 255, 255)
    outputChatBox(string.format("• Owner: %s", owner), player, 255, 255, 255)
end)

-- Random teleport
addCommandHandler("randomtp", function(player)
    local randomLocations = {{1544.6, -1675.5, 13.6, "Los Santos"}, {-1989.4, 137.4, 27.7, "San Fierro"},
                             {2105.5, 1003.5, 10.8, "Las Venturas"}, {-2240.8, -1761.6, 480.8, "Mount Chiliad"},
                             {1310.5, 1675.5, 10.8, "Bone County"}}

    local location = randomLocations[math.random(#randomLocations)]
    setElementPosition(player, location[1], location[2], location[3])

    outputChatBox(string.format("🎲 Random teleport den %s!", location[4]), player, 255, 255, 100)
    
    -- Save position to database after teleport
    if dbSavePlayer then 
        dbSavePlayer(player)
    end
end)

-- Suicide command
addCommandHandler("suicide", function(player)
    killPed(player, player)
    outputChatBox("💀 Ban da tu tu.", player, 255, 100, 100)

    -- Notify nearby players
    local x, y, z = getElementPosition(player)
    for _, nearPlayer in ipairs(getElementsByType("player")) do
        if nearPlayer ~= player then
            local nx, ny, nz = getElementPosition(nearPlayer)
            if getDistanceBetweenPoints3D(x, y, z, nx, ny, nz) < 50 then
                outputChatBox(string.format("💀 %s da tu tu.", getPlayerName(player)), nearPlayer, 255, 100, 100)
            end
        end
    end
end)

outputDebugString("[AMB] Miscellaneous & Utility system loaded - 20 commands")
