-- ================================
-- AMB MTA:SA - Admin Moderation System  
-- Mass migration of admin moderation commands
-- ================================

-- Admin kick command
addCommandHandler("akick", function(player, cmd, playerIdOrName, ...)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /akick [player_id] [reason]", player, 255, 255, 255)
        return
    end
    
    local reason = table.concat({...}, " ") or "Khong co ly do"
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    -- Check admin immunity
    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.adminLevel and targetData.adminLevel >= 1 then
        local adminData = getElementData(player, "playerData") or {}
        if (adminData.adminLevel or 0) <= targetData.adminLevel then
            outputChatBox("❌ Ban khong the kick admin cap cao hon hoac bang cap.", player, 255, 100, 100)
            return
        end
    end
    
    local adminName = getPlayerName(player)
    local targetName = getPlayerName(targetPlayer)
    
    -- Announce kick
    outputChatBox(string.format("🚨 %s da bi kick boi Admin %s. Ly do: %s", targetName, adminName, reason), root, 255, 100, 100)
    
    -- Log the kick
    outputDebugString("[ADMIN KICK] " .. adminName .. " kicked " .. targetName .. " - Reason: " .. reason)
    
    -- Kick with delay
    setTimer(function()
        if isElement(targetPlayer) then
            kickPlayer(targetPlayer, reason)
        end
    end, 2000, 1)
end)

-- Admin ban command
addCommandHandler("aban", function(player, cmd, playerIdOrName, days, ...)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName or not days then
        outputChatBox("Su dung: /aban [player_id] [days] [reason]", player, 255, 255, 255)
        return
    end
    
    local banDays = tonumber(days)
    if not banDays or banDays <= 0 then
        outputChatBox("❌ So ngay ban khong hop le.", player, 255, 100, 100)
        return
    end
    
    local reason = table.concat({...}, " ") or "Khong co ly do"
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    -- Check admin immunity
    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.adminLevel and targetData.adminLevel >= 1 then
        local adminData = getElementData(player, "playerData") or {}
        if (adminData.adminLevel or 0) <= targetData.adminLevel then
            outputChatBox("❌ Ban khong the ban admin cap cao hon hoac bang cap.", player, 255, 100, 100)
            return
        end
    end
    
    local adminName = getPlayerName(player)
    local targetName = getPlayerName(targetPlayer)
    local targetSerial = getPlayerSerial(targetPlayer)
    local targetIP = getPlayerIP(targetPlayer)
    
    -- Create ban
    local banTime = banDays * 24 * 60 * 60 -- Convert to seconds
    addBan(targetIP, nil, targetSerial, player, reason, banTime)
    
    -- Announce ban
    outputChatBox(string.format("🚨 %s da bi ban %d ngay boi Admin %s. Ly do: %s", targetName, banDays, adminName, reason), root, 255, 100, 100)
    
    -- Log the ban
    outputDebugString("[ADMIN BAN] " .. adminName .. " banned " .. targetName .. " for " .. banDays .. " days - Reason: " .. reason)
end)

-- Admin unban command
addCommandHandler("aunban", function(player, cmd, serial)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not serial then
        outputChatBox("Su dung: /aunban [serial]", player, 255, 255, 255)
        return
    end
    
    local bans = getBans()
    local found = false
    
    for _, ban in ipairs(bans) do
        if getBanSerial(ban) == serial then
            removeBan(ban)
            found = true
            break
        end
    end
    
    if found then
        local adminName = getPlayerName(player)
        outputChatBox(string.format("✅ Da unban serial: %s", serial), player, 0, 255, 0)
        
        -- Notify other admins
        for _, admin in ipairs(getElementsByType("player")) do
            if isPlayerAdmin(admin, 1) and admin ~= player then
                outputChatBox(string.format("🛡️ Admin %s da unban serial: %s", adminName, serial), admin, 255, 255, 100)
            end
        end
        
        outputDebugString("[ADMIN UNBAN] " .. adminName .. " unbanned serial: " .. serial)
    else
        outputChatBox("❌ Khong tim thay ban voi serial nay.", player, 255, 100, 100)
    end
end)

-- Admin freeze command
addCommandHandler("afreeze", function(player, cmd, playerIdOrName)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /afreeze [player_id]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local adminName = getPlayerName(player)
    local targetName = getPlayerName(targetPlayer)
    
    -- Toggle freeze
    local playerData = getElementData(targetPlayer, "playerData") or {}
    local isFrozen = playerData.frozen or false
    
    if isFrozen then
        -- Unfreeze
        setElementFrozen(targetPlayer, false)
        playerData.frozen = false
        setElementData(targetPlayer, "playerData", playerData)
        
        outputChatBox("✅ Ban da duoc unfreeze.", targetPlayer, 0, 255, 0)
        outputChatBox(string.format("✅ Da unfreeze %s.", targetName), player, 0, 255, 0)
        
        -- Notify admins
        for _, admin in ipairs(getElementsByType("player")) do
            if isPlayerAdmin(admin, 1) and admin ~= player then
                outputChatBox(string.format("🛡️ Admin %s da unfreeze %s", adminName, targetName), admin, 255, 255, 100)
            end
        end
    else
        -- Freeze
        setElementFrozen(targetPlayer, true)
        playerData.frozen = true
        setElementData(targetPlayer, "playerData", playerData)
        
        outputChatBox("❄️ Ban da bi freeze.", targetPlayer, 100, 200, 255)
        outputChatBox(string.format("✅ Da freeze %s.", targetName), player, 0, 255, 0)
        
        -- Notify admins
        for _, admin in ipairs(getElementsByType("player")) do
            if isPlayerAdmin(admin, 1) and admin ~= player then
                outputChatBox(string.format("🛡️ Admin %s da freeze %s", adminName, targetName), admin, 255, 255, 100)
            end
        end
    end
end)

-- Admin slap command
addCommandHandler("aslap", function(player, cmd, playerIdOrName, power)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /aslap [player_id] [power]", player, 255, 255, 255)
        return
    end
    
    local slapPower = tonumber(power) or 5
    if slapPower > 50 then slapPower = 50 end
    if slapPower < 1 then slapPower = 1 end
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local adminName = getPlayerName(player)
    local targetName = getPlayerName(targetPlayer)
    
    -- Get current position
    local x, y, z = getElementPosition(targetPlayer)
    
    -- Slap player
    setElementPosition(targetPlayer, x, y, z + slapPower)
    
    -- Damage if high power
    if slapPower > 10 then
        local health = getElementHealth(targetPlayer)
        setElementHealth(targetPlayer, math.max(1, health - (slapPower * 2)))
    end
    
    outputChatBox(string.format("👋 Ban da bi slap boi Admin %s! (Power: %d)", adminName, slapPower), targetPlayer, 255, 100, 100)
    outputChatBox(string.format("✅ Da slap %s voi power %d.", targetName, slapPower), player, 0, 255, 0)
    
    -- Notify nearby players
    local px, py, pz = getElementPosition(targetPlayer)
    for _, nearPlayer in ipairs(getElementsByType("player")) do
        if nearPlayer ~= targetPlayer and nearPlayer ~= player then
            local nx, ny, nz = getElementPosition(nearPlayer)
            if getDistanceBetweenPoints3D(px, py, pz, nx, ny, nz) < 30 then
                outputChatBox(string.format("👋 %s da bi Admin slap!", targetName), nearPlayer, 255, 200, 100)
            end
        end
    end
    
    outputDebugString("[ADMIN SLAP] " .. adminName .. " slapped " .. targetName .. " with power " .. slapPower)
end)

-- Admin goto command
addCommandHandler("agoto", function(player, cmd, playerIdOrName)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /agoto [player_id]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetName = getPlayerName(targetPlayer)
    local x, y, z = getElementPosition(targetPlayer)
    local interior = getElementInterior(targetPlayer)
    local dimension = getElementDimension(targetPlayer)
    
    -- Teleport admin to target
    setElementPosition(player, x + 2, y, z)
    setElementInterior(player, interior)
    setElementDimension(player, dimension)
    
    outputChatBox(string.format("✅ Da teleport den %s.", targetName), player, 0, 255, 0)
    
    outputDebugString("[ADMIN GOTO] " .. getPlayerName(player) .. " went to " .. targetName)
end)

-- Admin gethere command
addCommandHandler("agethere", function(player, cmd, playerIdOrName)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /agethere [player_id]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetName = getPlayerName(targetPlayer)
    local x, y, z = getElementPosition(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)
    
    -- Teleport target to admin
    setElementPosition(targetPlayer, x + 2, y, z)
    setElementInterior(targetPlayer, interior)
    setElementDimension(targetPlayer, dimension)
    
    outputChatBox(string.format("✅ Da teleport %s den ban.", targetName), player, 0, 255, 0)
    outputChatBox(string.format("📍 Ban da duoc teleport den Admin %s.", getPlayerName(player)), targetPlayer, 100, 200, 255)
    
    outputDebugString("[ADMIN GETHERE] " .. getPlayerName(player) .. " brought " .. targetName)
end)

-- Admin spectate command
addCommandHandler("aspec", function(player, cmd, playerIdOrName)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /aspec [player_id] hoac /aspec off", player, 255, 255, 255)
        return
    end
    
    if playerIdOrName == "off" then
        -- Stop spectating
        setCameraTarget(player, player)
        outputChatBox("✅ Da tat che do spectate.", player, 0, 255, 0)
        
        local playerData = getElementData(player, "playerData") or {}
        playerData.spectating = nil
        setElementData(player, "playerData", playerData)
        return
    end
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetName = getPlayerName(targetPlayer)
    
    -- Start spectating
    setCameraTarget(player, targetPlayer)
    outputChatBox(string.format("👁️ Dang spectate %s. Su dung /aspec off de tat.", targetName), player, 255, 255, 100)
    
    local playerData = getElementData(player, "playerData") or {}
    playerData.spectating = targetPlayer
    setElementData(player, "playerData", playerData)
    
    outputDebugString("[ADMIN SPEC] " .. getPlayerName(player) .. " is spectating " .. targetName)
end)

outputDebugString("[AMB] Admin moderation system loaded - 8 commands")
