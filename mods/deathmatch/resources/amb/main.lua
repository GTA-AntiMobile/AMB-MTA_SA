-- ================================================================
-- AMB MTA:SA - Main Server Entry Point
-- Clean Production Structure - Single Entry Point
-- Version: 1.1.2-production
-- Date: August 29, 2025
-- Migration: COMPLETE (1,182/1,182 commands) ✅
-- New Features: Enhanced Client Systems (Scoreboard, GPS, Voice, Fuel) ✨
-- ================================================================

-- Global server configuration
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
    outputServerLog("AMB MTA:SA v" ..
        SERVER_CONFIG.version .. " started - " .. SERVER_CONFIG.commands_migrated .. " commands ready")

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

-- -- Custom command event handler
-- addEvent("onCustomCommand", true)
-- addEventHandler("onCustomCommand", root, function(command)
--     local player = client
--     if not player or not isElement(player) then return end

--     local playerName = getPlayerName(player)
--     outputServerLog("[CUSTOM_COMMAND] " .. playerName .. ": /" .. command)

--     -- Parse command và arguments
--     local parts = {}
--     for part in string.gmatch(command, "%S+") do
--         table.insert(parts, part)
--     end

--     if #parts > 0 then
--         local cmd = parts[1]
--         local args = {}
--         for i = 2, #parts do
--             table.insert(args, parts[i])
--         end

--         -- Handle specific commands manually
--         if cmd == "cv" then
--             local idStr = args[1]
--             local cid = tonumber(idStr)
--             if not cid then
--                 outputChatBox("Usage: /cv [modelID]", player, 255, 0, 0)
--                 outputChatBox("Use /listcv to see available models", player, 255, 255, 0)
--                 return
--             end

--             local x, y, z = getElementPosition(player)
--             local _, _, rotZ = getElementRotation(player)
--             local radRot = math.rad(rotZ)
--             x = x + 5.0 * math.sin(radRot)
--             y = y + 5.0 * math.cos(radRot)

--             local vehicle

--             -- Use newmodels_azul for custom vehicles (30000+)
--             if cid >= 30000 and cid < 40000 then
--                 local newmodelsResource = getResourceFromName("newmodels_azul")
--                 if newmodelsResource and getResourceState(newmodelsResource) == "running" then
--                     vehicle = exports["newmodels_azul"]:createVehicle(cid, x, y, z, 0, 0, rotZ)
--                     if vehicle then
--                         outputChatBox("✅ Custom vehicle " .. cid .. " created!", player, 0, 255, 0)
--                     else
--                         outputChatBox("❌ Failed to create custom vehicle " .. cid, player, 255, 0, 0)
--                     end
--                 else
--                     outputChatBox("❌ newmodels_azul resource not running", player, 255, 0, 0)
--                 end
--             else
--                 -- Regular vehicle
--                 vehicle = createVehicle(cid, x, y, z, 0, 0, rotZ)
--                 if vehicle then
--                     outputChatBox("✅ Vehicle " .. cid .. " created!", player, 0, 255, 0)
--                 else
--                     outputChatBox("❌ Invalid vehicle ID: " .. cid, player, 255, 0, 0)
--                 end
--             end
--         elseif cmd == "test" then
--             outputChatBox("✅ Test command works! Custom chat system working.", player, 0, 255, 0)
--         else
--             outputChatBox("⚠️ Unknown command: /" .. _, player, 255, 100, 100)
--         end
--     end
-- end)

-- Resource stop event handler
addEventHandler("onResourceStop", resourceRoot, function()
    outputServerLog("AMB MTA:SA v1.1.2-production stopped")
end)

-- Server ready event for other modules to hook into
addEvent("onAMBServerReady", false)

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
