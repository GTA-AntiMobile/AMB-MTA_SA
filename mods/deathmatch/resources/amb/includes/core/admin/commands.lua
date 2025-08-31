-- ========================================
-- AMB Admin Commands System (MTA Server)
-- Migrated from server/commands.lua for better organization
-- Uses centralized ADMIN_LEVELS from shared/enums.lua
-- ========================================

-- Helper function to find player by name or ID (simulates SA-MP sscanf "u")
local function getPlayerFromPartialName(nameOrID)
    -- Try to convert to number first (player ID)
    local playerID = tonumber(nameOrID)
    if playerID then
        for _, player in ipairs(getElementsByType("player")) do
            if getElementData(player, "ID") == playerID then
                return player
            end
        end
    end
    
    -- Search by partial name
    local nameOrID_lower = string.lower(nameOrID)
    local matches = {}
    
    for _, player in ipairs(getElementsByType("player")) do
        local playerName = string.lower(getPlayerName(player))
        if string.find(playerName, nameOrID_lower, 1, true) then
            table.insert(matches, player)
        end
    end
    
    -- Return exact match or single partial match
    if #matches == 1 then
        return matches[1]
    elseif #matches > 1 then
        return nil, "Multiple players found" -- Too many matches
    else
        return nil, "Player not found" -- No matches
    end
end

-- Permission check function with GOD level support
local function isPlayerAdmin(player, requiredLevel)
    if not isElement(player) then return false end
    
    -- Try to get adminLevel from ElementData first (more reliable)
    local adminLevel = getElementData(player, "adminLevel")
    
    -- Fallback to playerData if ElementData not set
    if not adminLevel then
        local playerData = getElementData(player, "playerData")
        adminLevel = playerData and playerData.adminLevel or 0
    end
    
    outputDebugString("[ADMIN] Player " .. getPlayerName(player) .. " has adminLevel: " .. adminLevel .. ", required: " .. requiredLevel)
    
    -- GOD level có toàn quyền
    if adminLevel == ADMIN_LEVELS.GOD then
        outputDebugString("[ADMIN] GOD level detected - granting access")
        return true
    end
    
    -- Check normal permission level
    local hasPermission = adminLevel >= requiredLevel
    outputDebugString("[ADMIN] Permission check result: " .. tostring(hasPermission))
    return hasPermission
end

-- Get weapon name from ID
local function getWeaponNameFromID(weaponID)
    local weaponNames = {
        [22] = "Colt 45",
        [23] = "Silenced Pistol", 
        [24] = "Desert Eagle",
        [25] = "Shotgun",
        [26] = "Sawn-off Shotgun",
        [27] = "Combat Shotgun",
        [28] = "Micro SMG",
        [29] = "MP5",
        [30] = "AK-47",
        [31] = "M4",
        [32] = "Tec-9",
        [33] = "Country Rifle",
        [34] = "Sniper Rifle"
    }
    return weaponNames[weaponID] or "Unknown Weapon"
end

-- /goto command - Teleport to player
addCommandHandler("goto", function(player, command, targetName)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! You need moderator level or higher.", player, 255, 100, 100, false)
        return
    end
    
    if not targetName then
        outputChatBox("Usage: /goto [player]", player, 255, 255, 100, false)
        return
    end
    
    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Player not found!", player, 255, 100, 100, false)
        return
    end
    
    if target == player then
        outputChatBox("You cannot teleport to yourself!", player, 255, 100, 100, false)
        return
    end
    
    local x, y, z = getElementPosition(target)
    local dimension = getElementDimension(target)
    local interior = getElementInterior(target)
    
    setElementPosition(player, x + 2, y, z)
    setElementDimension(player, dimension)
    setElementInterior(player, interior)
    
    outputChatBox("Teleported to " .. getPlayerName(target), player, 100, 255, 100, false)
    outputDebugString("[AMB Admin] " .. getPlayerName(player) .. " teleported to " .. getPlayerName(target))
end)

-- /gethere command - Teleport player to you
addCommandHandler("gethere", function(player, command, targetName)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! You need moderator level or higher.", player, 255, 100, 100, false)
        return
    end
    
    if not targetName then
        outputChatBox("Usage: /gethere [player]", player, 255, 255, 100, false)
        return
    end
    
    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Player not found!", player, 255, 100, 100, false)
        return
    end
    
    if target == player then
        outputChatBox("You cannot teleport yourself to yourself!", player, 255, 100, 100, false)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local dimension = getElementDimension(player)
    local interior = getElementInterior(player)
    
    setElementPosition(target, x + 2, y, z)
    setElementDimension(target, dimension)
    setElementInterior(target, interior)
    
    outputChatBox("Teleported " .. getPlayerName(target) .. " to your location", player, 100, 255, 100, false)
    outputChatBox("You have been teleported to " .. getPlayerName(player), target, 100, 255, 100, false)
    outputDebugString("[AMB Admin] " .. getPlayerName(player) .. " teleported " .. getPlayerName(target) .. " to them")
end)

-- /stats command - Show player statistics
addCommandHandler("stats", function(player, cmd, targetName)
    local target = player
    if targetName then
        -- Check if player has permission to view other players' stats
        if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
            outputChatBox("Access denied! You can only view your own stats.", player, 255, 100, 100, false)
            return
        end
        
        local foundTarget = getPlayerFromName(targetName)
        if not foundTarget then
            outputChatBox("Player not found!", player, 255, 0, 0, false)
            return
        end
        target = foundTarget
    end
    
    local targetData = getElementData(target, "playerData")
    if not targetData then
        outputChatBox("Player data not found!", player, 255, 0, 0, false)
        return
    end
    
    outputChatBox("=== Stats for " .. getPlayerName(target) .. " ===", player, 255, 255, 0, false)
    outputChatBox("Level: " .. (targetData.level or 1), player, 255, 255, 255, false)
    outputChatBox("Money: $" .. (targetData.money or 0), player, 255, 255, 255, false)
    outputChatBox("Job: " .. (targetData.job or "Unemployed"), player, 255, 255, 255, false)
    outputChatBox("Admin Level: " .. (targetData.adminLevel or 0), player, 255, 255, 255, false)
    
    if target ~= player then
        outputDebugString("[AMB Admin] " .. getPlayerName(player) .. " viewed stats for " .. getPlayerName(target))
    end
end)

local CUSTOM_VEHICLE_START = 30001
local CUSTOM_VEHICLE_END   = 40000
local REGULAR_VEHICLE_MIN  = 400
local REGULAR_VEHICLE_MAX  = 611

local BASE_CUSTOM_VEHICLE  = 411
local MAX_BASE_CUSTOM_ID   = 600 -- tuần tự 411->600

-- /cv command
-- addCommandHandler("cv", function(player, _, modelID, color1, color2)
--     modelID = tonumber(modelID)
--     if not modelID then
--         return outputChatBox("Usage: /cv [modelID]", player, 255, 215, 0)
--     end

--     local x, y, z = getElementPosition(player)
--     local _, _, rot = getElementRotation(player)
--     local radRot = math.rad(rot)
--     x = x + 3 * math.sin(radRot)
--     y = y + 3 * math.cos(radRot)

--     local vehicle = spawnAdminVehicle(modelID, x, y, z, 0, 0, rot)

--     if vehicle then
--         color1 = tonumber(color1) or 0
--         color2 = tonumber(color2) or 0
--         setVehicleColor(vehicle, color1, color1, color2, color2)
--         setElementInterior(vehicle, getElementInterior(player))
--         setElementDimension(vehicle, getElementDimension(player))
--         -- warpPedIntoVehicle(player, vehicle) -- enter luôn vào xe
--         outputChatBox("✅ Spawned vehicle: " .. modelID, player, 76, 175, 80)
--     else
--         outputChatBox("❌ Invalid modelID!", player, 255, 152, 0)
--     end
-- end)
-- command /cv
addCommandHandler("cv", function(player, cmd, idStr)
    local cid = tonumber(idStr)
    if not cid then
        outputChatBox("Usage: /cv [modelID]", player, 255, 0, 0)
        return
    end

    if not customVehicleModels[cid] then
        outputChatBox("❌ Custom model " .. tostring(cid) .. " not registered yet!", player, 255, 0, 0)
        outputDebugString("[SERVER] Missing mapping for CID " .. tostring(cid))
        return
    end

    local model = customVehicleModels[cid].realId
    outputDebugString(("[SERVER] Mapping CID %d -> realId %d"):format(cid, model))

    local x, y, z = getElementPosition(player)
    local veh = createVehicle(model, x + 2, y, z + 1)
    if veh then
        outputDebugString("[SERVER] 🚗 Spawned vehicle model " .. tostring(model))
    else
        outputDebugString("[SERVER] ❌ Failed to create vehicle with model " .. tostring(model))
    end
end)

-- /listcv command
addCommandHandler("listcv", function(player)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        return outputChatBox("Access denied! Moderator level required.", player, 255, 100, 100)
    end

    outputChatBox("=== CUSTOM VEHICLE INFO ===", player, 33, 150, 243)
    -- Vehicles
    outputChatBox("=== Vehicles ===", player, 255, 215, 0)
    if MTA_MODEL_DATA and MTA_MODEL_DATA.SERVER_VEHICLE_MODELS then
        local id = CUSTOM_VEHICLE_START
        for _, v in ipairs(MTA_MODEL_DATA.SERVER_VEHICLE_MODELS) do
            local name = v.vehicleName or v.baseName or "Unknown"
            outputChatBox(id .. " - " .. name, player, 100, 255, 100)
            id = id + 1
        end
    end
    -- Objects
    outputChatBox("=== Objects ===", player, 255, 215, 0)
    if MTA_MODEL_DATA and MTA_MODEL_DATA.SERVER_OBJECT_MODELS then
        local id = 19001
        for _, v in ipairs(MTA_MODEL_DATA.SERVER_OBJECT_MODELS) do
            local name = v.objectName or v.baseName or "Object"
            outputChatBox(id .. " - " .. name, player, 100, 255, 100)
            id = id + 1
        end
    end
    -- Skins
    outputChatBox("=== Skins ===", player, 255, 215, 0)
    if MTA_MODEL_DATA and MTA_MODEL_DATA.SERVER_SKIN_MODELS then
        local id = 20001
        for _, v in ipairs(MTA_MODEL_DATA.SERVER_SKIN_MODELS) do
            local name = v.baseName or v.skinName or "Skin"
            outputChatBox(id .. " - " .. name, player, 100, 255, 100)
            id = id + 1
        end
    end

    outputChatBox("Usage: /cv [model] | /createobject [model]", player, 74, 144, 226)
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " viewed custom vehicle info")
end)

-- /listskin command - Show custom skin info
addCommandHandler("listskin", function(player, command)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! You need moderator level or higher.", player, 255, 100, 100, false)
        return
    end
    
    outputChatBox("=== CUSTOM SKINS (MTA) ===", player, 33, 150, 243, false)
    if MTA_MODEL_DATA and MTA_MODEL_DATA.SERVER_SKIN_MODELS then
        local id = 20001
        for _, v in ipairs(MTA_MODEL_DATA.SERVER_SKIN_MODELS) do
            local name = v.baseName or v.skinName or "Skin"
            outputChatBox(tostring(id) .. " - " .. name, player, 100, 255, 100, false)
            id = id + 1
        end
    end
    outputChatBox("Su dung: /setskin [player] [skin_id]", player, 74, 144, 226, false)
    
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " viewed custom skin info")
end)

-- /createobject command - Create custom objects
addCommandHandler("createobject", function(player, command, objectID)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! You need moderator level or higher.", player, 255, 100, 100, false)
        return
    end
    
    if not objectID then
        outputChatBox("Usage: /createobject [object ID] (19001-19999)", player, 255, 255, 100, false)
        return
    end
    
    objectID = tonumber(objectID)
    if not objectID or objectID < 19001 or objectID > 19999 then
        outputChatBox("Invalid object ID! Use 19001-19999", player, 255, 100, 100, false)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local _, _, rot = getElementRotation(player)
    
    -- Position object in front of player
    local radRot = math.rad(rot)
    x = x + 3.0 * math.sin(radRot)
    y = y + 3.0 * math.cos(radRot)
    z = z + 0.5
    
    -- Check if it's a custom object and get base ID for MTA
    local actualObjectID = objectID
    local objectType = "Regular"
    if isCustomObject and isCustomObject(objectID) then
        -- For custom objects, we need to use base object ID
        actualObjectID = 1337 + ((objectID - 19001) % 10) -- Map to 1337-1346 range
        objectType = "Custom"
        outputDebugString("[ADMIN] Custom object " .. objectID .. " mapped to base ID " .. actualObjectID)
    end
    
    -- Create object
    local object = createObject(actualObjectID, x, y, z, 0, 0, rot)
    if object then
        setElementData(object, "customObjectID", objectID)
        setElementData(player, "lastObject", object)
        
        outputChatBox("Da tao " .. objectType .. " object (Model: " .. objectID .. ")", player, 76, 175, 80, false)
        outputDebugString("[ADMIN] " ..
            getPlayerName(player) .. " created " .. objectType .. " object " .. objectID .. " successfully")
    else
        outputChatBox("Khong the tao object! Co loi xay ra.", player, 255, 107, 107, false)
        outputDebugString("[ADMIN] /createobject failed to create object for " .. getPlayerName(player))
    end
end)

-- /veh command - Create vehicle
addCommandHandler("veh", function(player, command, vehicleID)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! You need moderator level or higher.", player, 255, 100, 100, false)
        return
    end
    
    if not vehicleID then
        outputChatBox("Usage: /veh [vehicle ID] (400-611)", player, 255, 255, 100, false)
        return
    end
    
    vehicleID = tonumber(vehicleID)
    if not vehicleID or vehicleID < 400 or vehicleID > 611 then
        outputChatBox("Invalid vehicle ID! Use 400-611", player, 255, 100, 100, false)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local _, _, rot = getElementRotation(player)

    -- -- Destroy previous admin vehicle if exists
    -- local prevVehicle = getElementData(player, "adminVehicle")
    -- if prevVehicle and isElement(prevVehicle) then
    --     destroyElement(prevVehicle)
    -- end

    -- Create new vehicle
    local vehicle = createVehicle(vehicleID, x + 3, y, z + 1, 0, 0, rot)
    if vehicle then
        setElementData(player, "adminVehicle", vehicle)
        outputChatBox("Vehicle created! ID: " .. vehicleID, player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " created vehicle " .. vehicleID)
    else
        outputChatBox("Failed to create vehicle!", player, 255, 100, 100, false)
    end
end)

-- /sethp command - Set player health (matches SA-MP logic exactly)
addCommandHandler("sethp", function(player, command, targetName, hp)
    if not isPlayerAdmin(player, ADMIN_LEVELS.ADMIN) then  -- SA-MP requires level 4+
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end
    
    if not targetName or not hp then
        outputChatBox("SU DUNG: /sethp [Player] [health]", player, 255, 100, 100, false)
        return
    end
    
    local target, error = getPlayerFromPartialName(targetName)
    if not target then
        outputChatBox(error or "Nguoi choi khong hop le.", player, 255, 100, 100, false)
        return
    end
    
    local healthAmount = tonumber(hp)
    if not healthAmount then
        outputChatBox("Invalid health amount.", player, 255, 100, 100, false)
        return
    end
    
    -- Check jail time (simulate SA-MP pJailTime check)
    local targetJailTime = getElementData(target, "player.jailTime") or 0
    if targetJailTime >= 1 then
        outputChatBox("Ban khong the thiet lap HP cho nguoi o tu OOC!", player, 255, 255, 255, false)
        return
    end
    
    -- Admin protection check (like SA-MP)
    local playerAdminLevel = getElementData(player, "adminLevel") or 0
    local targetAdminLevel = getElementData(target, "adminLevel") or 0
    if targetAdminLevel >= playerAdminLevel and target ~= player then
        outputChatBox("Ban khong the lam dieu nay tren mot Admin cap cao!", player, 255, 100, 100, false)
        return
    end
    
    setElementHealth(target, healthAmount)
    outputChatBox("Ban da thiet lap " .. getPlayerName(target) .. "'s health cho " .. healthAmount .. ".", player, 255, 255, 255, false)
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " set " .. getPlayerName(target) .. "'s health to " .. healthAmount)
end)

-- /setmyhp command - Set own health (matches SA-MP logic)
addCommandHandler("setmyhp", function(player, command, hp)
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

-- /setarmor command - Set player armor (matches SA-MP logic exactly)
addCommandHandler("setarmor", function(player, command, targetName, armor)
    if not isPlayerAdmin(player, ADMIN_LEVELS.ADMIN) then  -- SA-MP requires level 4+
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end
    
    if not targetName or not armor then
        outputChatBox("SU DUNG: /setarmor [Player] [armor]", player, 255, 100, 100, false)
        return
    end
    
    local target, error = getPlayerFromPartialName(targetName)
    if not target then
        outputChatBox(error or "Nguoi choi khong hop le.", player, 255, 100, 100, false)
        return
    end
    
    local armorAmount = tonumber(armor)
    if not armorAmount then
        outputChatBox("Invalid armor amount.", player, 255, 100, 100, false)
        return
    end
    
    setPedArmor(target, armorAmount)
    outputChatBox("Ban da thiet lap " .. getPlayerName(target) .. "'s armor cho " .. armorAmount .. ".", player, 255, 255, 255, false)
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " set " .. getPlayerName(target) .. "'s armor to " .. armorAmount)
end)

-- /setmyarmor command - Set own armor (matches SA-MP logic)
addCommandHandler("setmyarmor", function(player, command, armor)
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

-- /giveweapon command - Give weapon to player
addCommandHandler("giveweapon", function(player, command, targetName, weaponID, ammo)
    if not isPlayerAdmin(player, ADMIN_LEVELS.ADMIN) then
        outputChatBox("Access denied! You need admin level or higher.", player, 255, 100, 100, false)
        return
    end
    
    if not targetName or not weaponID then
        outputChatBox("Usage: /giveweapon [player] [weapon ID] [ammo=100]", player, 255, 255, 100, false)
        return
    end
    
    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Player not found!", player, 255, 100, 100, false)
        return
    end
    
    weaponID = tonumber(weaponID)
    if not weaponID or weaponID < 1 or weaponID > 46 then
        outputChatBox("Invalid weapon ID! Use 1-46", player, 255, 100, 100, false)
        return
    end
    
    ammo = tonumber(ammo) or 100
    if ammo < 1 or ammo > 9999 then
        outputChatBox("Invalid ammo amount! Use 1-9999", player, 255, 100, 100, false)
        return
    end
    
    giveWeapon(target, weaponID, ammo)
    
    local weaponName = getWeaponNameFromID(weaponID)
    outputChatBox("Gave " .. getPlayerName(target) .. " weapon " .. weaponName .. " (" .. weaponID .. ") with " .. ammo .. " ammo", player, 100, 255, 100, false)
    outputChatBox("You received weapon " .. weaponName .. " (" .. weaponID .. ") with " .. ammo .. " ammo from " .. getPlayerName(player), target, 100, 255, 100, false)
    outputDebugString("[AMB Admin] " .. getPlayerName(player) .. " gave " .. getPlayerName(target) .. " weapon " .. weaponID .. " with " .. ammo .. " ammo")
end)

-- /time command - Show current time
addCommandHandler("time", function(player)
    local time = getRealTime()
    local timeStr = string.format("%02d:%02d:%02d", time.hour, time.minute, time.second)
    outputChatBox("Current time: " .. timeStr, player, 255, 255, 0, false)
end)

-- /forcelogin command - Force close login window for stuck players
addCommandHandler("forcelogin", function(player, command, targetName)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Access denied! You need moderator level or higher.", player, 255, 100, 100, false)
        return
    end
    
    if not targetName then
        outputChatBox("Usage: /forcelogin [player]", player, 255, 255, 100, false)
        return
    end
    
    local target = getPlayerFromPartialName(targetName)
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
    if not isPlayerAdmin(player, ADMIN_LEVELS.ADMINISTRATOR) then
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
    outputChatBox("Vehicles: /cv [model] /veh [model] /listcv", player, 255, 255, 255, false)
    outputChatBox("Objects: /createobject [model] (19001-19999)", player, 255, 255, 255, false)
    outputChatBox("Skins: /setskin [player] [skinID] /listskin", player, 255, 255, 255, false)
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
addCommandHandler("makeadmin", function(player, command, targetPlayer, level)
    if not targetPlayer or not level then
        -- Silent failure - no help message to avoid exposure
        return
    end
    
    local target = getPlayerFromName(targetPlayer)
    if not target then
        -- Silent failure
        return
    end
    
    level = tonumber(level)
    if not level or level < 0 or (level > ADMIN_LEVELS.FOUNDER and level ~= ADMIN_LEVELS.GOD) then
        -- Silent failure
        return
    end
    
    local targetData = getElementData(target, "playerData") or {}
    targetData.adminLevel = level
    setElementData(target, "playerData", targetData)
    
    local levelName = "Unknown"
    if level == ADMIN_LEVELS.GOD then
        levelName = "GOD (Toàn quyền)"
    elseif level == ADMIN_LEVELS.FOUNDER then
        levelName = "Founder"
    elseif level == ADMIN_LEVELS.DEVELOPER then
        levelName = "Developer"
    elseif level == ADMIN_LEVELS.MANAGEMENT then
        levelName = "Management"
    elseif level == ADMIN_LEVELS.HEAD_ADMIN then
        levelName = "Head Admin"
    elseif level == ADMIN_LEVELS.SENIOR_ADMIN then
        levelName = "Senior Admin"
    elseif level == ADMIN_LEVELS.ADMIN then
        levelName = "Admin"
    elseif level == ADMIN_LEVELS.MODERATOR then
        levelName = "Moderator"
    elseif level == ADMIN_LEVELS.HELPER then
        levelName = "Helper"
    else
        levelName = "Player"
    end
    
    outputChatBox("Set " .. getPlayerName(target) .. "'s admin level to " .. level .. " (" .. levelName .. ")", player, 100, 255, 100, false)
    -- Silent notification to target (no sender info)
    outputChatBox("Your admin level has been updated to " .. level .. " (" .. levelName .. ")", target, 100, 255, 100, false)
    -- Silent debug log only
    outputDebugString("[AMB Admin] Admin level set: " .. getPlayerName(target) .. " -> " .. level .. " (" .. levelName .. ")")
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
        setElementVelocity(vehicle, 0, 0, 0)  -- Reset vehicle speed like SA-MP
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
        setElementPosition(vehicle, x, y, z - 2)  -- SA-MP uses -2, not -5
        setElementVelocity(vehicle, 0, 0, 0)  -- Reset vehicle speed like SA-MP
        outputChatBox("Vehicle moved down 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /dn command (vehicle)")
    else
        -- Player is on foot or passenger - move the player down
        setElementPosition(player, x, y, z - 2)  -- SA-MP uses -2, not -5
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
        setElementPosition(vehicle, x - 2, y, z)  -- SA-MP uses -2, not -5
        setElementVelocity(vehicle, 0, 0, 0)  -- Reset vehicle speed like SA-MP
        outputChatBox("Vehicle moved left 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /lt command (vehicle)")
    else
        -- Player is on foot or passenger - move the player left
        setElementPosition(player, x - 2, y, z)  -- SA-MP uses -2, not -5
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
        setElementPosition(vehicle, x + 2, y, z)  -- SA-MP uses +2, not +5
        setElementVelocity(vehicle, 0, 0, 0)  -- Reset vehicle speed like SA-MP
        outputChatBox("Vehicle moved right 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /rt command (vehicle)")
    else
        -- Player is on foot or passenger - move the player right
        setElementPosition(player, x + 2, y, z)  -- SA-MP uses +2, not +5
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
        setElementPosition(vehicle, x, y + 2, z)  -- SA-MP uses +2, not +5
        setElementVelocity(vehicle, 0, 0, 0)  -- Reset vehicle speed like SA-MP
        outputChatBox("Vehicle moved forward 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /fd command (vehicle)")
    else
        -- Player is on foot or passenger - move the player forward
        setElementPosition(player, x, y + 2, z)  -- SA-MP uses +2, not +5
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
        setElementPosition(vehicle, x, y - 2, z)  -- SA-MP uses -2, not -5
        setElementVelocity(vehicle, 0, 0, 0)  -- Reset vehicle speed like SA-MP
        outputChatBox("Vehicle moved backward 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /bk command (vehicle)")
    else
        -- Player is on foot or passenger - move the player backward
        setElementPosition(player, x, y - 2, z)  -- SA-MP uses -2, not -5
        outputChatBox("Moved backward 2 units.", player, 100, 255, 100, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /bk command (on foot)")
    end
end)

-- /fly command - Admin flying mode (matches SA-MP logic)
addCommandHandler("fly", function(player, command)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local isFlying = getElementData(player, "admin.flying") or false
    
    if isFlying then
        -- Disable flying mode
        setElementData(player, "admin.flying", false)
        setPedGravity(player, 0.008) -- Restore normal gravity
        setElementPosition(player, x, y, z + 0.5) -- Small position adjustment like SA-MP
        setElementHealth(player, 100)
        setPedArmor(player, 100)
        -- Clear animation when disabling fly (matches Pawn)
        if clearPedTasks then clearPedTasks(player) end
        outputChatBox("Admin flying mode disabled.", player, 255, 255, 0, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " disabled flying mode")
    else
        -- Enable flying mode  
        setElementData(player, "admin.flying", true)
        setPedGravity(player, 0) -- Remove gravity
        setElementPosition(player, x, y, z + 5) -- Move up 5 units like SA-MP
        setElementHealth(player, 1000000000) -- Massive health like SA-MP
        setPedArmor(player, 1000000000) -- Massive armor like SA-MP
        outputChatBox("Admin flying mode enabled. Use movement commands to fly.", player, 0, 255, 0, false)
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " enabled flying mode")
    end
end)

-- /jetpack command - Admin jetpack system (matches SA-MP logic)  
addCommandHandler("jetpack", function(player, command, targetName)
    -- Level 2+ can use for themselves (no params)
    if not targetName then
        if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
            outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
            return
        end
        
        if isPedWearingJetpack(player) then
            setPedWearingJetpack(player, false)
            outputChatBox("Jetpack removed.", player, 255, 255, 0, false)
        else
            setPedWearingJetpack(player, true)
            outputChatBox("Jetpack equipped. Enjoy!", player, 0, 255, 0, false)
        end
        outputDebugString("[ADMIN] " .. getPlayerName(player) .. " used /jetpack on themselves")
        return
    end
    
    -- Level 4+ can give to others
    if not isPlayerAdmin(player, ADMIN_LEVELS.ADMIN) then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100, false)
        return
    end
    
    local target, error = getPlayerFromPartialName(targetName)
    if not target then
        outputChatBox(error or ("Player not found: " .. targetName), player, 255, 100, 100, false)
        return
    end
    
    setPedWearingJetpack(target, true)
    outputChatBox("Hay thuong thuc Jetpack cua ban!", target, 0, 255, 0, false)
    
    -- Global announcement like SA-MP
    local adminName = getPlayerName(player)
    local targetPlayerName = getPlayerName(target)
    outputChatBox("AdmCmd: " .. targetPlayerName .. " da nhan duoc Jetpack tu " .. adminName, root, 255, 100, 100, false)
    
    -- Admin log
    outputDebugString("[ADMIN] " .. adminName .. " gave jetpack to " .. targetPlayerName)
end)

outputDebugString("[AMB] Admin Commands loaded successfully!")
