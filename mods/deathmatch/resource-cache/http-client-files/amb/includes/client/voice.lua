-- ================================
-- AMB Voice Chat System
-- Local and global voice chat
-- ================================

local voiceEnabled = true
local globalVoiceEnabled = false
local voiceRange = 30 -- meters for local voice

-- Voice chat events
addEvent("onVoiceChatToggle", true)
addEvent("onGlobalVoiceToggle", true)

-- Toggle voice chat
function toggleVoiceChat()
    voiceEnabled = not voiceEnabled
    
    if voiceEnabled then
        outputChatBox("🎤 Voice chat enabled", 0, 255, 127)
    else
        outputChatBox("🔇 Voice chat disabled", 255, 100, 100)
    end
    
    triggerServerEvent("onVoiceChatToggle", localPlayer, voiceEnabled)
end

-- Toggle global voice (admin only)
function toggleGlobalVoice()
    local adminLevel = getElementData(localPlayer, "adminLevel") or 0
    
    if adminLevel < 1 then
        outputChatBox("❌ You need admin privileges for global voice", 255, 100, 100)
        return
    end
    
    globalVoiceEnabled = not globalVoiceEnabled
    
    if globalVoiceEnabled then
        outputChatBox("📢 Global voice chat enabled", 255, 255, 0)
    else
        outputChatBox("📢 Global voice chat disabled", 255, 255, 0)
    end
    
    triggerServerEvent("onGlobalVoiceToggle", localPlayer, globalVoiceEnabled)
end

-- Set voice range
function setVoiceRange(range)
    if not range or tonumber(range) == nil then
        outputChatBox("❌ Usage: /voicerange [distance]", 255, 100, 100)
        return
    end
    
    range = tonumber(range)
    if range < 5 or range > 100 then
        outputChatBox("❌ Voice range must be between 5-100 meters", 255, 100, 100)
        return
    end
    
    voiceRange = range
    outputChatBox("🎤 Voice chat range set to " .. range .. " meters", 0, 255, 127)
end

-- Voice indicators
function drawVoiceIndicators()
    if not voiceEnabled then return end
    
    local screenW, screenH = guiGetScreenSize()
    
    -- Show voice status
    local statusText = "🎤 Voice: " .. (voiceEnabled and "ON" or "OFF")
    if globalVoiceEnabled then
        statusText = statusText .. " | 📢 GLOBAL"
    else
        statusText = statusText .. " | 📍 LOCAL (" .. voiceRange .. "m)"
    end
    
    dxDrawText(statusText, 10, screenH - 100, 0, 0, tocolor(255, 255, 255, 200), 0.8, "default-bold")
    
    -- Show speaking players with voice indicators
    for _, player in ipairs(getElementsByType("player")) do
        if player ~= localPlayer and getElementData(player, "isSpeaking") then
            local x, y, z = getElementPosition(player)
            local px, py, pz = getElementPosition(localPlayer)
            local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
            
            if globalVoiceEnabled or distance <= voiceRange then
                local sx, sy = getScreenFromWorldPosition(x, y, z + 1)
                if sx and sy then
                    -- Voice indicator above player
                    dxDrawText("🎤", sx - 10, sy - 30, sx + 10, sy - 10, tocolor(255, 255, 0, 255), 2.0)
                    
                    -- Player name
                    local name = getPlayerName(player)
                    dxDrawText(name, sx - 50, sy - 50, sx + 50, sy - 30, tocolor(255, 255, 255, 255), 0.8, "default-bold", "center")
                end
            end
        end
    end
end

-- Commands
addCommandHandler("voice", toggleVoiceChat)
addCommandHandler("voicetoggle", toggleVoiceChat)
addCommandHandler("globalvoice", toggleGlobalVoice)
addCommandHandler("voicerange", setVoiceRange)

-- Keybinds
bindKey("v", "down", toggleVoiceChat)

-- Auto-start voice indicators
addEventHandler("onClientRender", root, drawVoiceIndicators)

outputChatBox("🎤 Voice chat loaded! Use /voice or 'V' key to toggle", 0, 255, 127)
outputChatBox("📢 Admins can use /globalvoice for server-wide chat", 255, 255, 0)
