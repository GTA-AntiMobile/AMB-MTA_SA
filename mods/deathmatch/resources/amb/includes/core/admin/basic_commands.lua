-- ====================================
-- 🛡️ AMB ADMIN COMMANDS SYSTEM
-- ====================================
-- Purpose: Essential admin commands migrated from SA-MP
-- Version: 1.0.0
-- Author: AMB Team

-- 🔧 Admin Level Check Function
function isAdmin(player, level)
    local account = getPlayerAccount(player)
    if not account then return false end
    
    local adminLevel = getAccountData(account, "AdminLevel") or 0
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
addCommandHandler("givemoney", function(player, cmd, target, amount)
    if not isAdmin(player, 3) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(target)
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

addCommandHandler("setmoney", function(player, cmd, target, amount)
    if not isAdmin(player, 3) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(target)
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
    outputChatBox("💰 Your money was set to $" .. money .. " by admin " .. getPlayerName(player), targetPlayer, 0, 255, 100)
    
    sendAdminMessage(getPlayerName(player) .. " set " .. getPlayerName(targetPlayer) .. "'s money to $" .. money)
end)

-- 🩺 Health & Armor Commands
addCommandHandler("sethp", function(player, cmd, target, health)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(target)
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

addCommandHandler("setarmor", function(player, cmd, target, armor)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(target)
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

-- 🚀 Jetpack Command
addCommandHandler("jetpack", function(player, cmd, target)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = target and getPlayerFromName(target) or player
    
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

-- 📍 Teleport Commands
addCommandHandler("goto", function(player, cmd, target)
    if not isAdmin(player, 1) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(target)
    
    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(targetPlayer)
    local interior = getElementInterior(targetPlayer)
    local dimension = getElementDimension(targetPlayer)
    
    setElementPosition(player, x + 2, y, z)
    setElementInterior(player, interior)
    setElementDimension(player, dimension)
    
    outputChatBox("✅ Teleported to " .. getPlayerName(targetPlayer), player, 0, 255, 0)
    outputChatBox("📍 Admin " .. getPlayerName(player) .. " teleported to you", targetPlayer, 255, 255, 0)
    
    sendAdminMessage(getPlayerName(player) .. " teleported to " .. getPlayerName(targetPlayer))
end)

addCommandHandler("gethere", function(player, cmd, target)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(target)
    
    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)
    
    setElementPosition(targetPlayer, x + 2, y, z)
    setElementInterior(targetPlayer, interior)
    setElementDimension(targetPlayer, dimension)
    
    outputChatBox("✅ Brought " .. getPlayerName(targetPlayer) .. " to you", player, 0, 255, 0)
    outputChatBox("📍 You were teleported to admin " .. getPlayerName(player), targetPlayer, 255, 255, 0)
    
    sendAdminMessage(getPlayerName(player) .. " brought " .. getPlayerName(targetPlayer) .. " to them")
end)

-- ❄️ Freeze/Unfreeze Commands
addCommandHandler("freeze", function(player, cmd, target)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(target)
    
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

addCommandHandler("unfreeze", function(player, cmd, target)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(target)
    
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

addCommandHandler("spec", function(player, cmd, target)
    if not isAdmin(player, 1) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(target)
    
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
        x = x, y = y, z = z,
        interior = interior,
        dimension = dimension
    }
    
    setCameraTarget(player, targetPlayer)
    setElementAlpha(player, 0) -- Make invisible
    setElementFrozen(player, true)
    
    outputChatBox("👁️ Now spectating " .. getPlayerName(targetPlayer) .. " | Use /specoff to stop", player, 255, 255, 0)
    
    sendAdminMessage(getPlayerName(player) .. " is spectating " .. getPlayerName(targetPlayer))
end)

addCommandHandler("specoff", function(player, cmd)
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
addCommandHandler("weather", function(player, cmd, weatherId)
    if not isAdmin(player, 3) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
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

addCommandHandler("time", function(player, cmd, hour, minute)
    if not isAdmin(player, 3) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local h = tonumber(hour)
    local m = tonumber(minute) or 0
    
    if not h or h < 0 or h > 23 then
        outputChatBox("❌ Hour must be between 0-23!", player, 255, 0, 0)
        return
    end
    
    if m < 0 or m > 59 then
        outputChatBox("❌ Minute must be between 0-59!", player, 255, 0, 0)
        return
    end
    
    setTime(h, m)
    outputChatBox("✅ Time changed to " .. string.format("%02d:%02d", h, m), player, 0, 255, 0)
    outputServerLog("[ADMIN] " .. getPlayerName(player) .. " changed time to " .. h .. ":" .. m)
    
    for _, p in ipairs(getElementsByType("player")) do
        outputChatBox("🕐 Time changed by admin " .. getPlayerName(player), p, 255, 255, 100)
    end
end)

-- ⚠️ Kick & Ban Commands
addCommandHandler("kick", function(player, cmd, target, ...)
    if not isAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(target)
    local reason = table.concat({...}, " ") or "No reason specified"
    
    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end
    
    local targetName = getPlayerName(targetPlayer)
    
    outputChatBox("⚠️ " .. targetName .. " was kicked by " .. getPlayerName(player) .. " | Reason: " .. reason, root, 255, 100, 100)
    outputServerLog("[KICK] " .. getPlayerName(player) .. " kicked " .. targetName .. " | Reason: " .. reason)
    
    kickPlayer(targetPlayer, reason)
end)

addCommandHandler("ban", function(player, cmd, target, ...)
    if not isAdmin(player, 4) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    local targetPlayer = getPlayerFromName(target)
    local reason = table.concat({...}, " ") or "No reason specified"
    
    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end
    
    local targetName = getPlayerName(targetPlayer)
    local targetSerial = getPlayerSerial(targetPlayer)
    
    outputChatBox("🔨 " .. targetName .. " was banned by " .. getPlayerName(player) .. " | Reason: " .. reason, root, 255, 0, 0)
    outputServerLog("[BAN] " .. getPlayerName(player) .. " banned " .. targetName .. " (Serial: " .. targetSerial .. ") | Reason: " .. reason)
    
    banPlayer(targetPlayer, false, false, true, getRootElement(), reason)
end)

-- 📋 Admin Help Command
addCommandHandler("acmds", function(player, cmd)
    if not isAdmin(player, 1) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("━━━━━━━━━━ 🛡️ ADMIN COMMANDS ━━━━━━━━━━", player, 100, 255, 100)
    outputChatBox("Level 1: /goto, /spec, /specoff", player, 255, 255, 255)
    outputChatBox("Level 2: /sethp, /setarmor, /jetpack, /gethere, /freeze, /unfreeze, /kick", player, 255, 255, 255)
    outputChatBox("Level 3: /givemoney, /setmoney, /weather, /time", player, 255, 255, 255)
    outputChatBox("Level 4: /ban", player, 255, 255, 255)
    outputChatBox("Vehicle: /veh, /deleteveh, /listveh, /deleteallveh", player, 255, 255, 255)
    outputChatBox("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", player, 100, 255, 100)
end)

outputServerLog("[ADMIN] Admin Commands System loaded successfully!")
