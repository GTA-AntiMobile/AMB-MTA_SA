-- ================================
-- AMB MTA:SA - Player Utility Commands
-- Migrated from SA-MP open.mp server
-- ================================

-- ID command - Find player by name or ID
addCommandHandler("id", function(player, cmd, params)
    if not params or params == "" then
        outputChatBox("SU DUNG: /id [player name]", player, 128, 128, 128)
        return
    end
    
    local isPlayerAdmin = hasPermission(player, "admin.level2")
    
    -- Check if searching by ID number
    local playerIdOrName = tonumber(params)
    if playerIdOrName then
        local targetPlayer = getPlayerFromID(playerIdOrName)
        if targetPlayer then
            local targetName = getPlayerName(targetPlayer)
            local level = getElementData(targetPlayer, "player.level") or 1
            local ping = getPlayerPing(targetPlayer)
            
            local message
            if isPlayerAdmin then
                local fps = getElementData(targetPlayer, "player.fps") or 0
                message = string.format("%s (ID: %d) - (Cap do: %d) - (Ping: %d) - (FPS: %d)", 
                    targetName, playerIdOrName, level, ping, fps)
            else
                message = string.format("%s (ID: %d) - (Cap do: %d) - (Ping: %d)", 
                    targetName, playerIdOrName, level, ping)
            end
            
            outputChatBox(message, player, 255, 255, 255)
            return
        end
    end
    
    -- Search by name (minimum 3 characters)
    if string.len(params) < 3 then
        outputChatBox("Ten nguoi tim kiem it nhat phai 3 ki tu.", player, 128, 128, 128)
        return
    end
    
    local searchResults = {}
    local searchLower = string.lower(params)
    
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        local targetName = getPlayerName(targetPlayer)
        local targetNameLower = string.lower(targetName)
        
        if string.find(targetNameLower, searchLower, 1, true) then
            local playerID = getElementData(targetPlayer, "player.id")
            local level = getElementData(targetPlayer, "player.level") or 1
            local ping = getPlayerPing(targetPlayer)
            
            local message
            if isPlayerAdmin then
                local fps = getElementData(targetPlayer, "player.fps") or 0
                message = string.format("%s (ID: %d) - (Cap do: %d) - (Ping: %d) - (FPS: %d)", 
                    targetName, playerID, level, ping, fps)
            else
                message = string.format("%s (ID: %d) - (Cap do: %d) - (Ping: %d)", 
                    targetName, playerID, level, ping)
            end
            
            table.insert(searchResults, message)
        end
    end
    
    if #searchResults == 0 then
        outputChatBox("Khong tim thay nguoi choi nao.", player, 128, 128, 128)
    else
        for _, result in ipairs(searchResults) do
            outputChatBox(result, player, 255, 255, 255)
        end
    end
end)

-- Near command - Show nearby players (admin only)
addCommandHandler("near", function(player, cmd, radiusStr)
    if not hasPermission(player, "admin.level2") then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not radiusStr then
        outputChatBox("SU DUNG: /near [radius]", player, 128, 128, 128)
        return
    end
    
    local radius = tonumber(radiusStr)
    if not radius or radius < 1 or radius > 100 then
        outputChatBox("Ban kinh phai lon hon 0 va nho hon 100!", player, 128, 128, 128)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local nearbyPlayers = {}
    
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        if targetPlayer ~= player then
            local tx, ty, tz = getElementPosition(targetPlayer)
            local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
            
            if distance <= radius then
                local playerID = getElementData(targetPlayer, "player.id")
                local level = getElementData(targetPlayer, "player.level") or 1
                local targetName = getPlayerName(targetPlayer)
                
                table.insert(nearbyPlayers, {
                    name = targetName,
                    id = playerID,
                    level = level,
                    distance = math.floor(distance)
                })
            end
        end
    end
    
    outputChatBox("Nguoi choi trong ban kinh " .. radius .. " met:", player, 170, 170, 255)
    
    if #nearbyPlayers == 0 then
        outputChatBox("Khong co nguoi choi nao gan ban.", player, 255, 255, 255)
    else
        -- Sort by distance
        table.sort(nearbyPlayers, function(a, b) return a.distance < b.distance end)
        
        for _, nearbyPlayer in ipairs(nearbyPlayers) do
            local message = string.format("%s (ID: %d - Level: %d) - Distance: %dm", 
                nearbyPlayer.name, nearbyPlayer.id, nearbyPlayer.level, nearbyPlayer.distance)
            outputChatBox(message, player, 255, 255, 255)
        end
        
        outputChatBox("Total: " .. #nearbyPlayers .. " players found", player, 170, 170, 255)
    end
end)

-- Helper function to get player by ID
function getPlayerFromID(playerID)
    for _, player in ipairs(getElementsByType("player")) do
        if getElementData(player, "player.id") == playerID then
            return player
        end
    end
    return false
end

-- Bonus: Players command - Show all online players
addCommandHandler("players", function(player)
    local players = getElementsByType("player")
    local playerCount = #players
    
    outputChatBox("Danh sach nguoi choi online (" .. playerCount .. " players):", player, 0, 255, 255)
    
    local playerList = {}
    for _, targetPlayer in ipairs(players) do
        local playerID = getElementData(targetPlayer, "player.id")
        local level = getElementData(targetPlayer, "player.level") or 1
        local targetName = getPlayerName(targetPlayer)
        
        table.insert(playerList, {
            name = targetName,
            id = playerID,
            level = level
        })
    end
    
    -- Sort by ID
    table.sort(playerList, function(a, b) return a.id < b.id end)
    
    for _, playerInfo in ipairs(playerList) do
        local message = string.format("%s (ID: %d - Level: %d)", 
            playerInfo.name, playerInfo.id, playerInfo.level)
        outputChatBox(message, player, 255, 255, 255)
    end
end)

outputDebugString("[AMB] Player utility commands loaded")
