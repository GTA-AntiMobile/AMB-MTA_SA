-- ================================
-- AMB Voice Chat Server-side Support
-- Handles voice chat events and permissions
-- ================================

-- Voice chat events
addEvent("onVoiceChatToggle", true)
addEvent("onGlobalVoiceToggle", true)

-- Player voice settings
local playerVoiceSettings = {}

-- Handle voice chat toggle
addEventHandler("onVoiceChatToggle", root, function(enabled)
    local player = source
    if not player then return end
    
    local playerName = getPlayerName(player)
    playerVoiceSettings[playerName] = {
        enabled = enabled,
        global = playerVoiceSettings[playerName] and playerVoiceSettings[playerName].global or false
    }
    
    setElementData(player, "voiceEnabled", enabled)
    
    outputDebugString("[VOICE] " .. playerName .. " " .. (enabled and "enabled" or "disabled") .. " voice chat")
end)

-- Handle global voice toggle (admin only)
addEventHandler("onGlobalVoiceToggle", root, function(enabled)
    local player = source
    if not player then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    local playerName = getPlayerName(player)
    
    if adminLevel < 1 then
        outputChatBox("❌ You need admin privileges for global voice", player, 255, 100, 100)
        return
    end
    
    if not playerVoiceSettings[playerName] then
        playerVoiceSettings[playerName] = { enabled = true, global = false }
    end
    
    playerVoiceSettings[playerName].global = enabled
    setElementData(player, "globalVoice", enabled)
    
    -- Announce to all players
    local message = playerName .. (enabled and " enabled" or " disabled") .. " global voice chat"
    outputChatBox("📢 ADMIN: " .. message, root, 255, 255, 0)
    outputDebugString("[VOICE] " .. message)
end)

-- Clean up on player quit
addEventHandler("onPlayerQuit", root, function()
    local playerName = getPlayerName(source)
    playerVoiceSettings[playerName] = nil
end)

outputDebugString("[VOICE] Voice chat server support loaded")
