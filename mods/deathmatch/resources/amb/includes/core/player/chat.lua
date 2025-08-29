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
    
    -- Allow certain commands for non-logged users
    if allowedCommands[cmd] then
        return
    end
    
    if not isPlayerLoggedIn(source) then
        outputChatBox("❌ You must be logged in to use commands! Use /login [password]", source, 255, 100, 100)
        cancelEvent()
        return
    end
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

-- 🚀 Enhanced Login Success Message (using consistent event)
addEvent("amb:onPlayerLogin", true)
addEventHandler("amb:onPlayerLogin", getRootElement(), function()
    local player = source
    setTimer(function()
        outputChatBox("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", player, 0, 255, 0)
        outputChatBox("✅ Welcome back to AMB Roleplay!", player, 255, 255, 255)
        outputChatBox("💬 You can now chat and use all commands", player, 255, 255, 100)
        outputChatBox("🛡️ Type /acmds for admin commands (if admin)", player, 255, 255, 100)
        outputChatBox("🚗 Type /veh for vehicle commands (if admin)", player, 255, 255, 100)
        outputChatBox("❓ Type /help for general commands", player, 255, 255, 100)
        outputChatBox("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", player, 0, 255, 0)
    end, 1000, 1)
end)

outputServerLog("[CHAT] Chat Security System loaded successfully!")
