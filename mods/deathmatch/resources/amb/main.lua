-- ================================================================
-- AMB MTA:SA - Main Server Entry Point
-- Clean Production Structure - Single Entry Point
-- Version: 1.1.2-production
-- Date: August 29, 2025
-- Migration: COMPLETE (1,182/1,182 commands) ✅
-- New Features: Enhanced Client Systems (Scoreboard, GPS, Voice, Fuel) ✨
-- ================================================================
-- Global server configuration
-- Load player cleanup logic
require("includes/core/player/cleanup.lua")
SERVER_CONFIG = {
    name = "AMB MTA:SA Production",
    version = "1.0.0-production",
    commands_migrated = 1182,
    systems_loaded = 17,
    debug_mode = true -- Set to true for debugging
}

-- Resource start event handler (MAIN ENTRY POINT)
addEventHandler("onResourceStart", resourceRoot, function()
    -- Single startup message to prevent spam
    outputServerLog("AMB MTA:SA v" .. SERVER_CONFIG.version .. " started - " .. SERVER_CONFIG.commands_migrated ..
                        " commands ready")

    if SERVER_CONFIG.debug_mode then
        outputDebugString("[AMB] Debug mode enabled", 3)
    end

    -- Initialize server state
    setGameType("AMB Roleplay")
    setMapName("San Andreas")

    -- Call post-startup initialization after delay
    setTimer(function()
        triggerEvent("onAMBServerReady", resourceRoot)
    end, 2000, 1)
end)

-- Resource stop event handler
addEventHandler("onResourceStop", resourceRoot, function()
    outputServerLog("AMB MTA:SA v1.1.2-production stopped")
    -- Auto logout all players and trigger client force logout
    for _, player in ipairs(getElementsByType("player")) do
        setElementData(player, "loggedIn", false)
        triggerClientEvent(player, "onForceLogout", player)
        -- Nếu có biến khác như "username", "adminLevel" cũng nên xóa hoặc reset
        -- setElementData(player, "username", nil)
        -- setElementData(player, "adminLevel", nil)
    end
end)

-- Server ready event for other modules to hook into
addEvent("onAMBServerReady", false)

-- Client log handler - receive logs from client and write to dedicated client.log file
addEvent("onClientLogMessage", true)
addEventHandler("onClientLogMessage", root, function(logMessage)
    local playerName = getPlayerName(client) or "Unknown"

    -- Write to both server log and dedicated client log file
    outputServerLog("[CLIENT:" .. playerName .. "] " .. logMessage)

    -- Also write to dedicated client.log file in resource folder
    local file = fileOpen("logs/client.log", false)
    if not file then
        file = fileCreate("logs/client.log")
    end

    if file then
        fileSetPos(file, fileGetSize(file)) -- Move to end of file
        fileWrite(file, "[CLIENT:" .. playerName .. "] " .. logMessage .. "\n")
        fileClose(file)
    end
end)

-- Display server information
outputDebugString("=== AMB ROLEPLAY SERVER v1.1.2-production ===")
outputDebugString("🎮 Complete SA-MP to MTA migration (1,182 commands)")
outputDebugString("✨ Enhanced with modern client-side features:")
outputDebugString("   📊 Enhanced Scoreboard (TAB)")
outputDebugString("   🚗 Professional Speedometer & Fuel System")
outputDebugString("   🎤 Voice Chat System (Local/Global)")
outputDebugString("   🗺️ GPS Navigation (50+ locations)")
outputDebugString("🏁 Production-ready for Vietnamese Roleplay")
outputDebugString("==============================================")
outputDebugString("AMB MTA:SA v1.1.2-production started - 1182 commands ready")
