-- ================================
-- AMB MTA:SA - Admin Vehicle & Weapon System
-- Mass migration of admin vehicle and weapon commands  
-- ================================

-- Admin give vehicle command
addCommandHandler("aveh", function(player, cmd, vehicleID, color1, color2)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not vehicleID then
        outputChatBox("Su dung: /aveh [vehicle_id] [color1] [color2]", player, 255, 255, 255)
        return
    end
    
    local vehID = tonumber(vehicleID)
    if not vehID or vehID < 400 or vehID > 611 then
        outputChatBox("❌ ID xe khong hop le (400-611).", player, 255, 100, 100)
        return
    end
    
    local col1 = tonumber(color1) or math.random(0, 255)
    local col2 = tonumber(color2) or math.random(0, 255)
    
    -- Get player position and rotation
    local x, y, z = getElementPosition(player)
    local _, _, rz = getElementRotation(player)
    
    -- Create vehicle
    local vehicle = createVehicle(vehID, x + 3, y, z + 1, 0, 0, rz)
    if vehicle then
        setVehicleColor(vehicle, col1, col2, 0, 0, 0, 0)
        
        -- Set admin as owner temporarily
        setElementData(vehicle, "owner", getPlayerName(player))
        setElementData(vehicle, "adminSpawned", true)
        
        outputChatBox(string.format("✅ Da tao xe %s (ID: %d) mau %d,%d.", getVehicleName(vehicle), vehID, col1, col2), player, 0, 255, 0)
        
        outputDebugString("[ADMIN VEHICLE] " .. getPlayerName(player) .. " spawned vehicle " .. vehID)
    else
        outputChatBox("❌ Khong the tao xe.", player, 255, 100, 100)
    end
end)

-- Admin give vehicle to player
addCommandHandler("agiveveh", function(player, cmd, playerIdOrName, vehicleID, color1, color2)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName or not vehicleID then
        outputChatBox("Su dung: /agiveveh [player_id] [vehicle_id] [color1] [color2]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local vehID = tonumber(vehicleID)
    if not vehID or vehID < 400 or vehID > 611 then
        outputChatBox("❌ ID xe khong hop le (400-611).", player, 255, 100, 100)
        return
    end
    
    local col1 = tonumber(color1) or math.random(0, 255)
    local col2 = tonumber(color2) or math.random(0, 255)
    
    -- Get target position
    local x, y, z = getElementPosition(targetPlayer)
    local _, _, rz = getElementRotation(targetPlayer)
    
    -- Create vehicle
    local vehicle = createVehicle(vehID, x + 3, y, z + 1, 0, 0, rz)
    if vehicle then
        setVehicleColor(vehicle, col1, col2, 0, 0, 0, 0)
        
        -- Set target as owner
        setElementData(vehicle, "owner", getPlayerName(targetPlayer))
        setElementData(vehicle, "adminGiven", true)
        
        local adminName = getPlayerName(player)
        local targetName = getPlayerName(targetPlayer)
        
        outputChatBox(string.format("✅ Da cho %s xe %s (ID: %d).", targetName, getVehicleName(vehicle), vehID), player, 0, 255, 0)
        outputChatBox(string.format("🎁 Ban da nhan xe %s tu Admin %s!", getVehicleName(vehicle), adminName), targetPlayer, 0, 255, 0)
        
        outputDebugString("[ADMIN GIVE VEHICLE] " .. adminName .. " gave " .. targetName .. " vehicle " .. vehID)
    else
        outputChatBox("❌ Khong the tao xe.", player, 255, 100, 100)
    end
end)

-- Admin destroy vehicle command
addCommandHandler("avehkill", function(player, cmd)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    -- Find nearest vehicle
    local px, py, pz = getElementPosition(player)
    local nearestVeh = nil
    local minDistance = 10
    
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        local vx, vy, vz = getElementPosition(vehicle)
        local distance = getDistanceBetweenPoints3D(px, py, pz, vx, vy, vz)
        if distance < minDistance then
            nearestVeh = vehicle
            minDistance = distance
        end
    end
    
    if nearestVeh then
        local vehName = getVehicleName(nearestVeh)
        destroyElement(nearestVeh)
        outputChatBox(string.format("✅ Da xoa xe %s gan nhat.", vehName), player, 0, 255, 0)
        
        outputDebugString("[ADMIN DESTROY VEHICLE] " .. getPlayerName(player) .. " destroyed " .. vehName)
    else
        outputChatBox("❌ Khong tim thay xe nao gan day.", player, 255, 100, 100)
    end
end)

-- Admin repair vehicle command
addCommandHandler("arepair", function(player, cmd, playerIdOrName)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    local targetPlayer = player
    
    if playerIdOrName then
        if not isPlayerAdmin(player, 2) then
            outputChatBox("❌ Ban can level 2+ de repair xe nguoi khac.", player, 255, 100, 100)
            return
        end
        
        for _, p in ipairs(getElementsByType("player")) do
            if getElementData(p, "playerID") == tonumber(playerIdOrName) then
                targetPlayer = p
                break
            end
        end
        
        if not targetPlayer then
            outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
            return
        end
    end
    
    local vehicle = getPedOccupiedVehicle(targetPlayer)
    if not vehicle then
        outputChatBox("❌ Nguoi choi khong o trong xe.", player, 255, 100, 100)
        return
    end
    
    -- Repair vehicle
    fixVehicle(vehicle)
    setVehicleEngineState(vehicle, true)
    
    local targetName = getPlayerName(targetPlayer)
    
    if targetPlayer == player then
        outputChatBox("✅ Da sua xe cua ban.", player, 0, 255, 0)
    else
        outputChatBox(string.format("✅ Da sua xe cua %s.", targetName), player, 0, 255, 0)
        outputChatBox(string.format("🔧 Xe cua ban da duoc Admin %s sua.", getPlayerName(player)), targetPlayer, 0, 255, 0)
    end
    
    outputDebugString("[ADMIN REPAIR] " .. getPlayerName(player) .. " repaired vehicle for " .. targetName)
end)

-- Admin give weapon command
addCommandHandler("aweapon", function(player, cmd, weaponID, ammo)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not weaponID then
        outputChatBox("Su dung: /aweapon [weapon_id] [ammo]", player, 255, 255, 255)
        return
    end
    
    local wepID = tonumber(weaponID)
    local wepAmmo = tonumber(ammo) or 200
    
    if not wepID or wepID < 1 or wepID > 46 then
        outputChatBox("❌ ID vu khi khong hop le (1-46).", player, 255, 100, 100)
        return
    end
    
    -- Give weapon
    giveWeapon(player, wepID, wepAmmo, true)
    
    local weaponName = getWeaponNameFromID(wepID) or "Unknown"
    outputChatBox(string.format("✅ Da nhan vu khi %s voi %d dan.", weaponName, wepAmmo), player, 0, 255, 0)
    
    outputDebugString("[ADMIN WEAPON] " .. getPlayerName(player) .. " gave self weapon " .. wepID)
end)

-- Admin give weapon to player
addCommandHandler("agiveweapon", function(player, cmd, playerIdOrName, weaponID, ammo)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName or not weaponID then
        outputChatBox("Su dung: /agiveweapon [player_id] [weapon_id] [ammo]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local wepID = tonumber(weaponID)
    local wepAmmo = tonumber(ammo) or 200
    
    if not wepID or wepID < 1 or wepID > 46 then
        outputChatBox("❌ ID vu khi khong hop le (1-46).", player, 255, 100, 100)
        return
    end
    
    -- Give weapon to target
    giveWeapon(targetPlayer, wepID, wepAmmo, true)
    
    local weaponName = getWeaponNameFromID(wepID) or "Unknown"
    local adminName = getPlayerName(player)
    local targetName = getPlayerName(targetPlayer)
    
    outputChatBox(string.format("✅ Da cho %s vu khi %s voi %d dan.", targetName, weaponName, wepAmmo), player, 0, 255, 0)
    outputChatBox(string.format("🎁 Ban da nhan vu khi %s tu Admin %s!", weaponName, adminName), targetPlayer, 0, 255, 0)
    
    outputDebugString("[ADMIN GIVE WEAPON] " .. adminName .. " gave " .. targetName .. " weapon " .. wepID)
end)

-- Admin disarm player command
addCommandHandler("adisarm", function(player, cmd, playerIdOrName)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /adisarm [player_id]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    -- Remove all weapons
    takeAllWeapons(targetPlayer)
    
    local adminName = getPlayerName(player)
    local targetName = getPlayerName(targetPlayer)
    
    outputChatBox(string.format("✅ Da disarm %s.", targetName), player, 0, 255, 0)
    outputChatBox(string.format("🚫 Tat ca vu khi cua ban da bi Admin %s thu hoi.", adminName), targetPlayer, 255, 100, 100)
    
    outputDebugString("[ADMIN DISARM] " .. adminName .. " disarmed " .. targetName)
end)

-- Admin weapon info command
addCommandHandler("aweaponinfo", function(player, cmd, playerIdOrName)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    local targetPlayer = player
    
    if playerIdOrName then
        for _, p in ipairs(getElementsByType("player")) do
            if getElementData(p, "playerID") == tonumber(playerIdOrName) then
                targetPlayer = p
                break
            end
        end
        
        if not targetPlayer then
            outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
            return
        end
    end
    
    local targetName = getPlayerName(targetPlayer)
    outputChatBox(string.format("🔫 ===== VU KHI CUA %s =====", targetName), player, 255, 255, 100)
    
    local hasWeapons = false
    for slot = 0, 12 do
        local weapon = getPedWeapon(targetPlayer, slot)
        if weapon and weapon > 0 then
            local ammo = getPedTotalAmmo(targetPlayer, slot)
            local weaponName = getWeaponNameFromID(weapon) or "Unknown"
            outputChatBox(string.format("Slot %d: %s (ID:%d) - %d dan", slot, weaponName, weapon, ammo), player, 255, 255, 255)
            hasWeapons = true
        end
    end
    
    if not hasWeapons then
        outputChatBox("Khong co vu khi nao.", player, 255, 255, 255)
    end
    
    outputChatBox("========================", player, 255, 255, 100)
end)

-- Admin armor command
addCommandHandler("aarmor", function(player, cmd, playerIdOrName, amount)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    local targetPlayer = player
    local armorAmount = tonumber(amount) or 100
    
    if playerIdOrName and playerIdOrName ~= "me" then
        for _, p in ipairs(getElementsByType("player")) do
            if getElementData(p, "playerID") == tonumber(playerIdOrName) then
                targetPlayer = p
                break
            end
        end
        
        if not targetPlayer then
            outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
            return
        end
    end
    
    if armorAmount > 100 then armorAmount = 100 end
    if armorAmount < 0 then armorAmount = 0 end
    
    setPedArmor(targetPlayer, armorAmount)
    
    local targetName = getPlayerName(targetPlayer)
    
    if targetPlayer == player then
        outputChatBox(string.format("✅ Da set armor thanh %d%%.", armorAmount), player, 0, 255, 0)
    else
        outputChatBox(string.format("✅ Da set armor cua %s thanh %d%%.", targetName, armorAmount), player, 0, 255, 0)
        outputChatBox(string.format("🛡️ Armor cua ban da duoc Admin set thanh %d%%.", armorAmount), targetPlayer, 0, 255, 0)
    end
    
    outputDebugString("[ADMIN ARMOR] " .. getPlayerName(player) .. " set " .. targetName .. " armor to " .. armorAmount)
end)

outputDebugString("[AMB] Admin vehicle & weapon system loaded - 9 commands")
