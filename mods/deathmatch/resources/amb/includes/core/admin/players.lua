-- ================================
-- AMB MTA:SA - Admin Players Management
-- Core admin commands for player management
-- ================================

-- Debug command to check database connection and skin
addCommandHandler("checkdb", function(player)
    outputChatBox("🔧 Checking database connection...", player, 255, 255, 0)
    
    -- Try different ways to get database connection
    local dbConn = db_connection or _G.db_connection or exports.amb:getDatabaseConnection()
    
    if not dbConn then
        outputChatBox("❌ No database connection found!", player, 255, 0, 0)
        outputChatBox("Trying alternative method...", player, 255, 255, 0)
        
        -- Try to get connection from global table
        if DATABASE_CONFIG then
            outputChatBox("✅ DATABASE_CONFIG found", player, 0, 255, 0)
            local cfg = DATABASE_CONFIG.mysql
            local connStr = string.format("dbname=%s;host=%s;port=%d", cfg.database, cfg.host, cfg.port)
            dbConn = dbConnect("mysql", connStr, cfg.user, cfg.password, "share=1")
            if dbConn then
                outputChatBox("✅ Created new database connection", player, 0, 255, 0)
            else
                outputChatBox("❌ Failed to create database connection", player, 255, 0, 0)
                return
            end
        else
            outputChatBox("❌ DATABASE_CONFIG not found", player, 255, 0, 0)
            return
        end
    else
        outputChatBox("✅ Database connection found", player, 0, 255, 0)
    end
    
    local account = getPlayerAccount(player)
    if account then
        outputChatBox("Account: " .. getAccountName(account), player, 255, 255, 0)
        dbQuery(function(qh, player)
            local result = dbPoll(qh, 0)
            if result and #result > 0 then
                local data = result[1]
                outputChatBox("DB Model: " .. tostring(data.Model), player, 0, 255, 255)
                outputChatBox("Current Model: " .. getElementModel(player), player, 255, 255, 0)
                outputChatBox("CustomSkinID: " .. tostring(getElementData(player, "customSkinID")), player, 255, 0, 255)
            else
                outputChatBox("No data found in DB", player, 255, 0, 0)
            end
        end, {player}, dbConn, "SELECT Model FROM accounts WHERE Username = ?", getAccountName(account))
    else
        outputChatBox("❌ No account found", player, 255, 0, 0)
    end
end)

-- Remove old setskin command from admin resource
removeCommandHandler("setskin")
outputDebugString("[PLAYERS] Overriding /setskin command from admin resource")

-- SETSKIN COMMAND MOVED TO END OF FILE FOR FINAL OVERRIDE

-- Working applyskin command (for testing)
addCommandHandler("applyskin", function(player, _, targetName, skinID)
    outputDebugString("[APPLYSKIN] Command called by " .. getPlayerName(player))
    outputChatBox("🔧 APPLYSKIN command received!", player, 255, 255, 0)
    
    -- Check admin level
    local adminLevel = tonumber(getElementData(player, "adminLevel")) or 0
    outputChatBox("Your admin level: " .. adminLevel, player, 255, 255, 0)
    
    if adminLevel < 2 then
        outputChatBox("❌ Need admin level 2+", player, 255, 0, 0)
        return
    end
    
    if not targetName or not skinID then
        outputChatBox("Usage: /applyskin [player] [skinID]", player, 255, 255, 0)
        return
    end
    
    local target = getPlayerFromNameOrId(targetName)
    if not target then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end
    
    local skin = tonumber(skinID)
    if not skin then
        outputChatBox("❌ Invalid skin ID!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("✅ Applying skin " .. skin .. " to " .. getPlayerName(target), player, 0, 255, 0)
    
    -- Apply skin directly
    if skin >= 20001 and skin <= 29999 then
        -- Custom skin
        local newmodelsResource = getResourceFromName("newmodels_azul")
        if newmodelsResource and getResourceState(newmodelsResource) == "running" then
            local success = exports["newmodels_azul"]:setElementCustomModel(target, skin)
            if success then
                outputChatBox("✅ Custom skin " .. skin .. " applied to " .. getPlayerName(target), player, 0, 255, 0)
                setElementData(target, "customSkinID", skin)
                setElementData(target, "pModel", skin) -- SA-MP style storage
                
                -- IMPORTANT: Save to database for persistence
                local dbConn = exports.amb:getDatabaseConnection() or _G.getDatabaseConnection and _G.getDatabaseConnection()
                if dbConn then
                    dbExec(dbConn, "UPDATE accounts SET Model = ? WHERE Username = ?", skin, getAccountName(getPlayerAccount(target)))
                    outputDebugString("[APPLYSKIN] Saved custom skin " .. skin .. " to database for " .. getPlayerName(target))
                else
                    outputChatBox("⚠️ Database not available - skin won't persist", player, 255, 255, 0)
                end
                
                -- SA-MP style success message
                outputChatBox("Skin cua ban da duoc thay doi thanh ID " .. skin .. " boi Administrator " .. getPlayerName(player) .. ".", target, 255, 255, 255)
                
                -- Log action
                if logAdminAction then
                    logAdminAction(player, "APPLYSKIN", getPlayerName(target), "Changed skin to " .. skin)
                end
            else
                outputChatBox("❌ Failed to apply custom skin " .. skin, player, 255, 0, 0)
            end
        else
            outputChatBox("❌ newmodels_azul not running!", player, 255, 0, 0)
        end
    else
        -- Standard skin
        setElementModel(target, skin)
        setElementData(target, "pModel", skin) -- SA-MP style storage
        
        -- IMPORTANT: Save to database for persistence
        local dbConn = exports.amb:getDatabaseConnection() or _G.getDatabaseConnection and _G.getDatabaseConnection()
        if dbConn then
            dbExec(dbConn, "UPDATE accounts SET Model = ? WHERE Username = ?", skin, getAccountName(getPlayerAccount(target)))
            outputDebugString("[APPLYSKIN] Saved standard skin " .. skin .. " to database for " .. getPlayerName(target))
        else
            outputChatBox("⚠️ Database not available - skin won't persist", player, 255, 255, 0)
        end
        
        outputChatBox("✅ Standard skin " .. skin .. " applied to " .. getPlayerName(target), player, 0, 255, 0)
        if getElementData(target, "customSkinID") then
            removeElementData(target, "customSkinID")
        end
        
        -- SA-MP style success message
        outputChatBox("Skin cua ban da duoc thay doi thanh ID " .. skin .. " boi Administrator " .. getPlayerName(player) .. ".", target, 255, 255, 255)
        
        -- Log action  
        if logAdminAction then
            logAdminAction(player, "APPLYSKIN", getPlayerName(target), "Changed skin to " .. skin)
        end
    end
end)

-- Dummy function to prevent errors (statistics tracking can be added later)
function incrementCommandStat(category)
    -- Do nothing for now, can be implemented later for statistics
end

-- Admin player management commands
local adminPlayerCommands = {
    "kick", "ban", "unban", "mute", "unmute", "freeze", "unfreeze",
    "slap", "kill", "heal", "armor", "setskin", "setinterior", "tp",
    "gethere", "spec", "unspec", "jail", "unjail", "warn", "unwarn"
}

-- Mute player command
addCommandHandler("mute", function(player, _, targetName, time, ...)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not targetName or not time then
        outputChatBox("USAGE: /mute [player] [time_minutes] [reason]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(targetName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local muteTime = tonumber(time)
    if not muteTime or muteTime <= 0 then
        outputChatBox("Thoi gian mute khong hop le!", player, 255, 0, 0)
        return
    end
    
    local reason = table.concat({...}, " ") or "Khong co ly do"
    
    -- Set player mute
    setElementData(target, "muted", true)
    setElementData(target, "muteTime", getRealTime().timestamp + (muteTime * 60))
    setElementData(target, "muteReason", reason)
    
    outputChatBox("Ban da bi mute boi admin " .. getPlayerName(player) .. " trong " .. muteTime .. " phut. Ly do: " .. reason, target, 255, 255, 0)
    outputChatBox("Ban da mute " .. getPlayerName(target) .. " trong " .. muteTime .. " phut.", player, 255, 255, 0)
    
    -- Auto unmute timer
    setTimer(function()
        if isElement(target) then
            setElementData(target, "muted", false)
            outputChatBox("Ban da het thoi gian bi mute.", target, 0, 255, 0)
        end
    end, muteTime * 60 * 1000, 1)
    
    -- Log action
    if logAdminAction then
        logAdminAction(player, "MUTE", getPlayerName(target), reason .. " (" .. muteTime .. " minutes)")
    end
    
    incrementCommandStat("adminCommands")
end)

-- Teleport to player command (SA-MP style: /tp [player])
addCommandHandler("tp", function(player, _, targetName)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not targetName then
        outputChatBox("USAGE: /tp [player]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(targetName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(target)
    local interior = getElementInterior(target)
    local dimension = getElementDimension(target)
    
    setElementPosition(player, x + 1, y, z)
    setElementInterior(player, interior)
    setElementDimension(player, dimension)
    
    outputChatBox("Ban da teleport den " .. getPlayerName(target), player, 255, 255, 0)
    
    -- Log action
    if logAdminAction then
        logAdminAction(player, "TP", getPlayerName(target), "Teleported to player")
    end
end)

-- Get player here command
addCommandHandler("gethere", function(player, _, targetName)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not targetName then
        outputChatBox("USAGE: /gethere [player]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(targetName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)
    
    setElementPosition(target, x + 1, y, z)
    setElementInterior(target, interior)
    setElementDimension(target, dimension)
    
    outputChatBox("Ban da goi " .. getPlayerName(target) .. " den ben minh", player, 255, 255, 0)
    outputChatBox("Ban da bi admin " .. getPlayerName(player) .. " goi den", target, 255, 255, 0)
    
    -- Log action
    if logAdminAction then
        logAdminAction(player, "GETHERE", getPlayerName(target), "Teleported player to admin")
    end
    
    incrementCommandStat("adminCommands")
end)

-- SA-MP Style Player ID System (0-based, reuse slots)
local MAX_PLAYERS = 500
local playerSlots = {} -- Track used slots

local function getNextAvailableID()
    for i = 0, MAX_PLAYERS - 1 do
        if not playerSlots[i] then
            return i
        end
    end
    return -1 -- Server full
end

local function releasePlayerID(id)
    if id and id >= 0 and id < MAX_PLAYERS then
        playerSlots[id] = nil
    end
end

-- Initialize player IDs for players already connected (server restart handling)
addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[PLAYER] Initializing player IDs after resource restart...")
    
    -- Clear the slots table to start fresh
    playerSlots = {}
    
    -- Reassign IDs to all currently connected players
    for _, player in ipairs(getElementsByType("player")) do
        local playerID = getNextAvailableID()
        if playerID >= 0 then
            playerSlots[playerID] = player
            setElementData(player, "ID", playerID) -- Use "ID" consistently
            outputDebugString("[PLAYER] Reassigned ID " .. playerID .. " to " .. getPlayerName(player) .. " after restart")
        else
            outputDebugString("[PLAYER] Server full during restart! Cannot assign ID to " .. getPlayerName(player), 2)
        end
    end
    
    outputDebugString("[PLAYER] Player ID initialization complete. " .. #getElementsByType("player") .. " players assigned IDs.")
end)

-- Assign Player ID when joining (SA-MP style: 0-based, reuse slots)
addEventHandler("onPlayerJoin", root, function()
    local playerID = getNextAvailableID()
    if playerID >= 0 then
        playerSlots[playerID] = source
        setElementData(source, "ID", playerID) -- Use "ID" consistently
        outputDebugString("[PLAYER] Assigned ID " .. playerID .. " to " .. getPlayerName(source))
    else
        outputDebugString("[PLAYER] Server full! Cannot assign ID to " .. getPlayerName(source), 2)
        kickPlayer(source, "Server full")
    end
end)

-- Release Player ID when quitting
addEventHandler("onPlayerQuit", root, function()
    local playerID = getElementData(source, "ID")
    if playerID and playerSlots then -- Add safety check for playerSlots table
        releasePlayerID(playerID)
        outputDebugString("[PLAYER] Released ID " .. playerID .. " from " .. getPlayerName(source))
    elseif playerID then
        outputDebugString("[PLAYER] Warning: Player " .. getPlayerName(source) .. " had ID " .. playerID .. " but playerSlots table not available (resource stopping?)")
    end
end)

-- Clean up when resource stops (prevent errors during restart)
addEventHandler("onResourceStop", resourceRoot, function()
    outputDebugString("[PLAYER] Resource stopping - clearing player slots table")
    playerSlots = nil -- Clear the table to prevent errors during restart
end)

-- Admin Players module loaded
outputDebugString("[ADMIN] Players module loaded with setskin override", 3)

-- FORCE OVERRIDE SETSKIN COMMAND AT THE END (should take priority)
addCommandHandler("setskin", function(player, _, targetName, skinID)
    outputDebugString("[SETSKIN-OVERRIDE] Final setskin command called by " .. getPlayerName(player))
    outputChatBox("🔧 SETSKIN (FINAL OVERRIDE) command received!", player, 255, 255, 0)
    
    -- EXACT SAME LOGIC AS APPLYSKIN FOR TESTING
    outputDebugString("[SETSKIN] Command called by " .. getPlayerName(player))
    outputChatBox("🔧 SETSKIN command received!", player, 255, 255, 0)
    
    -- Check admin level
    local adminLevel = tonumber(getElementData(player, "adminLevel")) or 0
    outputChatBox("Your admin level: " .. adminLevel, player, 255, 255, 0)
    
    if adminLevel < 2 then
        outputChatBox("❌ Need admin level 2+", player, 255, 0, 0)
        return
    end
    
    if not targetName or not skinID then
        outputChatBox("Usage: /setskin [player] [skinID]", player, 255, 255, 0)
        return
    end
    
    local target = getPlayerFromNameOrId(targetName)
    if not target then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end
    
    local skin = tonumber(skinID)
    if not skin then
        outputChatBox("❌ Invalid skin ID!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("✅ Applying skin " .. skin .. " to " .. getPlayerName(target), player, 0, 255, 0)
    
    -- Apply skin directly (EXACT SAME AS APPLYSKIN)
    if skin >= 20001 and skin <= 29999 then
        -- Custom skin
        local newmodelsResource = getResourceFromName("newmodels_azul")
        if newmodelsResource and getResourceState(newmodelsResource) == "running" then
            local success = exports["newmodels_azul"]:setElementCustomModel(target, skin)
            if success then
                outputChatBox("✅ Custom skin " .. skin .. " applied to " .. getPlayerName(target), player, 0, 255, 0)
                setElementData(target, "customSkinID", skin)
                setElementData(target, "pModel", skin) -- SA-MP style storage
                
                -- IMPORTANT: Save to database for persistence
                local dbConn = exports.amb:getDatabaseConnection() or _G.getDatabaseConnection and _G.getDatabaseConnection()
                if dbConn then
                    dbExec(dbConn, "UPDATE accounts SET Model = ? WHERE Username = ?", skin, getAccountName(getPlayerAccount(target)))
                    outputDebugString("[SETSKIN] Saved custom skin " .. skin .. " to database for " .. getPlayerName(target))
                else
                    outputChatBox("⚠️ Database not available - skin won't persist", player, 255, 255, 0)
                end
                
                -- SA-MP style success message
                outputChatBox("Skin cua ban da duoc thay doi thanh ID " .. skin .. " boi Administrator " .. getPlayerName(player) .. ".", target, 255, 255, 255)
                
                -- Log admin action
                if logAdminAction then
                    logAdminAction(player, "SETSKIN", getPlayerName(target), "Changed skin to " .. skin)
                end
            else
                outputChatBox("❌ Failed to apply custom skin", player, 255, 0, 0)
            end
        else
            outputChatBox("❌ Custom models resource not running", player, 255, 0, 0)
        end
    else
        -- Standard skin 
        setElementModel(target, skin)
        setElementData(target, "pModel", skin) -- SA-MP style storage
        outputChatBox("✅ Standard skin " .. skin .. " applied to " .. getPlayerName(target), player, 0, 255, 0)
        
        -- Save to database
        local dbConn = exports.amb:getDatabaseConnection() or _G.getDatabaseConnection and _G.getDatabaseConnection()
        if dbConn then
            dbExec(dbConn, "UPDATE accounts SET Model = ? WHERE Username = ?", skin, getAccountName(getPlayerAccount(target)))
            outputDebugString("[SETSKIN] Saved standard skin " .. skin .. " to database for " .. getPlayerName(target))
        else
            outputChatBox("⚠️ Database not available - skin won't persist", player, 255, 255, 0)
        end
        
        -- SA-MP style success message
        outputChatBox("Skin cua ban da duoc thay doi thanh ID " .. skin .. " boi Administrator " .. getPlayerName(player) .. ".", target, 255, 255, 255)
        
        -- Log admin action
        if logAdminAction then
            logAdminAction(player, "SETSKIN", getPlayerName(target), "Changed skin to " .. skin)
        end
    end
end)
