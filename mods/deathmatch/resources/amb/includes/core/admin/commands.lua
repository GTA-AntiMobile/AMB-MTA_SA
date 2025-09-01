-- ========================================
-- AMB Admin Commands System (MTA Server)
-- Migrated from server/commands.lua for better organization
-- Uses centralized ADMIN_LEVELS from shared/enums.lua
-- ========================================

-- Dynamic model scanning functions for newmodels_azul
local function getNewmodelsAvailableModels()
    local models = {
        vehicles = {},
        objects = {},
        peds = {}
    }
    
    local newmodelsResource = getResourceFromName("newmodels_azul")
    if not newmodelsResource or getResourceState(newmodelsResource) ~= "running" then
        return models
    end
    
    -- Use newmodels_azul exports to get dynamic model list
    if exports["newmodels_azul"] and exports["newmodels_azul"].getCustomModels then
        local customModels = exports["newmodels_azul"]:getCustomModels()
        if customModels then
            -- Parse the dynamic model data from newmodels_azul
            for id, modelData in pairs(customModels) do
                if modelData.elementType == "vehicle" then
                    table.insert(models.vehicles, {
                        id = id,
                        name = modelData.name or modelData.fileName or "Unknown Vehicle",
                        baseModel = modelData.baseID
                    })
                elseif modelData.elementType == "object" then
                    table.insert(models.objects, {
                        id = id,
                        name = modelData.name or modelData.fileName or "Unknown Object",
                        baseModel = modelData.baseID
                    })
                elseif modelData.elementType == "ped" then
                    table.insert(models.peds, {
                        id = id,
                        name = modelData.name or modelData.fileName or "Unknown Ped",
                        baseModel = modelData.baseID
                    })
                end
            end
        end
    end
    
    return models
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

    outputDebugString("[ADMIN] Player " ..
        getPlayerName(player) .. " has adminLevel: " .. adminLevel .. ", required: " .. requiredLevel)

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

-- /cv command - Create vehicle using newmodels_azul
addCommandHandler("cv", function(player, cmd, idStr)
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
            outputChatBox("❌ Invalid vehicle ID! Use 400-611 for standard vehicles or 30000+ for custom", player, 255, 0, 0)
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
        outputDebugString("[CV] " .. getPlayerName(player) .. " created vehicle " .. cid)
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
addCommandHandler("createobject", function(player, command, objectIDStr)
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
            outputChatBox("❌ Invalid object ID! Use 1-18000 for standard objects or 19000+ for custom", player, 255, 0, 0, false)
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

-- /sethp command - Set player health (matches SA-MP logic exactly)
addCommandHandler("sethp", function(player, command, targetName, hp)
    if not isPlayerAdmin(player, ADMIN_LEVELS.ADMIN) then -- SA-MP requires level 4+
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
    outputChatBox("Ban da thiet lap " .. getPlayerName(target) .. "'s health cho " .. healthAmount .. ".", player, 255,
        255, 255, false)
    outputDebugString("[ADMIN] " ..
        getPlayerName(player) .. " set " .. getPlayerName(target) .. "'s health to " .. healthAmount)
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
    if not isPlayerAdmin(player, ADMIN_LEVELS.ADMIN) then -- SA-MP requires level 4+
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
    outputChatBox("Ban da thiet lap " .. getPlayerName(target) .. "'s armor cho " .. armorAmount .. ".", player, 255, 255,
        255, false)
    outputDebugString("[ADMIN] " ..
        getPlayerName(player) .. " set " .. getPlayerName(target) .. "'s armor to " .. armorAmount)
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
    outputChatBox(
        "Gave " .. getPlayerName(target) .. " weapon " .. weaponName .. " (" .. weaponID .. ") with " .. ammo .. " ammo",
        player, 100, 255, 100, false)
    outputChatBox(
        "You received weapon " ..
        weaponName .. " (" .. weaponID .. ") with " .. ammo .. " ammo from " .. getPlayerName(player), target, 100, 255,
        100,
        false)
    outputDebugString("[AMB Admin] " ..
        getPlayerName(player) ..
        " gave " .. getPlayerName(target) .. " weapon " .. weaponID .. " with " .. ammo .. " ammo")
end) -- /forcelogin command - Force close login window for stuck players
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

    outputChatBox("Set " .. getPlayerName(target) .. "'s admin level to " .. level .. " (" .. levelName .. ")", player,
        100, 255, 100, false)
    -- Silent notification to target (no sender info)
    outputChatBox("Your admin level has been updated to " .. level .. " (" .. levelName .. ")", target, 100, 255, 100,
        false)
    -- Silent debug log only
    outputDebugString("[AMB Admin] Admin level set: " ..
        getPlayerName(target) .. " -> " .. level .. " (" .. levelName .. ")")
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
        setElementVelocity(vehicle, 0, 0, 0)     -- Reset vehicle speed like SA-MP
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
        setElementVelocity(vehicle, 0, 0, 0)     -- Reset vehicle speed like SA-MP
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
        setElementVelocity(vehicle, 0, 0, 0)     -- Reset vehicle speed like SA-MP
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
        setElementVelocity(vehicle, 0, 0, 0)     -- Reset vehicle speed like SA-MP
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
        setElementVelocity(vehicle, 0, 0, 0)     -- Reset vehicle speed like SA-MP
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
        outputChatBox("✈️ Fly mode ON", player, 0, 255, 0)
    else
        outputChatBox("✈️ Fly mode OFF", player, 255, 0, 0)
    end
end)

-- Cleanup khi player quit
addEventHandler("onPlayerQuit", root, function()
    flyPlayers[source] = nil
end)

outputDebugString("[AMB] Admin Commands loaded successfully!")
