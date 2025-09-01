-- ====================================
-- 🔒 AMB CHAT SECURITY SYSTEM
-- ====================================
-- Purpose: Block chat for non-authenticated users
-- Version: 1.0.0
-- Author: AMB Team

-- 🛡️ Check if player is logged in
function isPlayerLoggedIn(player)
    local account = getPlayerAccount(player)
    if not account or isGuestAccount(account) then
        return false
    end
    
    -- Check if player has completed login process
    local playerName = getAccountData(account, "PlayerName")
    return playerName ~= nil
end

-- 📢 Block Regular Chat
addEventHandler("onPlayerChat", getRootElement(), function(message, messageType)
    if not isPlayerLoggedIn(source) then
        outputChatBox("❌ You must be logged in to chat! Use /login [password]", source, 255, 100, 100)
        cancelEvent()
        return
    end
end)

-- 💬 Block Private Messages
addEventHandler("onPlayerPrivateMessage", getRootElement(), function(message, recipient)
    if not isPlayerLoggedIn(source) then
        outputChatBox("❌ You must be logged in to send private messages!", source, 255, 100, 100)
        cancelEvent()
        return
    end
    
    if not isPlayerLoggedIn(recipient) then
        outputChatBox("❌ The recipient is not logged in!", source, 255, 100, 100)
        cancelEvent()
        return
    end
end)

-- 👥 Block Team Chat (if exists)
addEventHandler("onPlayerTeamChat", getRootElement(), function(message)
    if not isPlayerLoggedIn(source) then
        outputChatBox("❌ You must be logged in to use team chat!", source, 255, 100, 100)
        cancelEvent()
        return
    end
end)

-- 📝 Block Command Usage (except login commands)
local allowedCommands = {
    ["login"] = true,
    ["register"] = true,
    ["help"] = true,
    ["commands"] = true,
    ["rules"] = true,
    ["info"] = true
}

addEventHandler("onPlayerCommand", getRootElement(), function(command)
    local cmd = string.lower(command)
    
    outputDebugString("[CHAT] Command '" .. cmd .. "' by " .. getPlayerName(source))
    
    -- Allow certain commands for non-logged users
    if allowedCommands[cmd] then
        outputDebugString("[CHAT] Command '" .. cmd .. "' allowed for non-logged users")
        return
    end
    
    local isLoggedIn = isPlayerLoggedIn(source)
    outputDebugString("[CHAT] Player " .. getPlayerName(source) .. " login status: " .. tostring(isLoggedIn))
    
    if not isLoggedIn then
        outputChatBox("❌ You must be logged in to use commands! Use /login [password]", source, 255, 100, 100)
        outputDebugString("[CHAT] Blocking command '" .. cmd .. "' - player not logged in")
        cancelEvent()
        return
    end
    
    outputDebugString("[CHAT] Command '" .. cmd .. "' allowed - player logged in")
end)

-- 🔔 Welcome Message for New Players
addEventHandler("onPlayerJoin", getRootElement(), function()
    local player = source
    setTimer(function()
        outputChatBox("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", player, 100, 255, 100)
        outputChatBox("🎮 Welcome to AMB Roleplay Server!", player, 255, 255, 255)
        outputChatBox("📝 Please login to start playing: /login [password]", player, 255, 255, 100)
        outputChatBox("🆕 New player? Register with: /register [password]", player, 255, 255, 100)
        outputChatBox("❓ Need help? Use /help for assistance", player, 255, 255, 100)
        outputChatBox("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", player, 100, 255, 100)
    end, 2000, 1)
end)

outputServerLog("[CHAT] Chat Security System loaded successfully!")
