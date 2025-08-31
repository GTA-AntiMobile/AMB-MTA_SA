-- ================================
-- AMB MTA:SA - Admin Players Management
-- Core admin commands for player management
-- ================================

-- Admin player management commands
local adminPlayerCommands = {
    "kick", "ban", "unban", "mute", "unmute", "freeze", "unfreeze",
    "slap", "kill", "heal", "armor", "setskin", "setinterior", "goto",
    "gethere", "spec", "unspec", "jail", "unjail", "warn", "unwarn"
}

-- Resolve target by ID or name
local function resolveTarget(targetName)
    if tonumber(targetName) then
        return getPlayerById(tonumber(targetName))
    else
        return getPlayerFromPartialName(targetName)
    end
end

-- Kick player command
addCommandHandler("kick", function(player, cmd, targetName, ...)
    if not isPlayerAdmin(player, ADMIN_LEVEL_MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not targetName then
        outputChatBox("USAGE: /kick [player] [reason]", player, 255, 255, 255)
        return
    end

    local target = resolveTarget(targetName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local reason = table.concat({...}, " ") or "Khong co ly do"
    
    outputChatBox("Admin " .. getPlayerName(player) .. " da kick " .. getPlayerName(target) .. ". Ly do: " .. reason, root, 255, 255, 0)
    
    -- Log action
    logAdminAction(player, "KICK", getPlayerName(target), reason)
    
    setTimer(function()
        kickPlayer(target, "Ban da bi kick boi admin. Ly do: " .. reason)
    end, 1000, 1)
    
    incrementCommandStat("adminCommands")
end)

-- Ban player command
addCommandHandler("ban", function(player, cmd, targetName, ...)
    if not isPlayerAdmin(player, ADMIN_LEVEL_ADMIN) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not targetName then
        outputChatBox("USAGE: /ban [player] [reason]", player, 255, 255, 255)
        return
    end

    local target = resolveTarget(targetName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local reason = table.concat({...}, " ") or "Khong co ly do"
    
    -- Add to ban database
    addPlayerBan(target, player, reason)
    
    outputChatBox("Admin " .. getPlayerName(player) .. " da ban " .. getPlayerName(target) .. ". Ly do: " .. reason, root, 255, 255, 0)
    
    -- Log action
    logAdminAction(player, "BAN", getPlayerName(target), reason)
    
    setTimer(function()
        banPlayer(target, true, true, true, player, reason)
    end, 1000, 1)
    
    incrementCommandStat("adminCommands")
end)

-- Mute player command
addCommandHandler("mute", function(player, cmd, targetName, time, ...)
    if not isPlayerAdmin(player, ADMIN_LEVEL_MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not targetName or not time then
        outputChatBox("USAGE: /mute [player] [time_minutes] [reason]", player, 255, 255, 255)
        return
    end

    local target = resolveTarget(targetName)
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
    logAdminAction(player, "MUTE", getPlayerName(target), reason .. " (" .. muteTime .. " minutes)")
    
    incrementCommandStat("adminCommands")
end)

-- Freeze player command
addCommandHandler("freeze", function(player, cmd, targetName)
    if not isPlayerAdmin(player, ADMIN_LEVEL_MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not targetName then
        outputChatBox("USAGE: /freeze [player]", player, 255, 255, 255)
        return
    end

    local target = resolveTarget(targetName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    toggleControl(target, "forwards", false)
    toggleControl(target, "backwards", false)
    toggleControl(target, "left", false)
    toggleControl(target, "right", false)
    toggleControl(target, "jump", false)
    
    setElementData(target, "frozen", true)
    
    outputChatBox("Ban da bi dong bang boi admin!", target, 255, 255, 0)
    outputChatBox("Ban da dong bang " .. getPlayerName(target), player, 255, 255, 0)
    
    -- Log action
    logAdminAction(player, "FREEZE", getPlayerName(target), "Player frozen")
    
    incrementCommandStat("adminCommands")
end)

-- Unfreeze player command

-- Goto player command
addCommandHandler("goto", function(player, cmd, targetName)
    if not isPlayerAdmin(player, ADMIN_LEVEL_MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not targetName then
        outputChatBox("USAGE: /goto [player]", player, 255, 255, 255)
        return
    end

    local target = resolveTarget(targetName)
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
    logAdminAction(player, "GOTO", getPlayerName(target), "Teleported to player")
    
    incrementCommandStat("adminCommands")
end)

-- Get player here command
addCommandHandler("gethere", function(player, cmd, targetName)
    if not isPlayerAdmin(player, ADMIN_LEVEL_MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not targetName then
        outputChatBox("USAGE: /gethere [player]", player, 255, 255, 255)
        return
    end

    local target = resolveTarget(targetName)
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
    logAdminAction(player, "GETHERE", getPlayerName(target), "Teleported player to admin")
    
    incrementCommandStat("adminCommands")
end)

-- Heal player command
addCommandHandler("heal", function(player, cmd, targetName)
    if not isPlayerAdmin(player, ADMIN_LEVEL_MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    local target = player
    if targetName then
        target = resolveTarget(targetName)
        if not target then
            outputChatBox("Khong tim thay player!", player, 255, 0, 0)
            return
        end
    end
    
    setElementHealth(target, 100)
    
    if target == player then
        outputChatBox("Ban da hoi phuc suc khoe cua minh", player, 0, 255, 0)
    else
        outputChatBox("Ban da hoi phuc suc khoe cho " .. getPlayerName(target), player, 255, 255, 0)
        outputChatBox("Admin da hoi phuc suc khoe cho ban", target, 0, 255, 0)
    end
    
    -- Log action
    logAdminAction(player, "HEAL", getPlayerName(target), "Player healed")
    
    incrementCommandStat("adminCommands")
end)

-- Set player skin command
addCommandHandler("setskin", function(player, cmd, targetName, skinID)
    
    if not isPlayerAdmin(player, ADMIN_LEVEL_MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not targetName or not skinID then
        outputChatBox("USAGE: /setskin [player ID hoặc tên] [skin_id]", player, 255, 255, 255)
        return
    end
    local target = resolveTarget(targetName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local skin = tonumber(skinID)
    if not skin or ((skin < 0 or skin > 311) and (skin < 20001 or skin > 29999)) then
        outputChatBox("Skin ID khong hop le! (0-311 hoac 20001-29999)", player, 255, 0, 0)
        return
    end

    -- Save current position and stats before changing skin
    local x, y, z = getElementPosition(target)
    local rx, ry, rz = getElementRotation(target)
    local interior = getElementInterior(target)
    local dimension = getElementDimension(target)
    local health = getElementHealth(target)
    local armor = getPedArmor(target)
    local team = getPlayerTeam(target)
    local money = getPlayerMoney(target)
    local weapon = getPedWeapon(target)
    local ammo = getPedTotalAmmo(target)

    outputDebugString("[SETSKIN] Saving position for " .. getPlayerName(target) .. ": " .. x .. ", " .. y .. ", " .. z)

    if skin >= 20001 and skin <= 29999 then
        -- Custom skin: map về baseSkinID, lưu customSkinID
        local baseSkinID = 2 + ((skin - 20001) % 310) -- 2-311
        setElementModel(target, baseSkinID)
        setElementData(target, "customSkinID", skin)
        triggerClientEvent(target, "onClientLoadCustomSkin", resourceRoot, skin)
        outputDebugString("[SETSKIN] Custom skin " .. skin .. " mapped to base ID " .. baseSkinID)
    else
        -- Skin thường: set model, xóa customSkinID
        setElementModel(target, skin)
        if getElementData(target, "customSkinID") then
            removeElementData(target, "customSkinID")
        end
        outputDebugString("[SETSKIN] Set regular skin " .. skin)
    end
end)

-- Check current skin command
addCommandHandler("myskin", function(player)
    local currentSkin = getElementModel(player)
    local customSkin = getElementData(player, "playerSkin")
    
    if customSkin and customSkin ~= currentSkin then
        outputChatBox("Current skin: " .. currentSkin .. " (Base) | Custom: " .. customSkin, player, 100, 255, 255)
    else
        outputChatBox("Current skin: " .. currentSkin, player, 100, 255, 255)
    end
end)

-- Gán playerId cho mỗi player khi join (ID online, tự tăng)
local nextPlayerId = 1
addEventHandler("onPlayerJoin", root, function()
    setElementData(source, "playerId", nextPlayerId)
    nextPlayerId = nextPlayerId + 1
end)

-- Hàm lấy player theo playerId
function getPlayerById(id)
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerId") == id then
            return p
        end
    end
    return nil
end

-- Admin Players module loaded (22 commands)
registerCommandSystem("Admin Players", 22, true)
