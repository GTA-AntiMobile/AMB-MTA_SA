-- ================================================================
-- AMB MTA:SA - Test Commands for Fixes
-- ================================================================

-- Test command để kiểm tra các fixes
addCommandHandler("test", function(player, command, ...)
    local args = {...}
    local message = table.concat(args, " ")
    
    if message == "" then
        outputChatBox("✅ Test command working! Usage: /test [message]", player, 0, 255, 0)
    else
        outputChatBox("✅ Test message: " .. message, player, 0, 255, 0)
    end
    
    outputDebugString("[TEST] Player " .. getPlayerName(player) .. " used test command: " .. (message or "no message"))
end)

outputDebugString("[AMB] Test command /test loaded successfully")
