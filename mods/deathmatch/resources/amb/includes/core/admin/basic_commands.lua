-- ====================================
-- 🛡️ AMB ADMIN COMMANDS SYSTEM
-- ====================================
-- Purpose: Essential admin commands migrated from SA-MP
-- Version: 1.0.0
-- Author: AMB Team

-- 🔧 Admin Level Check Function
function isAdmin(player, level)
    if not isElement(player) then return false end

    -- Try to get adminLevel from ElementData first (matches main system)
    local adminLevel = getElementData(player, "adminLevel")

    -- Fallback to playerData if ElementData not set
    if not adminLevel then
        local playerData = getElementData(player, "playerData")
        adminLevel = playerData and playerData.adminLevel or 0
    else
        adminLevel = tonumber(adminLevel) or 0
    end

    -- GOD level có toàn quyền
    if adminLevel == ADMIN_LEVELS.GOD then
        return true
    end

    return adminLevel >= level
end

-- 📝 Send Admin Message
function sendAdminMessage(message)
    outputServerLog("[ADMIN] " .. message)
    for _, player in ipairs(getElementsByType("player")) do
        if isAdmin(player, 1) then
            outputChatBox("🛡️ [ADMIN] " .. message, player, 255, 100, 100)
        end
    end
end

-- 💰 Money & Stats Commands
addCommandHandler("givemoney", function(player, _, playerIdOrName, amount)
    if not isAdmin(player, 3) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not amount then
        outputChatBox("Usage: /givemoney [player] [amount]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local money = tonumber(amount)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if not money or money <= 0 then
        outputChatBox("❌ Invalid amount!", player, 255, 0, 0)
        return
    end

    givePlayerMoney(targetPlayer, money)
    outputChatBox("✅ Given $" .. money .. " to " .. getPlayerName(targetPlayer), player, 0, 255, 0)
    outputChatBox("💰 You received $" .. money .. " from admin " .. getPlayerName(player), targetPlayer, 0, 255, 100)

    sendAdminMessage(getPlayerName(player) .. " gave $" .. money .. " to " .. getPlayerName(targetPlayer))
end)

addCommandHandler("setmoney", function(player, _, playerIdOrName, amount)
    if not isAdmin(player, 3) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not amount then
        outputChatBox("Usage: /setmoney [player] [amount]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local money = tonumber(amount)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if not money or money < 0 then
        outputChatBox("❌ Invalid amount!", player, 255, 0, 0)
        return
    end

    setPlayerMoney(targetPlayer, money)
    outputChatBox("✅ Set " .. getPlayerName(targetPlayer) .. "'s money to $" .. money, player, 0, 255, 0)
    outputChatBox("💰 Your money was set to $" .. money .. " by admin " .. getPlayerName(player), targetPlayer, 0, 255,
        100)

    sendAdminMessage(getPlayerName(player) .. " set " .. getPlayerName(targetPlayer) .. "'s money to $" .. money)
end)

-- 🩺 Health & Armor Commands
addCommandHandler("sethp", function(player, _, playerIdOrName, health)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not health then
        outputChatBox("Usage: /sethp [player] [health]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local hp = tonumber(health)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if not hp or hp < 0 or hp > 100 then
        outputChatBox("❌ Health must be between 0-100!", player, 255, 0, 0)
        return
    end

    setElementHealth(targetPlayer, hp)
    outputChatBox("✅ Set " .. getPlayerName(targetPlayer) .. "'s health to " .. hp, player, 0, 255, 0)
    outputChatBox("🩺 Your health was set to " .. hp .. " by admin " .. getPlayerName(player), targetPlayer, 0, 255, 100)

    sendAdminMessage(getPlayerName(player) .. " set " .. getPlayerName(targetPlayer) .. "'s health to " .. hp)
end)

addCommandHandler("setarmor", function(player, _, playerIdOrName, armor)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not armor then
        outputChatBox("Usage: /setarmor [player] [armor]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local arm = tonumber(armor)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if not arm or arm < 0 or arm > 100 then
        outputChatBox("❌ Armor must be between 0-100!", player, 255, 0, 0)
        return
    end

    setPedArmor(targetPlayer, arm)
    outputChatBox("✅ Set " .. getPlayerName(targetPlayer) .. "'s armor to " .. arm, player, 0, 255, 0)
    outputChatBox("🛡️ Your armor was set to " .. arm .. " by admin " .. getPlayerName(player), targetPlayer, 0, 255, 100)

    sendAdminMessage(getPlayerName(player) .. " set " .. getPlayerName(targetPlayer) .. "'s armor to " .. arm)
end)

-- 🎭 Skin Commands
addCommandHandler("changeskin", function(player, _, playerIdOrName, skinId)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not skinId then
        outputChatBox("Usage: /changeskin [player] [skinId]", player, 255, 255, 0)
        outputChatBox("Standard skins: 0-312, Custom skins: 20001-20027", player, 255, 255, 100)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local skin = tonumber(skinId)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if not skin then
        outputChatBox("❌ Invalid skin ID!", player, 255, 0, 0)
        return
    end

    -- Check if it's a valid skin ID
    local isValid = false
    local skinType = "Unknown"

    if skin >= 0 and skin <= 312 then
        -- Standard GTA skin
        isValid = true
        skinType = "Standard"
        setElementModel(targetPlayer, skin)
        -- Clear custom skin data
        if getElementData(targetPlayer, "customSkinID") then
            removeElementData(targetPlayer, "customSkinID")
        end
    elseif skin >= 20001 and skin <= 29999 then
        -- Custom skin - check if available
        local newmodelsResource = getResourceFromName("newmodels_azul")
        if newmodelsResource and getResourceState(newmodelsResource) == "running" then
            local customModels = exports["newmodels_azul"]:getCustomModels()
            if customModels[skin] and customModels[skin].type == "ped" then
                local success = exports["newmodels_azul"]:setElementModel(targetPlayer, skin)
                if success then
                    isValid = true
                    skinType = "Custom (" .. (customModels[skin].name or "Unknown") .. ")"
                    setElementData(targetPlayer, "customSkinID", skin)
                else
                    outputChatBox("❌ Failed to apply custom skin " .. skin, player, 255, 0, 0)
                    return
                end
            else
                outputChatBox("❌ Custom skin " .. skin .. " not found!", player, 255, 0, 0)
                return
            end
        else
            outputChatBox("❌ Custom skins not available (newmodels_azul not running)", player, 255, 0, 0)
            return
        end
    end

    if isValid then
        -- Save to database immediately
        local username = getElementData(targetPlayer, "username")
        if username then
            local dbConn = getDatabaseConnection and getDatabaseConnection() or db_connection
            if dbConn then
                dbExec(dbConn, "UPDATE accounts SET Model = ? WHERE Username = ?", skin, username)
                outputDebugString("[CHANGESKIN] Saved skin " ..
                skin .. " to database for " .. getPlayerName(targetPlayer))
            else
                outputChatBox("⚠️ Database not available - skin won't persist after restart", player, 255, 255, 0)
            end
        end

        outputChatBox("✅ Set " .. getPlayerName(targetPlayer) .. "'s skin to " .. skin .. " (" .. skinType .. ")", player,
            0, 255, 0)
        if targetPlayer ~= player then
            outputChatBox("🎭 Your skin was changed to " .. skin .. " by admin " .. getPlayerName(player), targetPlayer, 0,
                255, 100)
        end
        sendAdminMessage(getPlayerName(player) ..
        " changed " .. getPlayerName(targetPlayer) .. "'s skin to " .. skin .. " (" .. skinType .. ")")
    else
        outputChatBox("❌ Invalid skin ID: " .. skin, player, 255, 0, 0)
    end
end)

-- 🚀 Jetpack Command
addCommandHandler("jetpack", function(player, _, playerIdOrName)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /jetpack [player]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if isPedWearingJetpack(targetPlayer) then
        setPedWearingJetpack(targetPlayer, false)
        outputChatBox("✅ Jetpack removed from " .. getPlayerName(targetPlayer), player, 255, 255, 0)
        if targetPlayer ~= player then
            outputChatBox("🚀 Your jetpack was removed by admin " .. getPlayerName(player), targetPlayer, 255, 255, 0)
        end
    else
        setPedWearingJetpack(targetPlayer, true)
        outputChatBox("✅ Jetpack given to " .. getPlayerName(targetPlayer), player, 0, 255, 0)
        if targetPlayer ~= player then
            outputChatBox("🚀 You received a jetpack from admin " .. getPlayerName(player), targetPlayer, 0, 255, 100)
        end
    end

    sendAdminMessage(getPlayerName(player) .. " toggled jetpack for " .. getPlayerName(targetPlayer))
end)

-- � Respawn/Revival Commands
addCommandHandler("hoisinh", function(player, _, playerIdOrName)
    if not isAdmin(player, 1) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /hoisinh [player]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if not isPedDead(targetPlayer) then
        outputChatBox("❌ " .. getPlayerName(targetPlayer) .. " is not dead!", player, 255, 255, 0)
        return
    end

    -- Save current skin/model before spawning
    local currentModel = 299 -- fallback
    local newmodelsResource = getResourceFromName("newmodels_azul")
    if newmodelsResource and getResourceState(newmodelsResource) == "running" then
        currentModel = exports["newmodels_azul"]:getElementModel(targetPlayer) or 299
    else
        currentModel = getElementModel(targetPlayer)
    end

    -- Get current position
    local x, y, z = getElementPosition(targetPlayer)
    local rot = select(3, getElementRotation(targetPlayer))
    local interior = getElementInterior(targetPlayer)
    local dimension = getElementDimension(targetPlayer)

    -- Spawn player with proper skin handling
    if newmodelsResource and getResourceState(newmodelsResource) == "running" then
        exports["newmodels_azul"]:spawnPlayer(targetPlayer, x, y, z, rot, currentModel, interior, dimension)
    else
        spawnPlayer(targetPlayer, x, y, z, rot, currentModel, interior, dimension)
    end

    setElementHealth(targetPlayer, 100)

    outputChatBox("✅ Revived " .. getPlayerName(targetPlayer), player, 0, 255, 0)
    if targetPlayer ~= player then
        outputChatBox("💚 You have been revived by admin " .. getPlayerName(player), targetPlayer, 0, 255, 100)
    end

    sendAdminMessage(getPlayerName(player) .. " revived " .. getPlayerName(targetPlayer))
end)

-- Alias for respawn command
addCommandHandler("respawn", function(player, _, playerIdOrName)
    executeCommandHandler("hoisinh", player, playerIdOrName)
end)

-- �📍 Teleport Commands
-- Note: /goto command moved to players.lua for better admin integration
-- ❄️ Freeze/Unfreeze Commands
addCommandHandler("freeze", function(player, _, playerIdOrName)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /freeze [player]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    setElementFrozen(targetPlayer, true)
    toggleAllControls(targetPlayer, false)

    outputChatBox("✅ Froze " .. getPlayerName(targetPlayer), player, 0, 255, 0)
    outputChatBox("❄️ You have been frozen by admin " .. getPlayerName(player), targetPlayer, 100, 200, 255)

    sendAdminMessage(getPlayerName(player) .. " froze " .. getPlayerName(targetPlayer))
end)

addCommandHandler("unfreeze", function(player, _, playerIdOrName)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /unfreeze [player]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    setElementFrozen(targetPlayer, false)
    toggleAllControls(targetPlayer, true)

    outputChatBox("✅ Unfroze " .. getPlayerName(targetPlayer), player, 0, 255, 0)
    outputChatBox("🔥 You have been unfrozen by admin " .. getPlayerName(player), targetPlayer, 255, 200, 100)

    sendAdminMessage(getPlayerName(player) .. " unfroze " .. getPlayerName(targetPlayer))
end)

-- 🏃 Spectate Commands
local spectateData = {}

addCommandHandler("spec", function(player, _, playerIdOrName)
    if not isAdmin(player, 1) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /spec [player]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if targetPlayer == player then
        outputChatBox("❌ You cannot spectate yourself!", player, 255, 0, 0)
        return
    end

    -- Save original position
    local x, y, z = getElementPosition(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)

    spectateData[player] = {
        x = x,
        y = y,
        z = z,
        interior = interior,
        dimension = dimension
    }

    setCameraTarget(player, targetPlayer)
    setElementAlpha(player, 0) -- Make invisible
    setElementFrozen(player, true)

    outputChatBox("👁️ Now spectating " .. getPlayerName(targetPlayer) .. " | Use /specoff to stop", player, 255, 255, 0)

    sendAdminMessage(getPlayerName(player) .. " is spectating " .. getPlayerName(targetPlayer))
end)

addCommandHandler("specoff", function(player, _)
    if not isAdmin(player, 1) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not spectateData[player] then
        outputChatBox("❌ You are not spectating anyone!", player, 255, 0, 0)
        return
    end

    local data = spectateData[player]

    setCameraTarget(player, player)
    setElementPosition(player, data.x, data.y, data.z)
    setElementInterior(player, data.interior)
    setElementDimension(player, data.dimension)
    setElementAlpha(player, 255)
    setElementFrozen(player, false)

    spectateData[player] = nil

    outputChatBox("✅ Stopped spectating", player, 0, 255, 0)

    sendAdminMessage(getPlayerName(player) .. " stopped spectating")
end)

-- 🌤️ Weather & Time Commands
addCommandHandler("thoitiet", function(player, _, weatherId)
    if not isAdmin(player, 3) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not weatherId then
        outputChatBox("Usage: /thoitiet [weatherId]", player, 255, 255, 0)
        return
    end

    local weather = tonumber(weatherId)

    if not weather or weather < 0 or weather > 45 then
        outputChatBox("❌ Weather ID must be between 0-45!", player, 255, 0, 0)
        return
    end

    setWeather(weather)
    outputChatBox("✅ Weather changed to ID: " .. weather, player, 0, 255, 0)
    outputServerLog("[ADMIN] " .. getPlayerName(player) .. " changed weather to " .. weather)

    for _, p in ipairs(getElementsByType("player")) do
        outputChatBox("🌤️ Weather changed by admin " .. getPlayerName(player), p, 255, 255, 100)
    end
end)

-- ⚠️ Kick & Ban Commands
addCommandHandler("kick", function(player, _, playerIdOrName, ...)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /kick [player] [reason]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local reason = table.concat({ ... }, " ") or "No reason specified"

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    local targetName = getPlayerName(targetPlayer)

    outputChatBox("⚠️ " .. targetName .. " was kicked by " .. getPlayerName(player) .. " | Reason: " .. reason, root, 255,
        100, 100)
    outputServerLog("[KICK] " .. getPlayerName(player) .. " kicked " .. targetName .. " | Reason: " .. reason)

    kickPlayer(targetPlayer, reason)
end)

addCommandHandler("ban", function(player, _, playerIdOrName, ...)
    if not isAdmin(player, 4) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /ban [player] [reason]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local reason = table.concat({ ... }, " ") or "No reason specified"

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    local targetName = getPlayerName(targetPlayer)
    local targetSerial = getPlayerSerial(targetPlayer)

    outputChatBox("🔨 " .. targetName .. " was banned by " .. getPlayerName(player) .. " | Reason: " .. reason, root, 255,
        0, 0)
    outputServerLog("[BAN] " ..
    getPlayerName(player) .. " banned " .. targetName .. " (Serial: " .. targetSerial .. ") | Reason: " .. reason)

    banPlayer(targetPlayer, false, false, true, getRootElement(), reason)
end)

-- 📋 Admin Help Command
addCommandHandler("acmds", function(player, _)
    if not isAdmin(player, 1) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    outputChatBox("━━━━━━━━━━ 🛡️ ADMIN COMMANDS ━━━━━━━━━━", player, 100, 255, 100)
    outputChatBox("Level 1: /goto, /spec, /specoff, /hoisinh, /respawn", player, 255, 255, 255)
    outputChatBox("Level 2: /sethp, /setarmor, /jetpack, /fly, /gethere, /freeze, /unfreeze, /kick, /changeskin", player,
        255, 255, 255)
    outputChatBox("Level 3: /givemoney, /setmoney, /weather, /time", player, 255, 255, 255)
    outputChatBox("Level 4: /ban", player, 255, 255, 255)
    outputChatBox("Vehicle: /veh, /deleteveh, /listveh, /deleteallveh", player, 255, 255, 255)
    outputChatBox("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", player, 100, 255, 100)
end)

outputServerLog("[ADMIN] Admin Commands System loaded successfully!")
