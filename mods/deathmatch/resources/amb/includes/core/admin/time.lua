-- ================================
-- AMB MTA:SA - Admin Time Management
-- Migrated from SA-MP open.mp server
-- ================================

-- Time of Day (TOD) Command
addCommandHandler("tod", function(player, cmd, timeStr)
    -- Check admin permission (level 1338 equivalent)
    if not hasPermission(player, "admin.level5") then
        outputChatBox("You are not authorized to use that command!", player, 255, 100, 100)
        return
    end
    
    if not timeStr then
        outputChatBox("USAGE: /tod [time] (0-23)", player, 255, 255, 255)
        return
    end
    
    local time = tonumber(timeStr)
    if not time or time < 0 or time > 23 then
        outputChatBox("USAGE: /tod [time] (0-23)", player, 255, 255, 255)
        return
    end
    
    -- Set world time for all players
    setTime(time, 0)
    
    -- Broadcast to all admins (level 2+)
    local message = "Time set to " .. time .. ":00."
    for _, adminPlayer in ipairs(getElementsByType("player")) do
        if hasPermission(adminPlayer, "admin.level2") then
            outputChatBox(message, adminPlayer, 170, 170, 255)
        end
    end
    
    outputDebugString("[ADMIN] " .. getPlayerName(player) .. " set server time to " .. time .. ":00")
end)
