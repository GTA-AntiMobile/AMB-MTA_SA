-- ================================
-- AMB MTA:SA - Medical & Emergency Commands
-- Mass migration of medical and emergency system commands
-- ================================
-- Respond to emergency
addCommandHandler("respond", function(player, cmd, emergencyID)
    local playerData = getElementData(player, "playerData") or {}
    local job = playerData.job

    if job ~= "Police" and job ~= "Medic" and job ~= "Firefighter" then
        outputChatBox("❌ Ban khong phai emergency responder.", player, 255, 100, 100)
        return
    end

    if not emergencyID then
        outputChatBox("Su dung: /respond [emergency_id]", player, 255, 255, 255)
        return
    end

    local emergencyData = getServerData("emergency_" .. emergencyID)
    if not emergencyData then
        outputChatBox("❌ Emergency call khong ton tai.", player, 255, 100, 100)
        return
    end

    -- Create checkpoint for responder
    local x, y, z = emergencyData.x, emergencyData.y, emergencyData.z
    local checkpoint = createMarker(x, y, z - 1, "checkpoint", 3, 255, 0, 0, 150)
    setElementData(checkpoint, "emergencyResponse", getPlayerName(player))
    setElementData(player, "respondingTo", emergencyID)

    outputChatBox(string.format("🚨 Responding to emergency #%d", emergencyID), player, 255, 255, 0)
    outputChatBox(string.format("🚨 Location: %.1f, %.1f, %.1f", x, y, z), player, 255, 255, 100)

    -- Notify caller
    local caller = getPlayerFromName(emergencyData.caller)
    if caller then
        outputChatBox(string.format("🚨 %s (%s) is responding to your emergency!", getPlayerName(player), job),
            caller, 0, 255, 0)
    end

    -- Notify other responders
    for _, responder in ipairs(getElementsByType("player")) do
        local responderData = getElementData(responder, "playerData") or {}
        local responderJob = responderData.job
        if (responderJob == "Police" or responderJob == "Medic" or responderJob == "Firefighter") and responder ~=
            player then
            outputChatBox(string.format("🚨 %s (%s) responding to emergency #%d", getPlayerName(player), job,
                emergencyID), responder, 255, 255, 100)
        end
    end
end)

-- Medical treatment system
addCommandHandler("heal", function(player, cmd, targetName)
    local playerData = getElementData(player, "playerData") or {}

    if playerData.job ~= "Medic" then
        outputChatBox("❌ Ban khong phai medic.", player, 255, 100, 100)
        return
    end

    local targetPlayer = player
    if targetName then
        targetPlayer = getPlayerFromNameOrId(targetName)
        if not targetPlayer then
            outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
            return
        end
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)

    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 5 then
        outputChatBox("❌ Ban can gan target hon.", player, 255, 100, 100)
        return
    end

    -- Heal target
    setElementHealth(targetPlayer, 100)

    if targetPlayer == player then
        outputChatBox("🏥 Da tu heal ban than.", player, 0, 255, 0)
    else
        outputChatBox(string.format("🏥 Da heal %s.", getPlayerName(targetPlayer)), player, 0, 255, 0)
        outputChatBox(string.format("🏥 Da duoc heal boi medic %s.", getPlayerName(player)), targetPlayer, 0, 255, 0)
    end

    -- Payment for healing
    local targetData = getElementData(targetPlayer, "playerData") or {}
    local cost = 100

    if (targetData.money or 0) >= cost then
        targetData.money = (targetData.money or 0) - cost
        playerData.money = (playerData.money or 0) + cost

        setElementData(targetPlayer, "playerData", targetData)
        setElementData(player, "playerData", playerData)

        outputChatBox(string.format("💰 Medical bill: $%d", cost), targetPlayer, 255, 255, 100)
        outputChatBox(string.format("💰 Nhan $%d cho viec heal", cost), player, 0, 255, 0)
    end
end)

-- Revive system
addCommandHandler("revive", function(player, cmd, targetName)
    local playerData = getElementData(player, "playerData") or {}

    if playerData.job ~= "Medic" then
        outputChatBox("❌ Ban khong phai medic.", player, 255, 100, 100)
        return
    end

    if not targetName then
        outputChatBox("Su dung: /revive [player]", player, 255, 255, 255)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(targetName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    -- Check if target is dead
    if getElementHealth(targetPlayer) > 0 then
        outputChatBox("❌ Nguoi nay khong bi thuong nang.", player, 255, 100, 100)
        return
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)

    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 3 then
        outputChatBox("❌ Ban can gan target hon.", player, 255, 100, 100)
        return
    end

    -- Revive target
    spawnPlayer(targetPlayer, tx, ty, tz + 1, 0, 0, 0, 0)
    setElementHealth(targetPlayer, 50) -- Revive with half health

    outputChatBox(string.format("🏥 Da revive %s.", getPlayerName(targetPlayer)), player, 0, 255, 0)
    outputChatBox(string.format("🏥 Ban da duoc revive boi medic %s.", getPlayerName(player)), targetPlayer, 0, 255, 0)

    -- Payment for reviving
    local targetData = getElementData(targetPlayer, "playerData") or {}
    local cost = 500

    if (targetData.money or 0) >= cost then
        targetData.money = (targetData.money or 0) - cost
        playerData.money = (playerData.money or 0) + cost

        setElementData(targetPlayer, "playerData", targetData)
        setElementData(player, "playerData", playerData)

        outputChatBox(string.format("💰 Revival cost: $%d", cost), targetPlayer, 255, 255, 100)
        outputChatBox(string.format("💰 Nhan $%d cho viec revive", cost), player, 0, 255, 0)
    end
end)

-- Medical examination
addCommandHandler("examine", function(player, cmd, targetName)
    local playerData = getElementData(player, "playerData") or {}

    if playerData.job ~= "Medic" then
        outputChatBox("❌ Ban khong phai medic.", player, 255, 100, 100)
        return
    end

    local targetPlayer = player
    if targetName then
        targetPlayer = getPlayerFromNameOrId(targetName)
        if not targetPlayer then
            outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
            return
        end
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)

    if targetPlayer ~= player and getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 5 then
        outputChatBox("❌ Ban can gan target hon.", player, 255, 100, 100)
        return
    end

    -- Medical examination
    local health = getElementHealth(targetPlayer)
    local armor = getPedArmor(targetPlayer)

    outputChatBox(string.format("🏥 ===== MEDICAL EXAM: %s =====", getPlayerName(targetPlayer)), player, 255, 255, 0)
    outputChatBox(string.format("• Health: %.1f%%", health), player, 255, 255, 255)
    outputChatBox(string.format("• Armor: %.1f%%", armor), player, 255, 255, 255)

    -- Determine medical condition
    if health >= 80 then
        outputChatBox("• Condition: Healthy", player, 0, 255, 0)
    elseif health >= 50 then
        outputChatBox("• Condition: Minor injuries", player, 255, 255, 0)
    elseif health >= 20 then
        outputChatBox("• Condition: Serious injuries", player, 255, 100, 0)
    else
        outputChatBox("• Condition: Critical condition", player, 255, 0, 0)
    end

    -- Check for drugs or special conditions
    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.drugged then
        outputChatBox("• Status: Under influence of drugs", player, 255, 0, 255)
    end

    if targetData.drunk then
        outputChatBox("• Status: Intoxicated", player, 255, 100, 100)
    end
end)

-- Ambulance duty
addCommandHandler("ambulance", function(player, cmd, action)
    local playerData = getElementData(player, "playerData") or {}

    if playerData.job ~= "Medic" then
        outputChatBox("❌ Ban khong phai medic.", player, 255, 100, 100)
        return
    end

    if not action then
        outputChatBox("🚑 ===== AMBULANCE SYSTEM =====", player, 255, 255, 0)
        outputChatBox("• /ambulance duty - On/Off duty", player, 255, 255, 255)
        outputChatBox("• /ambulance equipment - Lay medical kit", player, 255, 255, 255)
        outputChatBox("• /ambulance call [location] - Goi backup", player, 255, 255, 255)
        return
    end

    if action == "duty" then
        local onDuty = getElementData(player, "medicDuty")
        setElementData(player, "medicDuty", not onDuty)

        local status = onDuty and "OFF" or "ON"
        outputChatBox(string.format("🚑 Medic duty: %s", status), player, 255, 255, 0)

        if not onDuty then
            -- Give medical equipment
            giveWeapon(player, 41, 500) -- Spray can (medical spray)
            outputChatBox("🏥 Da nhan medical equipment.", player, 0, 255, 0)
        end

    elseif action == "equipment" then
        if not getElementData(player, "medicDuty") then
            outputChatBox("❌ Ban can on duty truoc.", player, 255, 100, 100)
            return
        end

        giveWeapon(player, 41, 500) -- Medical spray
        outputChatBox("🏥 Da lay medical kit.", player, 0, 255, 0)

    elseif action == "call" then
        local location = table.concat({cmd, ...}, " ", 3)
        if not location or location == "" then
            outputChatBox("Su dung: /ambulance call [location]", player, 255, 255, 255)
            return
        end

        -- Notify other medics
        for _, medic in ipairs(getElementsByType("player")) do
            local medicData = getElementData(medic, "playerData") or {}
            if medicData.job == "Medic" and medic ~= player then
                outputChatBox(string.format("🚑 BACKUP CALL: %s can backup tai %s", getPlayerName(player), location),
                    medic, 255, 0, 0)
            end
        end

        outputChatBox(string.format("🚑 Da goi backup tai %s", location), player, 0, 255, 0)
    end
end)

-- Drug treatment
addCommandHandler("detox", function(player, cmd, targetName)
    local playerData = getElementData(player, "playerData") or {}

    if playerData.job ~= "Medic" then
        outputChatBox("❌ Ban khong phai medic.", player, 255, 100, 100)
        return
    end

    local targetPlayer = player
    if targetName then
        targetPlayer = getPlayerFromNameOrId(targetName)
        if not targetPlayer then
            outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
            return
        end
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)

    if targetPlayer ~= player and getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 5 then
        outputChatBox("❌ Ban can gan target hon.", player, 255, 100, 100)
        return
    end

    local targetData = getElementData(targetPlayer, "playerData") or {}

    if not targetData.drugged and not targetData.drunk then
        outputChatBox("❌ Nguoi nay khong bi ngoi doc.", player, 255, 100, 100)
        return
    end

    -- Remove drug effects
    targetData.drugged = nil
    targetData.drunk = nil
    setElementData(targetPlayer, "playerData", targetData)

    outputChatBox(string.format("🏥 Da detox %s.", getPlayerName(targetPlayer)), player, 0, 255, 0)
    outputChatBox("🏥 Ban da duoc detox. Cam giac tot hon nhieu!", targetPlayer, 0, 255, 0)

    -- Payment
    local cost = 200
    if (targetData.money or 0) >= cost then
        targetData.money = (targetData.money or 0) - cost
        playerData.money = (playerData.money or 0) + cost

        setElementData(targetPlayer, "playerData", targetData)
        setElementData(player, "playerData", playerData)

        outputChatBox(string.format("💰 Detox cost: $%d", cost), targetPlayer, 255, 255, 100)
    end
end)

-- First aid training
addCommandHandler("firstaid", function(player, cmd, targetName)
    local playerData = getElementData(player, "playerData") or {}

    if not targetName then
        -- Self first aid
        local health = getElementHealth(player)
        if health >= 80 then
            outputChatBox("❌ Ban khong can first aid.", player, 255, 100, 100)
            return
        end

        local newHealth = math.min(100, health + 20)
        setElementHealth(player, newHealth)
        outputChatBox("🏥 Da tu first aid. Health tang 20.", player, 0, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(targetName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)

    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 3 then
        outputChatBox("❌ Ban can gan target hon.", player, 255, 100, 100)
        return
    end

    local health = getElementHealth(targetPlayer)
    if health >= 80 then
        outputChatBox("❌ Nguoi nay khong can first aid.", player, 255, 100, 100)
        return
    end

    local newHealth = math.min(100, health + 15)
    setElementHealth(targetPlayer, newHealth)

    outputChatBox(string.format("🏥 Da first aid cho %s.", getPlayerName(targetPlayer)), player, 0, 255, 0)
    outputChatBox(string.format("🏥 Da duoc first aid boi %s. Health tang 15.", getPlayerName(player)), targetPlayer,
        0, 255, 0)
end)

-- Hospital system
addCommandHandler("hospital", function(player, cmd, action)
    -- Check if at hospital
    local px, py, pz = getElementPosition(player)
    local hospitals = {{1607.0, -1615.0, 13.5}, -- LS Hospital
    {-2655.0, 639.5, 14.5}, -- SF Hospital
    {1608.0, 1815.0, 10.8} -- LV Hospital
    }

    local atHospital = false
    for _, hospital in ipairs(hospitals) do
        if getDistanceBetweenPoints3D(px, py, pz, hospital[1], hospital[2], hospital[3]) < 10 then
            atHospital = true
            break
        end
    end

    if not atHospital then
        outputChatBox("❌ Ban can o trong hospital.", player, 255, 100, 100)
        return
    end

    if not action then
        outputChatBox("🏥 ===== HOSPITAL SERVICES =====", player, 255, 255, 0)
        outputChatBox("• /hospital heal - Heal ($100)", player, 255, 255, 255)
        outputChatBox("• /hospital checkup - Health checkup ($50)", player, 255, 255, 255)
        outputChatBox("• /hospital insurance - Mua bao hiem ($500)", player, 255, 255, 255)
        return
    end

    local playerData = getElementData(player, "playerData") or {}

    if action == "heal" then
        local cost = 100
        if (playerData.money or 0) < cost then
            outputChatBox("❌ Ban can $100 de heal.", player, 255, 100, 100)
            return
        end

        playerData.money = (playerData.money or 0) - cost
        setElementData(player, "playerData", playerData)
        setElementHealth(player, 100)

        outputChatBox("🏥 Da heal thanh cong! Health: 100%", player, 0, 255, 0)

    elseif action == "checkup" then
        local cost = 50
        if (playerData.money or 0) < cost then
            outputChatBox("❌ Ban can $50 de checkup.", player, 255, 100, 100)
            return
        end

        playerData.money = (playerData.money or 0) - cost
        setElementData(player, "playerData", playerData)

        local health = getElementHealth(player)
        outputChatBox("🏥 ===== HEALTH CHECKUP =====", player, 255, 255, 0)
        outputChatBox(string.format("• Health: %.1f%%", health), player, 255, 255, 255)
        outputChatBox("• Overall condition: " .. (health >= 80 and "Good" or health >= 50 and "Fair" or "Poor"),
            player, 255, 255, 255)

    elseif action == "insurance" then
        local cost = 500
        if (playerData.money or 0) < cost then
            outputChatBox("❌ Ban can $500 de mua insurance.", player, 255, 100, 100)
            return
        end

        if playerData.healthInsurance then
            outputChatBox("❌ Ban da co health insurance roi.", player, 255, 100, 100)
            return
        end

        playerData.money = (playerData.money or 0) - cost
        playerData.healthInsurance = true
        setElementData(player, "playerData", playerData)

        outputChatBox("🏥 Da mua health insurance! Chi phi y te giam 50%.", player, 0, 255, 0)
    end
end)

-- Helper functions
function getServerData(key)
    return getElementData(getResourceRootElement(), key)
end

function setServerData(key, value)
    setElementData(getResourceRootElement(), key, value)
end

outputDebugString("[AMB] Medical & Emergency system loaded - 10 commands")
