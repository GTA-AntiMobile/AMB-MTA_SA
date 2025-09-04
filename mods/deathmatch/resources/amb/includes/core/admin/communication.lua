-- ================================
-- AMB MTA:SA - Admin Communication System
-- Mass migration of admin communication commands
-- ================================
-- Admin chat commands
addCommandHandler("a", function(player, cmd, ...)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end

    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /a [tin nhan]", player, 255, 255, 255)
        return
    end

    local playerName = getPlayerName(player)
    local playerData = getElementData(player, "playerData")
    local adminLevel = playerData and playerData.adminLevel or 1

    -- Send to all admins
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(targetPlayer, 1) then
            outputChatBox(string.format("🛡️ [ADMIN] %s: %s", playerName, message), targetPlayer, 255, 255, 100)
        end
    end

    outputDebugString("[ADMIN CHAT] " .. playerName .. ": " .. message)
end)

-- Community helper chat
addCommandHandler("c", function(player, cmd, ...)
    local playerData = getElementData(player, "playerData")
    if not playerData then
        return
    end

    local isHelper = playerData.helper or 0
    local isPlayerAdmin = playerData.adminLevel or 0

    if isHelper < 1 and isPlayerAdmin < 1 then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end

    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /c [tin nhan]", player, 255, 255, 255)
        return
    end

    local playerName = getPlayerName(player)
    local prefix = "🆘"
    if isPlayerAdmin >= 1 then
        prefix = "🛡️"
    end

    -- Send to all helpers and admins
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        local targetData = getElementData(targetPlayer, "playerData")
        if targetData and (targetData.helper >= 1 or targetData.adminLevel >= 1) then
            outputChatBox(string.format("%s [HELPER] %s: %s", prefix, playerName, message), targetPlayer, 100, 255, 100)
        end
    end

    outputDebugString("[HELPER CHAT] " .. playerName .. ": " .. message)
end)

-- Admin duty command
addCommandHandler("aduty", function(player)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end

    local playerData = getElementData(player, "playerData")
    local isOnDuty = playerData.adminDuty or false

    playerData.adminDuty = not isOnDuty
    setElementData(player, "playerData", playerData)

    local playerName = getPlayerName(player)

    if playerData.adminDuty then
        outputChatBox("✅ Ban da bat che do hanh chinh.", player, 0, 255, 0)
        for _, targetPlayer in ipairs(getElementsByType("player")) do
            if isPlayerAdmin(targetPlayer, 1) then
                outputChatBox(string.format("🛡️ Admin %s da bat che do hanh chinh.", playerName), targetPlayer,
                    255, 255, 100)
            end
        end
    else
        outputChatBox("❌ Ban da tat che do hanh chinh.", player, 255, 100, 100)
        for _, targetPlayer in ipairs(getElementsByType("player")) do
            if isPlayerAdmin(targetPlayer, 1) then
                outputChatBox(string.format("🛡️ Admin %s da tat che do hanh chinh.", playerName), targetPlayer,
                    255, 255, 100)
            end
        end
    end
end)

-- Admin list command
addCommandHandler("admins", function(player)
    local onlineAdmins = {}

    for _, targetPlayer in ipairs(getElementsByType("player")) do
        local playerData = getElementData(targetPlayer, "playerData")
        if playerData and playerData.adminLevel and playerData.adminLevel >= 1 then
            local adminInfo = {
                name = getPlayerName(targetPlayer),
                level = playerData.adminLevel,
                duty = playerData.adminDuty or false,
                id = getElementData(targetPlayer, "playerID") or 0
            }
            table.insert(onlineAdmins, adminInfo)
        end
    end

    if #onlineAdmins == 0 then
        outputChatBox("❌ Khong co admin nao online.", player, 255, 100, 100)
        return
    end

    outputChatBox("🛡️ ===== ADMIN ONLINE =====", player, 255, 255, 100)
    for _, admin in ipairs(onlineAdmins) do
        local dutyStatus = admin.duty and "ON DUTY" or "OFF DUTY"
        local dutyColor = admin.duty and "00FF00" or "FF0000"

        outputChatBox(string.format("ID %d: %s (Level %d) - [%s]", admin.id, admin.name, admin.level, dutyStatus),
            player, 255, 255, 255)
    end
    outputChatBox("========================", player, 255, 255, 100)
end)

-- Admin help command
addCommandHandler("ahelp", function(player, cmd, ...)
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /ahelp [tin nhan help]", player, 255, 255, 255)
        return
    end

    local playerName = getPlayerName(player)
    local playerID = getElementData(player, "playerID") or 0

    -- Send to all online admins
    local sentToAdmins = 0
    for _, admin in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(admin, 1) then
            outputChatBox(string.format("🆘 [HELP] %s (ID:%d): %s", playerName, playerID, message), admin, 255, 255, 0)
            sentToAdmins = sentToAdmins + 1
        end
    end

    if sentToAdmins > 0 then
        outputChatBox(string.format("✅ Tin nhan help da gui den %d admin(s).", sentToAdmins), player, 0, 255, 0)
    else
        outputChatBox("❌ Khong co admin nao online de nhan help.", player, 255, 100, 100)
    end

    outputDebugString("[AHELP] " .. playerName .. " (ID:" .. playerID .. "): " .. message)
end)

-- Accept help command
addCommandHandler("accepthelp", function(player, cmd, playerIdOrName)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /accepthelp [player_id]", player, 255, 255, 255)
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

    outputChatBox(string.format("✅ Admin %s da nhan help cua ban.", adminName), targetPlayer, 0, 255, 0)
    outputChatBox(string.format("✅ Ban da nhan help cua %s.", targetName), player, 0, 255, 0)

    -- Notify other admins
    for _, admin in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(admin, 1) and admin ~= player then
            outputChatBox(string.format("🛡️ Admin %s da nhan help cua %s", adminName, targetName), admin, 255, 255,
                100)
        end
    end
end)

-- Admin message to player
addCommandHandler("amsg", function(player, cmd, playerIdOrName, ...)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /amsg [player_id] [tin nhan]", player, 255, 255, 255)
        return
    end

    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /amsg [player_id] [tin nhan]", player, 255, 255, 255)
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

    outputChatBox(string.format("🛡️ [ADMIN MSG] %s: %s", adminName, message), targetPlayer, 255, 100, 100)
    outputChatBox(string.format("✅ Tin nhan da gui den %s: %s", targetName, message), player, 0, 255, 0)

    outputDebugString("[ADMIN MSG] " .. adminName .. " -> " .. targetName .. ": " .. message)
end)

-- Admin mute command
addCommandHandler("admute", function(player, cmd, playerIdOrName, minutes, ...)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end

    if not playerIdOrName or not minutes then
        outputChatBox("Su dung: /admute [player_id] [minutes] [reason]", player, 255, 255, 255)
        return
    end

    local reason = table.concat({...}, " ") or "Khong co ly do"
    local muteTime = tonumber(minutes)

    if not muteTime or muteTime <= 0 then
        outputChatBox("❌ Thoi gian mute khong hop le.", player, 255, 100, 100)
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

    -- Set mute
    local playerData = getElementData(targetPlayer, "playerData") or {}
    playerData.muted = true
    playerData.muteTime = getRealTime().timestamp + (muteTime * 60)
    playerData.muteReason = reason
    setElementData(targetPlayer, "playerData", playerData)

    outputChatBox(string.format("❌ Ban da bi mute %d phut. Ly do: %s", muteTime, reason), targetPlayer, 255, 100, 100)
    outputChatBox(string.format("✅ Da mute %s trong %d phut.", targetName, muteTime), player, 0, 255, 0)

    -- Notify all admins
    for _, admin in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(admin, 1) then
            outputChatBox(string.format("🛡️ %s da mute %s (%d phut): %s", adminName, targetName, muteTime, reason),
                admin, 255, 255, 100)
        end
    end
end)

-- Admin unmute command
addCommandHandler("adunmute", function(player, cmd, playerIdOrName)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban khong co quyen su dung lenh nay.", player, 255, 100, 100)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /adunmute [player_id]", player, 255, 255, 255)
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

    -- Remove mute
    local playerData = getElementData(targetPlayer, "playerData") or {}
    playerData.muted = false
    playerData.muteTime = nil
    playerData.muteReason = nil
    setElementData(targetPlayer, "playerData", playerData)

    outputChatBox("✅ Ban da duoc unmute.", targetPlayer, 0, 255, 0)
    outputChatBox(string.format("✅ Da unmute %s.", targetName), player, 0, 255, 0)

    -- Notify all admins
    for _, admin in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(admin, 1) then
            outputChatBox(string.format("🛡️ %s da unmute %s", adminName, targetName), admin, 255, 255, 100)
        end
    end
end)
