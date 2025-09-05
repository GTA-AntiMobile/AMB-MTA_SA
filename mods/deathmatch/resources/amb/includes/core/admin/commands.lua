local DEBUG_COMMANDS = true

local function debugLog(message)
    if DEBUG_COMMANDS then
        outputDebugString("[ADMIN_CMD] " .. message)
        outputConsole("[ADMIN_CMD] " .. message)
    end
end

-- /cv command - Create vehicle using newmodels_azul
addCommandHandler("cv", function(player, _, idStr)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! Moderator level required.", player, 255, 100, 100)
        return
    end

    local cid = tonumber(idStr)
    if not cid then
        outputChatBox("Usage: /cv [modelID]", player, 255, 0, 0)
        outputChatBox("Use /listcv to see available models", player, 255, 255, 0)
        return
    end

    local x, y, z = getElementPosition(player)
    local _, _, rotZ = getElementRotation(player)
    local radRot = math.rad(rotZ)
    x = x + 5.0 * math.sin(radRot)
    y = y + 5.0 * math.cos(radRot)

    local vehicle

    -- Use newmodels_azul for custom vehicles (30000+)
    if cid >= 30000 and cid < 40000 then
        local newmodelsResource = getResourceFromName("newmodels_azul")
        if newmodelsResource and getResourceState(newmodelsResource) == "running" then
            vehicle = exports["newmodels_azul"]:createVehicle(cid, x, y, z, 0, 0, rotZ)
            if vehicle then
                outputChatBox("✅ Custom vehicle " .. cid .. " created!", player, 0, 255, 0)
            else
                outputChatBox("❌ Failed to create custom vehicle " .. cid, player, 255, 0, 0)
            end
        else
            outputChatBox("❌ newmodels_azul not running!", player, 255, 0, 0)
            return
        end
    else
        -- Standard GTA SA vehicles (400-611)
        if cid < 400 or cid > 611 then
            outputChatBox("❌ Invalid vehicle ID! Use 400-611 for standard vehicles or 30000+ for custom", player, 255,
                0, 0)
            return
        end
        vehicle = createVehicle(cid, x, y, z, 0, 0, rotZ)
        if vehicle then
            outputChatBox("✅ Standard vehicle " .. cid .. " created!", player, 0, 255, 0)
        else
            outputChatBox("❌ Failed to create vehicle " .. cid, player, 255, 0, 0)
        end
    end

    if vehicle then
        setElementInterior(vehicle, getElementInterior(player))
        setElementDimension(vehicle, getElementDimension(player))

        -- Set custom vehicle name for speedometer display
        if cid >= 30000 and cid < 40000 then
            -- Try to get name from scanned models first
            local models = getNewmodelsAvailableModels()
            local customName = "Custom Vehicle " .. cid

            for _, vehicleInfo in ipairs(models.vehicles) do
                if vehicleInfo.id == cid then
                    customName = vehicleInfo.name
                    break
                end
            end

            setElementData(vehicle, "customVehicleName", customName)
            setElementData(vehicle, "customVehicleID", cid)
            outputDebugString("[CV] Set custom name: " .. customName .. " for vehicle " .. cid)
        end
    end
end)

-- /listcv command - Dynamic vehicle listing
addCommandHandler("listcv", function(player)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! Moderator level required.", player, 255, 100, 100)
        return
    end

    outputChatBox("=== VEHICLE MODELS ===", player, 33, 150, 243)

    -- Get dynamic models from newmodels_azul
    local models = getNewmodelsAvailableModels()

    -- Display custom vehicles
    outputChatBox("=== Custom Vehicles ===", player, 255, 215, 0)
    if #models.vehicles > 0 then
        for _, vehicle in ipairs(models.vehicles) do
            outputChatBox(vehicle.id .. " - " .. vehicle.name, player, 100, 255, 100)
        end
    else
        outputChatBox("No custom vehicles available", player, 255, 100, 100)
    end

    -- Display standard vehicles info
    outputChatBox("=== Standard Vehicles (400-611) ===", player, 255, 215, 0)
    outputChatBox("Cars: 400-404, 410-412, 415-426, 445-451", player, 255, 255, 255)
    outputChatBox("Motorcycles: 448, 461-463, 468, 471, 521-523", player, 255, 255, 255)
    outputChatBox("Aircraft: 460, 464-465, 469, 476, 487-488", player, 255, 255, 255)

    outputChatBox("Usage: /cv [model]", player, 74, 144, 226)
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " viewed vehicle list")
end)

-- /listskin command - Dynamic skin listing
addCommandHandler("listskin", function(player, command)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! You need moderator level or higher.", player, 255, 100, 100, false)
        return
    end

    outputChatBox("=== SKIN MODELS ===", player, 33, 150, 243, false)

    -- Get dynamic models from newmodels_azul
    local models = getNewmodelsAvailableModels()

    -- Display custom skins
    outputChatBox("=== Custom Skins ===", player, 255, 215, 0, false)
    if #models.peds > 0 then
        for _, ped in ipairs(models.peds) do
            outputChatBox(ped.id .. " - " .. ped.name, player, 100, 255, 100, false)
        end
    else
        outputChatBox("No custom skins available", player, 255, 100, 100, false)
    end

    -- Display standard skins info
    outputChatBox("=== Standard Skins (0-299) ===", player, 255, 215, 0, false)
    outputChatBox("Police: 280-288, Army: 287, Civilians: 1-299", player, 255, 255, 255, false)

    outputChatBox("Usage: /changeskin [player] [skin_id]", player, 74, 144, 226, false)
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " viewed skin list")
end)

-- /listobjects command - Dynamic object listing
addCommandHandler("listobjects", function(player)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! You need moderator level or higher.", player, 255, 100, 100, false)
        return
    end

    outputChatBox("=== OBJECT MODELS ===", player, 33, 150, 243, false)

    -- Get dynamic models from newmodels_azul
    local models = getNewmodelsAvailableModels()

    -- Display custom objects
    outputChatBox("=== Custom Objects ===", player, 255, 215, 0, false)
    if #models.objects > 0 then
        for _, object in ipairs(models.objects) do
            outputChatBox(object.id .. " - " .. object.name, player, 100, 255, 100, false)
        end
    else
        outputChatBox("No custom objects available", player, 255, 100, 100, false)
    end

    -- Display standard objects info
    outputChatBox("=== Standard Objects (1-18000+) ===", player, 255, 215, 0, false)
    outputChatBox("Common: 1337-1400, Buildings: 3000-4000", player, 255, 255, 255, false)

    outputChatBox("Usage: /createobject [object_id]", player, 74, 144, 226, false)
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " viewed object list")
end)

-- /createobject command - Create custom objects using newmodels_azul
addCommandHandler("createobject", function(player, _, objectIDStr)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! You need moderator level or higher.", player, 255, 100, 100, false)
        return
    end

    if not objectIDStr then
        outputChatBox("Usage: /createobject [object ID]", player, 255, 255, 100, false)
        outputChatBox("Use /listobjects to see available models", player, 255, 255, 0, false)
        return
    end

    local objectID = tonumber(objectIDStr)
    if not objectID then
        outputChatBox("❌ Invalid object ID! Must be a number", player, 255, 100, 100, false)
        return
    end

    local x, y, z = getElementPosition(player)
    local _, _, rot = getElementRotation(player)

    -- Position object in front of player
    local radRot = math.rad(rot)
    x = x + 3.0 * math.sin(radRot)
    y = y + 3.0 * math.cos(radRot)
    z = z + 0.5

    local object

    -- Use newmodels_azul for custom objects (19000+)
    if objectID >= 19000 and objectID < 30000 then
        local newmodelsResource = getResourceFromName("newmodels_azul")
        if newmodelsResource and getResourceState(newmodelsResource) == "running" then
            object = exports["newmodels_azul"]:createObject(objectID, x, y, z, 0, 0, rot)
            if object then
                outputChatBox("✅ Custom object " .. objectID .. " created!", player, 0, 255, 0, false)
            else
                outputChatBox("❌ Failed to create custom object " .. objectID, player, 255, 0, 0, false)
            end
        else
            outputChatBox("❌ newmodels_azul not running!", player, 255, 0, 0, false)
            return
        end
    else
        -- Standard GTA SA objects (1-18000)
        if objectID < 1 or objectID >= 19000 then
            outputChatBox("❌ Invalid object ID! Use 1-18000 for standard objects or 19000+ for custom", player, 255,
                0, 0, false)
            return
        end
        object = createObject(objectID, x, y, z, 0, 0, rot)
        if object then
            outputChatBox("✅ Standard object " .. objectID .. " created!", player, 0, 255, 0, false)
        else
            outputChatBox("❌ Failed to create object " .. objectID, player, 255, 0, 0, false)
        end
    end

    if object then
        setElementInterior(object, getElementInterior(player))
        setElementDimension(object, getElementDimension(player))
        setElementData(player, "lastObject", object)
        outputDebugString("[CREATEOBJECT] " .. getPlayerName(player) .. " created object " .. objectID)
    end
end)

-- /setmyhp command - Set own health (matches SA-MP logic)
addCommandHandler("setmyhp", function(player, _, hp)
    -- SA-MP: Admin level 4+ OR Undercover level 1+
    local adminLevel = getElementData(player, "adminLevel") or 0
    local undercoverLevel = getElementData(player, "player.undercoverLevel") or 0

    if adminLevel < ADMIN_LEVELS.ADMIN and undercoverLevel < 1 then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end

    if not hp then
        outputChatBox("SU DUNG: /setmyhp [health]", player, 255, 100, 100, false)
        return
    end

    local healthAmount = tonumber(hp)
    if not healthAmount then
        outputChatBox("Invalid health amount.", player, 255, 100, 100, false)
        return
    end

    setElementHealth(player, healthAmount)
    outputChatBox("Ban da thiet lap Health cua ban " .. healthAmount .. ".", player, 255, 255, 255, false)
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " set their own health to " .. healthAmount)
end)

-- /setmyarmor command - Set own armor (matches SA-MP logic)
addCommandHandler("setmyarmor", function(player, _, armor)
    -- SA-MP: Admin level 4+ OR Undercover level 1+
    local adminLevel = getElementData(player, "adminLevel") or 0
    local undercoverLevel = getElementData(player, "player.undercoverLevel") or 0

    if adminLevel < ADMIN_LEVELS.ADMIN and undercoverLevel < 1 then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end

    if not armor then
        outputChatBox("SU DUNG: /setmyarmor [amount]", player, 255, 100, 100, false)
        return
    end

    local armorAmount = tonumber(armor)
    if not armorAmount then
        outputChatBox("Invalid armor amount.", player, 255, 100, 100, false)
        return
    end

    setPedArmor(player, armorAmount)
    outputChatBox("Ban da thiet lap armor cho " .. armorAmount .. ".", player, 255, 255, 255, false)
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " set their own armor to " .. armorAmount)
end)

addCommandHandler("forcelogin", function(player, _, playerIdOrName)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! You need moderator level or higher.", player, 255, 100, 100, false)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /forcelogin [player]", player, 255, 255, 100, false)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Player not found!", player, 255, 100, 100, false)
        return
    end

    -- Force close login for target
    triggerClientEvent(target, "hideLoginGUI", target)
    setTimer(function()
        if isElement(target) then
            triggerClientEvent(target, "hideLoginGUI", target)
        end
    end, 100, 1)

    outputChatBox("Forced login window close for " .. getPlayerName(target), player, 100, 255, 100, false)
    outputChatBox("Admin has force-closed your login window", target, 255, 255, 100, false)
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " force closed login for " .. getPlayerName(target))
end)

-- /reloadmodels command - Hot reload custom models
addCommandHandler("reloadmodels", function(player, command)
    if not isPlayerAdmin(player, ADMIN_LEVELS.ADMIN) then
        outputChatBox("Access denied! You need administrator level or higher.", player, 255, 100, 100, false)
        return
    end

    outputChatBox("🔄 Reloading custom models...", player, 100, 255, 255, false)

    if reloadCustomModels then
        reloadCustomModels()
        outputChatBox("✅ Custom models reloaded successfully!", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " reloaded custom models")
    else
        outputChatBox("❌ Model reload function not available!", player, 255, 100, 100, false)
    end
end)

-- /acmds command - Show admin commands with GOD level support
addCommandHandler("acmds", function(player, command)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! You need moderator level or higher.", player, 255, 100, 100, false)
        return
    end

    local playerData = getElementData(player, "playerData")
    local adminLevel = (playerData and playerData.adminLevel) or 0

    outputChatBox("=== AMB Admin Commands ===", player, 255, 255, 100, false)
    outputChatBox("Vehicles: /cv [model] /listcv", player, 255, 255, 255, false)
    outputChatBox("Objects: /createobject [model] /listobjects", player, 255, 255, 255, false)
    outputChatBox("Skins: /changeskin [player] [skinID] /listskin", player, 255, 255, 255, false)
    outputChatBox("Moderator+: /goto /gethere /stats", player, 255, 255, 255, false)
    outputChatBox("Movement: /up /dn /lt /rt /fd /bk (Moderator+)", player, 100, 255, 100, false)
    outputChatBox("Admin+: /sethp /setarmor /giveweapon /jetpack [player]", player, 255, 255, 255, false)
    outputChatBox("Personal: /setmyhp /setmyarmor (Admin+ or Undercover)", player, 255, 255, 100, false)
    outputChatBox("Debug: /forcelogin [player] (Fix stuck login)", player, 255, 100, 255, false)
    outputChatBox("System: /reloadmodels (Hot reload models)", player, 255, 100, 255, false)
    outputChatBox("All: /time /myskin", player, 255, 255, 255, false)

    if adminLevel == ADMIN_LEVELS.GOD then
        outputChatBox("GOD Mode: Toàn quyền truy cập tất cả lệnh!", player, 255, 215, 0, false)
    end
end)

-- /makeadmin command - Hidden admin setup (silent operation)
addCommandHandler("makeadmin", function(player, command, playerIdOrName, level)
    outputDebugString("[DEBUG] /makeadmin called: playerIdOrName='" .. tostring(playerIdOrName) .. "', level='" ..
                          tostring(level) .. "'")

    -- Check args
    if not playerIdOrName or not level then
        outputChatBox("Su dung: /makeadmin [player] [level]", player, 255, 100, 100)
        return
    end

    level = tonumber(level)
    if not level then
        outputChatBox("Level phai la mot so.", player, 255, 100, 100)
        return
    end

    -- Optional: check if player executing has sufficient rights (example: must be GOD or FOUNDER)
    local myLevel = getElementData(player, "adminLevel") or 0
    if myLevel < ADMIN_LEVELS.FOUNDER then
        outputChatBox("Ban khong co quyen cap admin level.", player, 255, 100, 100)
        return
    end

    -- Get target player
    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay nguoi choi: " .. tostring(playerIdOrName), player, 255, 100, 100)
        return
    end

    -- Set admin level
    setElementData(target, "adminLevel", level)
    outputChatBox("Da cap level admin " .. level .. " cho " .. getPlayerName(target), player, 0, 255, 0)
    outputChatBox("Quyen admin cua ban da duoc cap level " .. level, target, 0, 255, 0)

    -- Optional: trigger client event
    triggerClientEvent(target, "onAdminLevelChanged", target, level)

    outputDebugString(string.format("[ADMIN] %s set admin level %d for %s", getPlayerName(player), level,
        getPlayerName(target)))
end)

-- ========================================
-- MOVEMENT COMMANDS (migrated from open.mp)
-- ========================================

-- /up command - Move player/vehicle up 5 units
addCommandHandler("up", function(player, command)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end

    local x, y, z = getElementPosition(player)
    local vehicle = getPedOccupiedVehicle(player)

    -- Check if player is driver of a vehicle (matches SA-MP logic)
    if vehicle and getVehicleOccupant(vehicle, 0) == player then
        -- Player is driver - move the vehicle up and reset speed
        setElementPosition(vehicle, x, y, z + 5)
        setElementVelocity(vehicle, 0, 0, 0) -- Reset vehicle speed like SA-MP
        outputChatBox("Vehicle moved up 5 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /up command (vehicle)")
    else
        -- Player is on foot or passenger - move the player up
        setElementPosition(player, x, y, z + 5)
        outputChatBox("Moved up 5 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /up command (on foot)")
    end
end)

-- /dn command - Move player/vehicle down 2 units (matches SA-MP)
addCommandHandler("dn", function(player, command)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end

    local x, y, z = getElementPosition(player)
    local vehicle = getPedOccupiedVehicle(player)

    -- Check if player is driver of a vehicle (matches SA-MP logic)
    if vehicle and getVehicleOccupant(vehicle, 0) == player then
        -- Player is driver - move the vehicle down and reset speed
        setElementPosition(vehicle, x, y, z - 2) -- SA-MP uses -2, not -5
        setElementVelocity(vehicle, 0, 0, 0) -- Reset vehicle speed like SA-MP
        outputChatBox("Vehicle moved down 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /dn command (vehicle)")
    else
        -- Player is on foot or passenger - move the player down
        setElementPosition(player, x, y, z - 2) -- SA-MP uses -2, not -5
        outputChatBox("Moved down 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /dn command (on foot)")
    end
end)

-- /lt command - Move player/vehicle left 2 units (matches SA-MP)
addCommandHandler("lt", function(player, command)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end

    local x, y, z = getElementPosition(player)
    local vehicle = getPedOccupiedVehicle(player)

    -- Check if player is driver of a vehicle (matches SA-MP logic)
    if vehicle and getVehicleOccupant(vehicle, 0) == player then
        -- Player is driver - move the vehicle left and reset speed
        setElementPosition(vehicle, x - 2, y, z) -- SA-MP uses -2, not -5
        setElementVelocity(vehicle, 0, 0, 0) -- Reset vehicle speed like SA-MP
        outputChatBox("Vehicle moved left 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /lt command (vehicle)")
    else
        -- Player is on foot or passenger - move the player left
        setElementPosition(player, x - 2, y, z) -- SA-MP uses -2, not -5
        outputChatBox("Moved left 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /lt command (on foot)")
    end
end)

-- /rt command - Move player/vehicle right 2 units (matches SA-MP)
addCommandHandler("rt", function(player, command)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end

    local x, y, z = getElementPosition(player)
    local vehicle = getPedOccupiedVehicle(player)

    -- Check if player is driver of a vehicle (matches SA-MP logic)
    if vehicle and getVehicleOccupant(vehicle, 0) == player then
        -- Player is driver - move the vehicle right and reset speed
        setElementPosition(vehicle, x + 2, y, z) -- SA-MP uses +2, not +5
        setElementVelocity(vehicle, 0, 0, 0) -- Reset vehicle speed like SA-MP
        outputChatBox("Vehicle moved right 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /rt command (vehicle)")
    else
        -- Player is on foot or passenger - move the player right
        setElementPosition(player, x + 2, y, z) -- SA-MP uses +2, not +5
        outputChatBox("Moved right 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /rt command (on foot)")
    end
end)

-- /fd command - Move player/vehicle forward 2 units (matches SA-MP)
addCommandHandler("fd", function(player, command)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end

    local x, y, z = getElementPosition(player)
    local vehicle = getPedOccupiedVehicle(player)

    -- Check if player is driver of a vehicle (matches SA-MP logic)
    if vehicle and getVehicleOccupant(vehicle, 0) == player then
        -- Player is driver - move the vehicle forward and reset speed
        setElementPosition(vehicle, x, y + 2, z) -- SA-MP uses +2, not +5
        setElementVelocity(vehicle, 0, 0, 0) -- Reset vehicle speed like SA-MP
        outputChatBox("Vehicle moved forward 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /fd command (vehicle)")
    else
        -- Player is on foot or passenger - move the player forward
        setElementPosition(player, x, y + 2, z) -- SA-MP uses +2, not +5
        outputChatBox("Moved forward 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /fd command (on foot)")
    end
end)

-- /bk command - Move player/vehicle backward 2 units (matches SA-MP)
addCommandHandler("bk", function(player, command)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end

    local x, y, z = getElementPosition(player)
    local vehicle = getPedOccupiedVehicle(player)

    -- Check if player is driver of a vehicle (matches SA-MP logic)
    if vehicle and getVehicleOccupant(vehicle, 0) == player then
        -- Player is driver - move the vehicle backward and reset speed
        setElementPosition(vehicle, x, y - 2, z) -- SA-MP uses -2, not -5
        setElementVelocity(vehicle, 0, 0, 0) -- Reset vehicle speed like SA-MP
        outputChatBox("Vehicle moved backward 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /bk command (vehicle)")
    else
        -- Player is on foot or passenger - move the player backward
        setElementPosition(player, x, y - 2, z) -- SA-MP uses -2, not -5
        outputChatBox("Moved backward 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /bk command (on foot)")
    end
end)

local flyPlayers = {} -- lưu trạng thái fly mỗi player
-- Toggle fly mode
addCommandHandler("fly", function(player)
    if not isPlayerAdmin(player, 2) then -- MODERATOR trở lên
        outputChatBox("Bạn không có quyền!", player, 255, 0, 0)
        return
    end

    local enabled = not flyPlayers[player]
    flyPlayers[player] = enabled

    -- gửi trạng thái xuống client
    triggerClientEvent(player, "flyMode:set", player, enabled)

    if enabled then
        -- Make player invulnerable during fly
        setElementData(player, "flymode_invulnerable", true)
        setElementHealth(player, 100)
        setPedArmor(player, 100)
        -- Spawn at safe height when enabling fly
        local x, y, z = getElementPosition(player)
        setElementPosition(player, x, y, z + 5.0)
        outputChatBox("✈️ Fly mode ON", player, 0, 255, 0)
    else
        setElementData(player, "flymode_invulnerable", false)
        outputChatBox("✈️ Fly mode OFF", player, 255, 0, 0)
    end
end)

-- Cleanup khi player quit
addEventHandler("onPlayerQuit", root, function()
    flyPlayers[source] = nil
end)

-- Protect flying players from damage
addEventHandler("onPlayerDamage", root, function()
    if getElementData(source, "flymode_invulnerable") then
        cancelEvent()
        setElementHealth(source, 100)
    end
end)

-- Prevent fall damage for flying players
addEventHandler("onPlayerWasted", root, function()
    if getElementData(source, "flymode_invulnerable") then
        cancelEvent()
        setTimer(function()
            spawnPlayer(source, getElementPosition(source))
            setElementHealth(source, 100)
        end, 100, 1)
    end
end)

-- Emergency landing event
addEvent("flyMode:emergencyLanding", true)
addEventHandler("flyMode:emergencyLanding", root, function()
    if flyPlayers[source] then
        flyPlayers[source] = false
        setElementData(source, "flymode_invulnerable", false)
        triggerClientEvent(source, "flyMode:set", source, false)
        outputChatBox("🚁 Emergency landing completed", source, 255, 255, 0)
    end
end)

-- Auto-disable when entering vehicle
addEvent("flyMode:autoDisable", true)
addEventHandler("flyMode:autoDisable", root, function()
    if flyPlayers[source] then
        flyPlayers[source] = false
        setElementData(source, "flymode_invulnerable", false)
        triggerClientEvent(source, "flyMode:set", source, false)
        outputChatBox("✈️ Fly mode disabled (entered vehicle)", source, 255, 255, 0)
    end
end)

-- Admin commands loaded notification
outputDebugString("[ADMIN_CMD] 30 commands loaded")
