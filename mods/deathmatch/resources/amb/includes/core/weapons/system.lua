-- ================================
-- AMB MTA:SA - Weapon & Combat Commands
-- Mass migration of weapon and combat commands
-- ================================
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

-- Give weapon to player (including custom weapons from newmodels_azul)
addCommandHandler("duavukhi", function(player, cmd, playerIdOrName, weaponID, ammo)
    local playerData = getElementData(player, "playerData") or {}

    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Chi admin level 2+ moi co the give weapon.", player, 255, 100, 100)
        return
    end

    if not playerIdOrName or not weaponID then
        outputChatBox("Su dung: /duavukhi [player_id] [weapon_id] [ammo]", player, 255, 255, 255)
        outputChatBox("VD: /duavukhi 0 19002 100 (Minecraft Diamond Pickaxe)", player, 255, 255, 100)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    local wepID = tonumber(weaponID)
    local ammoAmount = tonumber(ammo) or 100

    if not wepID then
        outputChatBox("❌ Weapon ID phai la so.", player, 255, 100, 100)
        return
    end

    -- Check if it's a custom weapon (19000+)
    if wepID >= 19001 and wepID < 20000 then
        local newmodelsResource = getResourceFromName("newmodels_azul")
        if newmodelsResource and getResourceState(newmodelsResource) == "running" then
            -- Use custom weapon from newmodels_azul - give as baseball bat but with custom model
            giveWeapon(targetPlayer, 5, ammoAmount, true) -- Baseball bat as base weapon

            -- Try to set custom model using newmodels_azul
            local success = exports["newmodels_azul"]:setElementCustomModel(targetPlayer, wepID)
            if success then
                outputChatBox(string.format("🔫 Da give custom weapon %d (%d ammo) cho %s.", wepID, ammoAmount,
                    getPlayerName(targetPlayer)), player, 0, 255, 0)
                outputChatBox(string.format("🔫 Admin %s da give ban custom weapon %d (%d ammo).",
                    getPlayerName(player), wepID, ammoAmount), targetPlayer, 255, 255, 100)
                setElementData(targetPlayer, "customWeaponID", wepID)
            else
                outputChatBox("❌ Failed to set custom weapon model " .. wepID, player, 255, 0, 0)
            end
        else
            outputChatBox("❌ newmodels_azul not running!", player, 255, 0, 0)
        end
    elseif (wepID >= 0 and wepID <= 46) then
        -- Standard weapon (0-46)

        giveWeapon(targetPlayer, wepID, ammoAmount, true)

        local weaponName = getWeaponNameFromID(wepID) or "Unknown"
        outputChatBox(string.format("🔫 Da give %s (%d ammo) cho %s.", weaponName, ammoAmount,
            getPlayerName(targetPlayer)), player, 0, 255, 0)
        outputChatBox(string.format("🔫 Admin %s da give ban %s (%d ammo).", getPlayerName(player), weaponName,
            ammoAmount), targetPlayer, 255, 255, 100)
    else
        outputChatBox("❌ Weapon ID khong hop le (0-46 hoac 19001-19999 cho custom).", player, 255, 100, 100)
    end
end)

-- Give object to player (for custom objects like Minecraft Diamond Pickaxe)
addCommandHandler("giveobject", function(player, cmd, playerIdOrName, objectID)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Chi admin level 2+ moi co the give object.", player, 255, 100, 100)
        return
    end

    if not playerIdOrName or not objectID then
        outputChatBox("Su dung: /giveobject [player_id] [object_id]", player, 255, 255, 255)
        outputChatBox("VD: /giveobject 0 19002 (Minecraft Diamond Pickaxe)", player, 255, 255, 100)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    local objID = tonumber(objectID)
    if not objID then
        outputChatBox("❌ Object ID phai la so.", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(targetPlayer)
    local _, _, rot = getElementRotation(targetPlayer)

    -- Position object in front of player
    local radRot = math.rad(rot)
    x = x + 2.0 * math.sin(radRot)
    y = y + 2.0 * math.cos(radRot)
    z = z + 0.5

    local object

    -- Use newmodels_azul for custom objects (19000+)
    if objID >= 19000 and objID < 30000 then
        local newmodelsResource = getResourceFromName("newmodels_azul")
        if newmodelsResource and getResourceState(newmodelsResource) == "running" then
            object = exports["newmodels_azul"]:createObject(objID, x, y, z, 0, 0, rot)
            if object then
                outputChatBox("✅ Custom object " .. objID .. " created for " .. getPlayerName(targetPlayer) .. "!",
                    player, 0, 255, 0)
                outputChatBox("✅ Admin gave you object " .. objID .. "!", targetPlayer, 0, 255, 0)
            else
                outputChatBox("❌ Failed to create custom object " .. objID, player, 255, 0, 0)
            end
        else
            outputChatBox("❌ newmodels_azul not running!", player, 255, 0, 0)
            return
        end
    else
        -- Standard GTA SA objects
        object = createObject(objID, x, y, z, 0, 0, rot)
        if object then
            outputChatBox("✅ Standard object " .. objID .. " created for " .. getPlayerName(targetPlayer) .. "!",
                player, 0, 255, 0)
            outputChatBox("✅ Admin gave you object " .. objID .. "!", targetPlayer, 0, 255, 0)
        else
            outputChatBox("❌ Failed to create object " .. objID, player, 255, 0, 0)
        end
    end

    if object then
        setElementInterior(object, getElementInterior(targetPlayer))
        setElementDimension(object, getElementDimension(targetPlayer))
    end
end)

-- Take weapon from player
addCommandHandler("takeweapon", function(player, cmd, playerIdOrName, weaponID)
    local playerData = getElementData(player, "playerData") or {}

    if (playerData.adminLevel or 0) < 2 then
        outputChatBox("❌ Chi admin level 2+ moi co the take weapon.", player, 255, 100, 100)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /takeweapon [player_id] [weapon_id]", player, 255, 255, 255)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    if weaponID then
        local wepID = tonumber(weaponID)
        if wepID and wepID >= 0 and wepID <= 46 then
            takeWeapon(targetPlayer, wepID)
            local weaponName = getWeaponNameFromID(wepID) or "Unknown"
            outputChatBox(string.format("🔫 Da take %s tu %s.", weaponName, getPlayerName(targetPlayer)), player, 255,
                255, 100)
            outputChatBox(string.format("🔫 Admin %s da take %s cua ban.", getPlayerName(player), weaponName),
                targetPlayer, 255, 100, 100)
        else
            outputChatBox("❌ Weapon ID khong hop le.", player, 255, 100, 100)
        end
    else
        -- Take all weapons
        takeAllWeapons(targetPlayer)
        outputChatBox(string.format("🔫 Da take tat ca weapons tu %s.", getPlayerName(targetPlayer)), player, 255,
            255, 100)
        outputChatBox(string.format("🔫 Admin %s da take tat ca weapons cua ban.", getPlayerName(player)),
            targetPlayer, 255, 100, 100)
    end
end)

-- Show weapon stats
addCommandHandler("weaponstats", function(player)
    local weapons = {}
    for slot = 0, 12 do
        local weapon = getPedWeapon(player, slot)
        if weapon and weapon > 0 then
            local ammo = getPedTotalAmmo(player, slot)
            local weaponName = getWeaponNameFromID(weapon) or "Unknown"
            table.insert(weapons, {
                name = weaponName,
                id = weapon,
                ammo = ammo
            })
        end
    end

    if #weapons == 0 then
        outputChatBox("🔫 Ban khong co weapon nao.", player, 255, 255, 100)
        return
    end

    outputChatBox("🔫 ===== WEAPON STATS =====", player, 255, 255, 0)
    for _, weapon in ipairs(weapons) do
        outputChatBox(string.format("• %s (ID:%d) - %d ammo", weapon.name, weapon.id, weapon.ammo), player, 255, 255,
            255)
    end
end)

-- Weapon shop
addCommandHandler("buyweapon", function(player, cmd, weaponID)
    if not weaponID then
        outputChatBox("🔫 ===== WEAPON SHOP =====", player, 255, 255, 0)
        outputChatBox("• /buyweapon 22 - Pistol ($500)", player, 255, 255, 255)
        outputChatBox("• /buyweapon 24 - Desert Eagle ($1500)", player, 255, 255, 255)
        outputChatBox("• /buyweapon 25 - Shotgun ($2000)", player, 255, 255, 255)
        outputChatBox("• /buyweapon 29 - MP5 ($3000)", player, 255, 255, 255)
        outputChatBox("• /buyweapon 30 - AK-47 ($5000)", player, 255, 255, 255)
        outputChatBox("• /buyweapon 31 - M4 ($5500)", player, 255, 255, 255)
        outputChatBox("• /buyweapon 34 - Sniper ($8000)", player, 255, 255, 255)
        return
    end

    local wepID = tonumber(weaponID)
    local weaponPrices = {
        [22] = {
            price = 500,
            ammo = 50,
            name = "Pistol"
        },
        [24] = {
            price = 1500,
            ammo = 35,
            name = "Desert Eagle"
        },
        [25] = {
            price = 2000,
            ammo = 25,
            name = "Shotgun"
        },
        [29] = {
            price = 3000,
            ammo = 120,
            name = "MP5"
        },
        [30] = {
            price = 5000,
            ammo = 180,
            name = "AK-47"
        },
        [31] = {
            price = 5500,
            ammo = 200,
            name = "M4"
        },
        [34] = {
            price = 8000,
            ammo = 50,
            name = "Sniper"
        }
    }

    local weapon = weaponPrices[wepID]
    if not weapon then
        outputChatBox("❌ Weapon khong co ban tai shop.", player, 255, 100, 100)
        return
    end

    local playerData = getElementData(player, "playerData") or {}
    if (playerData.money or 0) < weapon.price then
        outputChatBox(string.format("❌ Ban can $%d de mua %s.", weapon.price, weapon.name), player, 255, 100, 100)
        return
    end

    -- Check if at weapon shop
    local px, py, pz = getElementPosition(player)
    local weaponShops = {{1368.6, -1279.8, 13.5}, -- Los Santos
    {2400.5, -1981.8, 13.5}, -- Los Santos 2
    {-2625.8, 208.5, 4.8}, -- San Fierro
    {2539.7, 2084.0, 10.8} -- Las Venturas
    }

    local atShop = false
    for _, shop in ipairs(weaponShops) do
        if getDistanceBetweenPoints3D(px, py, pz, shop[1], shop[2], shop[3]) < 5 then
            atShop = true
            break
        end
    end

    if not atShop then
        outputChatBox("❌ Ban can o gan weapon shop de mua weapon.", player, 255, 100, 100)
        return
    end

    -- Buy weapon
    playerData.money = (playerData.money or 0) - weapon.price
    setElementData(player, "playerData", playerData)
    giveWeapon(player, wepID, weapon.ammo, true)

    outputChatBox(string.format("🔫 Da mua %s voi gia $%d (%d ammo)!", weapon.name, weapon.price, weapon.ammo),
        player, 0, 255, 0)
end)

-- Shoot command (fun)
addCommandHandler("shoot", function(player, cmd, playerIdOrName)
    if not playerIdOrName then
        outputChatBox("Su dung: /shoot [player_id]", player, 255, 255, 255)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    if targetPlayer == player then
        outputChatBox("❌ Ban khong the shoot chinh minh.", player, 255, 100, 100)
        return
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 20 then
        outputChatBox("❌ Target qua xa.", player, 255, 100, 100)
        return
    end

    -- Check if player has weapon
    local weapon = getPedWeapon(player)
    if weapon == 0 then
        outputChatBox("❌ Ban khong co weapon.", player, 255, 100, 100)
        return
    end

    local ammo = getPedTotalAmmo(player)
    if ammo <= 0 then
        outputChatBox("❌ Ban khong co ammo.", player, 255, 100, 100)
        return
    end

    -- Simulate shooting
    local damage = math.random(10, 30)
    local currentHealth = getElementHealth(targetPlayer)
    setElementHealth(targetPlayer, math.max(0, currentHealth - damage))

    local weaponName = getWeaponNameFromID(weapon) or "Unknown"
    outputChatBox(string.format("🔫 Da shoot %s voi %s (-%.1f HP)!", getPlayerName(targetPlayer), weaponName, damage),
        player, 255, 255, 100)
    outputChatBox(string.format("🔫 %s da shoot ban voi %s (-%.1f HP)!", getPlayerName(player), weaponName, damage),
        targetPlayer, 255, 100, 100)

    -- Reduce ammo
    setWeaponAmmo(player, weapon, ammo - 1)
end)

-- Duel system
addCommandHandler("duel", function(player, cmd, playerIdOrName)
    if not playerIdOrName then
        outputChatBox("Su dung: /duel [player_id]", player, 255, 255, 255)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    if targetPlayer == player then
        outputChatBox("❌ Ban khong the duel voi chinh minh.", player, 255, 100, 100)
        return
    end

    local playerData = getElementData(player, "playerData") or {}
    if playerData.inDuel then
        outputChatBox("❌ Ban dang o trong duel roi.", player, 255, 100, 100)
        return
    end

    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.inDuel then
        outputChatBox("❌ Nguoi choi dang o trong duel roi.", player, 255, 100, 100)
        return
    end

    -- Send duel request
    targetData.duelRequest = {
        from = player,
        time = getRealTime().timestamp
    }
    setElementData(targetPlayer, "playerData", targetData)

    outputChatBox(string.format("⚔️ Da gui duel request den %s.", getPlayerName(targetPlayer)), player, 255, 255,
        100)
    outputChatBox(string.format("⚔️ %s thach ban duel. Su dung /acceptduel hoac /denyduel.", getPlayerName(player)),
        targetPlayer, 255, 255, 100)
end)

-- Accept duel
addCommandHandler("acceptduel", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.duelRequest then
        outputChatBox("❌ Ban khong co duel request.", player, 255, 100, 100)
        return
    end

    local challenger = playerData.duelRequest.from
    if not isElement(challenger) then
        outputChatBox("❌ Duel request da expired.", player, 255, 100, 100)
        playerData.duelRequest = nil
        setElementData(player, "playerData", playerData)
        return
    end

    -- Start duel
    playerData.inDuel = {
        opponent = challenger,
        startTime = getRealTime().timestamp
    }
    playerData.duelRequest = nil

    local challengerData = getElementData(challenger, "playerData") or {}
    challengerData.inDuel = {
        opponent = player,
        startTime = getRealTime().timestamp
    }

    setElementData(player, "playerData", playerData)
    setElementData(challenger, "playerData", challengerData)

    -- Give weapons and teleport to arena
    local duelArena = {0, 0, 3} -- Arena coordinates
    setElementPosition(player, duelArena[1] + 5, duelArena[2], duelArena[3])
    setElementPosition(challenger, duelArena[1] - 5, duelArena[2], duelArena[3])

    -- Give same weapons
    takeAllWeapons(player)
    takeAllWeapons(challenger)
    giveWeapon(player, 24, 50, true) -- Desert Eagle
    giveWeapon(challenger, 24, 50, true)

    outputChatBox("⚔️ DUEL STARTED! Fight to the death!", player, 255, 0, 0)
    outputChatBox("⚔️ DUEL STARTED! Fight to the death!", challenger, 255, 0, 0)
end)

-- Deny duel
addCommandHandler("denyduel", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.duelRequest then
        outputChatBox("❌ Ban khong co duel request.", player, 255, 100, 100)
        return
    end

    local challenger = playerData.duelRequest.from
    playerData.duelRequest = nil
    setElementData(player, "playerData", playerData)

    if isElement(challenger) then
        outputChatBox(string.format("❌ %s da deny duel cua ban.", getPlayerName(player)), challenger, 255, 100, 100)
    end

    outputChatBox("❌ Da deny duel request.", player, 255, 100, 100)
end)

-- Knife fight
addCommandHandler("knifefight", function(player, cmd, playerIdOrName)
    if not playerIdOrName then
        outputChatBox("Su dung: /knifefight [player_id]", player, 255, 255, 255)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    if targetPlayer == player then
        outputChatBox("❌ Ban khong the knife fight voi chinh minh.", player, 255, 100, 100)
        return
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 3 then
        outputChatBox("❌ Ban qua xa de knife fight.", player, 255, 100, 100)
        return
    end

    -- Start knife fight
    takeAllWeapons(player)
    takeAllWeapons(targetPlayer)
    giveWeapon(player, 4, 1, true) -- Knife
    giveWeapon(targetPlayer, 4, 1, true)

    outputChatBox("🔪 KNIFE FIGHT! May the best fighter win!", player, 255, 0, 0)
    outputChatBox("🔪 KNIFE FIGHT! May the best fighter win!", targetPlayer, 255, 0, 0)

    -- Notify nearby players
    for _, nearPlayer in ipairs(getElementsByType("player")) do
        if nearPlayer ~= player and nearPlayer ~= targetPlayer then
            local nx, ny, nz = getElementPosition(nearPlayer)
            if getDistanceBetweenPoints3D(px, py, pz, nx, ny, nz) < 30 then
                outputChatBox(string.format("🔪 %s va %s dang knife fight!", getPlayerName(player),
                    getPlayerName(targetPlayer)), nearPlayer, 255, 255, 0)
            end
        end
    end
end)

-- Weapon drop
addCommandHandler("dropweapon", function(player)
    local weapon = getPedWeapon(player)
    if weapon == 0 then
        outputChatBox("❌ Ban khong co weapon de drop.", player, 255, 100, 100)
        return
    end

    local ammo = getPedTotalAmmo(player)
    takeWeapon(player, weapon)

    -- Create pickup at player position
    local x, y, z = getElementPosition(player)
    local pickup = createPickup(x, y, z, 2, weapon, 0, ammo)

    local weaponName = getWeaponNameFromID(weapon) or "Unknown"
    outputChatBox(string.format("🔫 Da drop %s (%d ammo).", weaponName, ammo), player, 255, 255, 100)

    -- Auto destroy pickup after 5 minutes
    setTimer(function()
        if isElement(pickup) then
            destroyElement(pickup)
        end
    end, 300000, 1)
end)

outputDebugString("[AMB] Weapon & Combat system loaded - 10 commands")
