-- ================================
-- AMB MTA:SA - Gang/Family System Commands
-- Mass migration of gang-related commands
-- ================================

-- Family chat command
addCommandHandler("f", function(player, cmd, ...)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.family or playerData.family <= 0 then
        outputChatBox("❌ Ban khong co family.", player, 255, 100, 100)
        return
    end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /f [tin nhan]", player, 255, 255, 255)
        return
    end
    
    local playerName = getPlayerName(player)
    local familyID = playerData.family
    
    -- Send to all family members
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        local targetData = getElementData(targetPlayer, "playerData")
        if targetData and targetData.family == familyID then
            outputChatBox(string.format("👥 [FAMILY] %s: %s", playerName, message), targetPlayer, 255, 100, 255)
        end
    end
end)

-- Gang chat command
addCommandHandler("g", function(player, cmd, ...)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.gang or playerData.gang <= 0 then
        outputChatBox("❌ Ban khong co gang.", player, 255, 100, 100)
        return
    end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /g [tin nhan]", player, 255, 255, 255)
        return
    end
    
    local playerName = getPlayerName(player)
    local gangID = playerData.gang
    
    -- Send to all gang members
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        local targetData = getElementData(targetPlayer, "playerData")
        if targetData and targetData.gang == gangID then
            outputChatBox(string.format("⚔️ [GANG] %s: %s", playerName, message), targetPlayer, 255, 0, 0)
        end
    end
end)

-- Family invite command
addCommandHandler("finvite", function(player, cmd, playerIdOrName)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.family or playerData.family <= 0 then
        outputChatBox("❌ Ban khong co family.", player, 255, 100, 100)
        return
    end
    
    if (playerData.familyRank or 0) < 5 then -- Leader rank
        outputChatBox("❌ Ban khong co quyen invite family members.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /finvite [player_id]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.family and targetData.family > 0 then
        outputChatBox("❌ Nguoi choi da co family roi.", player, 255, 100, 100)
        return
    end
    
    -- Send invitation
    targetData.familyInvite = {
        family = playerData.family,
        inviter = player,
        time = getRealTime().timestamp
    }
    setElementData(targetPlayer, "playerData", targetData)
    
    outputChatBox(string.format("✅ Da gui family invite den %s.", getPlayerName(targetPlayer)), player, 0, 255, 0)
    outputChatBox(string.format("👥 %s da moi ban vao family. Su dung /faccept de accept.", getPlayerName(player)), targetPlayer, 255, 255, 100)
end)

-- Accept family invite
addCommandHandler("faccept", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.familyInvite then
        outputChatBox("❌ Ban khong co family invite nao.", player, 255, 100, 100)
        return
    end
    
    local invite = playerData.familyInvite
    if not isElement(invite.inviter) then
        outputChatBox("❌ Family invite da expired.", player, 255, 100, 100)
        playerData.familyInvite = nil
        setElementData(player, "playerData", playerData)
        return
    end
    
    -- Join family
    playerData.family = invite.family
    playerData.familyRank = 1 -- Lowest rank
    playerData.familyInvite = nil
    setElementData(player, "playerData", playerData)
    
    outputChatBox("✅ Ban da gia nhap family!", player, 0, 255, 0)
    outputChatBox(string.format("👥 %s da gia nhap family.", getPlayerName(player)), invite.inviter, 0, 255, 0)
end)

-- Uninvite from family
addCommandHandler("funinvite", function(player, cmd, playerIdOrName)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.family or playerData.family <= 0 then
        outputChatBox("❌ Ban khong co family.", player, 255, 100, 100)
        return
    end
    
    if (playerData.familyRank or 0) < 4 then
        outputChatBox("❌ Ban khong co quyen kick family members.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /funinvite [player_id]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.family ~= playerData.family then
        outputChatBox("❌ Nguoi choi khong cung family.", player, 255, 100, 100)
        return
    end
    
    if (targetData.familyRank or 0) >= (playerData.familyRank or 0) then
        outputChatBox("❌ Ban khong the kick nguoi co rank cao hon.", player, 255, 100, 100)
        return
    end
    
    -- Remove from family
    targetData.family = 0
    targetData.familyRank = 0
    setElementData(targetPlayer, "playerData", targetData)
    
    outputChatBox(string.format("✅ Da kick %s khoi family.", getPlayerName(targetPlayer)), player, 255, 255, 0)
    outputChatBox("❌ Ban da bi kick khoi family.", targetPlayer, 255, 100, 100)
end)

-- Quit family
addCommandHandler("fquit", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.family or playerData.family <= 0 then
        outputChatBox("❌ Ban khong co family.", player, 255, 100, 100)
        return
    end
    
    if (playerData.familyRank or 0) >= 5 then -- Leader
        outputChatBox("❌ Leader khong the quit family. Transfer leadership truoc.", player, 255, 100, 100)
        return
    end
    
    -- Leave family
    local familyID = playerData.family
    playerData.family = 0
    playerData.familyRank = 0
    setElementData(player, "playerData", playerData)
    
    -- Notify family members
    for _, familyPlayer in ipairs(getElementsByType("player")) do
        local familyData = getElementData(familyPlayer, "playerData")
        if familyData and familyData.family == familyID then
            outputChatBox(string.format("👥 %s da roi khoi family.", getPlayerName(player)), familyPlayer, 255, 255, 100)
        end
    end
    
    outputChatBox("✅ Ban da roi khoi family.", player, 255, 255, 100)
end)

-- Gang invite command
addCommandHandler("ginvite", function(player, cmd, playerIdOrName)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.gang or playerData.gang <= 0 then
        outputChatBox("❌ Ban khong co gang.", player, 255, 100, 100)
        return
    end
    
    if (playerData.gangRank or 0) < 5 then
        outputChatBox("❌ Ban khong co quyen invite gang members.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /ginvite [player_id]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.gang and targetData.gang > 0 then
        outputChatBox("❌ Nguoi choi da co gang roi.", player, 255, 100, 100)
        return
    end
    
    -- Send invitation
    targetData.gangInvite = {
        gang = playerData.gang,
        inviter = player,
        time = getRealTime().timestamp
    }
    setElementData(targetPlayer, "playerData", targetData)
    
    outputChatBox(string.format("✅ Da gui gang invite den %s.", getPlayerName(targetPlayer)), player, 0, 255, 0)
    outputChatBox(string.format("⚔️ %s da moi ban vao gang. Su dung /gaccept de accept.", getPlayerName(player)), targetPlayer, 255, 100, 100)
end)

-- Accept gang invite
addCommandHandler("gaccept", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.gangInvite then
        outputChatBox("❌ Ban khong co gang invite nao.", player, 255, 100, 100)
        return
    end
    
    local invite = playerData.gangInvite
    if not isElement(invite.inviter) then
        outputChatBox("❌ Gang invite da expired.", player, 255, 100, 100)
        playerData.gangInvite = nil
        setElementData(player, "playerData", playerData)
        return
    end
    
    -- Join gang
    playerData.gang = invite.gang
    playerData.gangRank = 1
    playerData.gangInvite = nil
    setElementData(player, "playerData", playerData)
    
    outputChatBox("✅ Ban da gia nhap gang!", player, 0, 255, 0)
    outputChatBox(string.format("⚔️ %s da gia nhap gang.", getPlayerName(player)), invite.inviter, 0, 255, 0)
end)

-- Gang members list
addCommandHandler("gmembers", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.gang or playerData.gang <= 0 then
        outputChatBox("❌ Ban khong co gang.", player, 255, 100, 100)
        return
    end
    
    local gangID = playerData.gang
    local members = {}
    
    for _, gangPlayer in ipairs(getElementsByType("player")) do
        local gangData = getElementData(gangPlayer, "playerData")
        if gangData and gangData.gang == gangID then
            table.insert(members, {
                name = getPlayerName(gangPlayer),
                rank = gangData.gangRank or 1,
                online = true
            })
        end
    end
    
    outputChatBox("⚔️ ===== GANG MEMBERS =====", player, 255, 255, 0)
    for _, member in ipairs(members) do
        local rankNames = {"Member", "Soldier", "Captain", "Lieutenant", "Leader"}
        local rankName = rankNames[member.rank] or "Member"
        outputChatBox(string.format("• %s - %s %s", member.name, rankName, member.online and "(Online)" or "(Offline)"), player, 255, 255, 255)
    end
end)

-- Family members list
addCommandHandler("fmembers", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.family or playerData.family <= 0 then
        outputChatBox("❌ Ban khong co family.", player, 255, 100, 100)
        return
    end
    
    local familyID = playerData.family
    local members = {}
    
    for _, familyPlayer in ipairs(getElementsByType("player")) do
        local familyData = getElementData(familyPlayer, "playerData")
        if familyData and familyData.family == familyID then
            table.insert(members, {
                name = getPlayerName(familyPlayer),
                rank = familyData.familyRank or 1,
                online = true
            })
        end
    end
    
    outputChatBox("👥 ===== FAMILY MEMBERS =====", player, 255, 255, 0)
    for _, member in ipairs(members) do
        local rankNames = {"Member", "Trusted", "Senior", "Co-Leader", "Leader"}
        local rankName = rankNames[member.rank] or "Member"
        outputChatBox(string.format("• %s - %s %s", member.name, rankName, member.online and "(Online)" or "(Offline)"), player, 255, 255, 255)
    end
end)

-- Promote in gang
addCommandHandler("gpromote", function(player, cmd, playerIdOrName)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.gang or playerData.gang <= 0 then
        outputChatBox("❌ Ban khong co gang.", player, 255, 100, 100)
        return
    end
    
    if (playerData.gangRank or 0) < 4 then
        outputChatBox("❌ Ban khong co quyen promote.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /gpromote [player_id]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.gang ~= playerData.gang then
        outputChatBox("❌ Nguoi choi khong cung gang.", player, 255, 100, 100)
        return
    end
    
    local currentRank = targetData.gangRank or 1
    if currentRank >= 5 then
        outputChatBox("❌ Nguoi choi da o rank cao nhat.", player, 255, 100, 100)
        return
    end
    
    if currentRank >= (playerData.gangRank or 0) then
        outputChatBox("❌ Ban khong the promote nguoi co rank cao hon ban.", player, 255, 100, 100)
        return
    end
    
    -- Promote
    targetData.gangRank = currentRank + 1
    setElementData(targetPlayer, "playerData", targetData)
    
    local rankNames = {"Member", "Soldier", "Captain", "Lieutenant", "Leader"}
    local newRankName = rankNames[targetData.gangRank] or "Member"
    
    outputChatBox(string.format("✅ Da promote %s len %s.", getPlayerName(targetPlayer), newRankName), player, 0, 255, 0)
    outputChatBox(string.format("🎉 Ban da duoc promote len %s!", newRankName), targetPlayer, 0, 255, 0)
end)

-- Gang territory system
addCommandHandler("gwar", function(player, cmd, action, targetGangID)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.gang or playerData.gang <= 0 then
        outputChatBox("❌ Ban khong co gang.", player, 255, 100, 100)
        return
    end
    
    if (playerData.gangRank or 0) < 4 then
        outputChatBox("❌ Ban khong co quyen declare war.", player, 255, 100, 100)
        return
    end
    
    if not action then
        outputChatBox("Su dung: /gwar [start/stop] [gang_id]", player, 255, 255, 255)
        return
    end
    
    if action == "start" then
        if not targetGangID then
            outputChatBox("Su dung: /gwar start [gang_id]", player, 255, 255, 255)
            return
        end
        
        local gangID = playerData.gang
        local targetGang = tonumber(targetGangID)
        
        if targetGang == gangID then
            outputChatBox("❌ Khong the war voi gang cua ban.", player, 255, 100, 100)
            return
        end
        
        -- Check if war already exists
        local currentWars = getElementData(getResourceRootElement(), "gangWars") or {}
        for _, war in ipairs(currentWars) do
            if (war.gang1 == gangID and war.gang2 == targetGang) or 
               (war.gang1 == targetGang and war.gang2 == gangID) then
                outputChatBox("❌ War da ton tai giua 2 gang nay.", player, 255, 100, 100)
                return
            end
        end
        
        -- Start war
        table.insert(currentWars, {
            gang1 = gangID,
            gang2 = targetGang,
            startTime = getRealTime().timestamp,
            score1 = 0,
            score2 = 0
        })
        setElementData(getResourceRootElement(), "gangWars", currentWars)
        
        -- Notify all players
        for _, p in ipairs(getElementsByType("player")) do
            local pData = getElementData(p, "playerData")
            if pData and (pData.gang == gangID or pData.gang == targetGang) then
                outputChatBox("⚔️ WAR DECLARED! Gang war has started!", p, 255, 0, 0)
            end
        end
        
        outputChatBox(string.format("⚔️ War declared voi gang %d!", targetGang), player, 255, 0, 0)
        
    elseif action == "stop" then
        local gangID = playerData.gang
        local currentWars = getElementData(getResourceRootElement(), "gangWars") or {}
        
        for i, war in ipairs(currentWars) do
            if war.gang1 == gangID or war.gang2 == gangID then
                table.remove(currentWars, i)
                setElementData(getResourceRootElement(), "gangWars", currentWars)
                
                -- Notify all players
                for _, p in ipairs(getElementsByType("player")) do
                    local pData = getElementData(p, "playerData")
                    if pData and (pData.gang == war.gang1 or pData.gang == war.gang2) then
                        outputChatBox("⚔️ Gang war has ended!", p, 255, 255, 0)
                    end
                end
                
                outputChatBox("✅ Gang war stopped.", player, 0, 255, 0)
                return
            end
        end
        
        outputChatBox("❌ Gang cua ban khong co war nao.", player, 255, 100, 100)
    end
end)

outputDebugString("[AMB] Gang/Family system loaded - 13 commands")
