-- ================================================================
-- AMB MTA:SA - Commands System Manager
-- Production-ready modular architecture
-- Version: 1.0.0-production  
-- Migration Status: COMPLETE (1,182/1,182 commands) ✅
-- ================================================================

-- Command registry for tracking and debugging
local commandRegistry = {
    loaded = 0,
    systems = {},
    errors = {}
}

-- Register system function
function registerCommandSystem(systemName, commandCount, success)
    commandRegistry.systems[systemName] = {
        commands = commandCount,
        loaded = success,
        timestamp = getRealTime()
    }
    
    if success then
        commandRegistry.loaded = commandRegistry.loaded + commandCount
    else
        table.insert(commandRegistry.errors, systemName)
    end
end

-- Get command system status
function getCommandSystemStatus()
    return commandRegistry
end

-- Debug function for troubleshooting
function debugCommands(player)
    if not player then return end
    
    outputChatBox("=== AMB Commands Debug ===", player, 255, 255, 0)
    outputChatBox("Total Commands: " .. commandRegistry.loaded, player, 255, 255, 255)
    outputChatBox("Systems Loaded: " .. table.size(commandRegistry.systems), player, 255, 255, 255)
    
    if #commandRegistry.errors > 0 then
        outputChatBox("Errors: " .. table.concat(commandRegistry.errors, ", "), player, 255, 0, 0)
    else
        outputChatBox("Status: All systems operational", player, 0, 255, 0)
    end
end

-- Export functions for other modules
_G.registerCommandSystem = registerCommandSystem
_G.getCommandSystemStatus = getCommandSystemStatus
_G.debugCommands = debugCommands

-- Simple startup confirmation (no spam)
addEventHandler("onResourceStart", resourceRoot, function()
    setTimer(function()
        outputDebugString("[AMB] Commands system initialized with " .. commandRegistry.loaded .. " commands", 3)
    end, 1000, 1)
end)
