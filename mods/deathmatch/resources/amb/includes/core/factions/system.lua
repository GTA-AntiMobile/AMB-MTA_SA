-- ================================
-- AMB MTA:SA - Faction & Organization Commands
-- Mass migration of faction and organization management commands
-- ================================

-- Faction creation and management
addCommandHandler("createfaction", function(player, cmd, factionName, ...)
    local playerData = getElementData(player, "playerData") or {}
    
    -- Admin level check
    if (playerData.adminLevel or 0) < 5 then
        outputChatBox("❌ Ban can admin level 5 de tao faction.", player, 255, 100, 100)
        return
    end
    
    if not factionName then
        outputChatBox("Su dung: /createfaction [name] [type] [color]", player, 255, 255, 255)
        outputChatBox("Types: police, medical, gang, government, business", player, 255, 255, 255)
        return
    end
    
    local args = {...}
    local factionType = args[1] or "gang"
    local factionColor = args[2] or "255,255,255"
    
    -- Validate faction type
    local validTypes = {police = true, medical = true, gang = true, government = true, business = true}
    if not validTypes[factionType] then
        outputChatBox("❌ Faction type khong hop le.", player, 255, 100, 100)
        return
    end
    
    -- Get next faction ID
    local factionID = getServerData("nextFactionID") or 1
    setServerData("nextFactionID", factionID + 1)
    
    -- Create faction data
    local factionData = {
        id = factionID,
        name = factionName,
        type = factionType,
        color = factionColor,
        leader = getPlayerName(player),
        members = {},
        money = 0,
        vehicles = {},
        properties = {},
        created = getRealTime().timestamp
    }
    
    -- Save faction
    setServerData("faction_" .. factionID, factionData)
    
    -- Add creator as leader
    playerData.faction = factionID
    playerData.factionRank = 10 -- Leader rank
    setElementData(player, "playerData", playerData)
    
    outputChatBox(string.format("✅ Da tao faction '%s' (ID: %d, Type: %s)", factionName, factionID, factionType), player, 0, 255, 0)
    outputChatBox(string.format("🏢 FACTION CREATED: %s [%s] by %s", factionName, factionType, getPlayerName(player)), root, 255, 255, 0)
end)

-- Join faction
addCommandHandler("invitef", function(player, cmd, targetName, factionID)
    if not targetName or not factionID then
        outputChatBox("Su dung: /invitef [player] [faction_id]", player, 255, 255, 255)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    local targetPlayer = getPlayerFromNameOrId(targetName)
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local factionData = getServerData("faction_" .. factionID)
    if not factionData then
        outputChatBox("❌ Faction khong ton tai.", player, 255, 100, 100)
        return
    end
    
    -- Check if player can invite (rank 8+)
    if playerData.faction ~= tonumber(factionID) or (playerData.factionRank or 0) < 8 then
        outputChatBox("❌ Ban khong co quyen moi nguoi vao faction nay.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.faction and targetData.faction > 0 then
        outputChatBox("❌ Nguoi choi da co faction roi.", player, 255, 100, 100)
        return
    end
    
    -- Send invitation
    setElementData(targetPlayer, "factionInvite", {
        factionID = tonumber(factionID),
        inviter = getPlayerName(player),
        factionName = factionData.name
    })
    
    outputChatBox(string.format("📨 Da gui loi moi vao faction '%s' cho %s.", factionData.name, getPlayerName(targetPlayer)), player, 0, 255, 0)
    outputChatBox(string.format("📨 %s moi ban vao faction '%s'. Su dung /acceptf hoac /declinef", getPlayerName(player), factionData.name), targetPlayer, 255, 255, 0)
end)

-- Accept faction invitation
addCommandHandler("acceptf", function(player)
    local invite = getElementData(player, "factionInvite")
    if not invite then
        outputChatBox("❌ Ban khong co loi moi faction nao.", player, 255, 100, 100)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    local factionData = getServerData("faction_" .. invite.factionID)
    
    if not factionData then
        outputChatBox("❌ Faction khong con ton tai.", player, 255, 100, 100)
        removeElementData(player, "factionInvite")
        return
    end
    
    -- Add to faction
    playerData.faction = invite.factionID
    playerData.factionRank = 1 -- Lowest rank
    setElementData(player, "playerData", playerData)
    
    -- Add to faction member list
    factionData.members[getPlayerName(player)] = {
        rank = 1,
        joined = getRealTime().timestamp
    }
    setServerData("faction_" .. invite.factionID, factionData)
    
    removeElementData(player, "factionInvite")
    
    outputChatBox(string.format("✅ Da gia nhap faction '%s'!", factionData.name), player, 0, 255, 0)
    
    -- Notify faction members
    for _, p in ipairs(getElementsByType("player")) do
        local pData = getElementData(p, "playerData") or {}
        if pData.faction == invite.factionID then
            outputChatBox(string.format("🏢 %s da gia nhap faction.", getPlayerName(player)), p, 255, 255, 0)
        end
    end
end)

-- Decline faction invitation
addCommandHandler("declinef", function(player)
    local invite = getElementData(player, "factionInvite")
    if not invite then
        outputChatBox("❌ Ban khong co loi moi faction nao.", player, 255, 100, 100)
        return
    end
    
    removeElementData(player, "factionInvite")
    outputChatBox("❌ Da tu choi loi moi faction.", player, 255, 255, 100)
end)

-- Leave faction
addCommandHandler("quitf", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.faction or playerData.faction <= 0 then
        outputChatBox("❌ Ban khong thuoc faction nao.", player, 255, 100, 100)
        return
    end
    
    if (playerData.factionRank or 0) >= 10 then
        outputChatBox("❌ Leader khong the roi faction. Su dung /transferleadership truoc.", player, 255, 100, 100)
        return
    end
    
    local factionData = getServerData("faction_" .. playerData.faction)
    if factionData then
        factionData.members[getPlayerName(player)] = nil
        setServerData("faction_" .. playerData.faction, factionData)
        
        -- Notify faction members
        for _, p in ipairs(getElementsByType("player")) do
            local pData = getElementData(p, "playerData") or {}
            if pData.faction == playerData.faction then
                outputChatBox(string.format("🏢 %s da roi faction.", getPlayerName(player)), p, 255, 255, 100)
            end
        end
    end
    
    playerData.faction = 0
    playerData.factionRank = 0
    setElementData(player, "playerData", playerData)
    
    outputChatBox("✅ Da roi faction.", player, 0, 255, 0)
end)

-- Kick from faction
addCommandHandler("kickf", function(player, cmd, targetName)
    if not targetName then
        outputChatBox("Su dung: /kickf [player]", player, 255, 255, 255)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    local targetPlayer = getPlayerFromNameOrId(targetName)
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    
    -- Check permissions
    if not playerData.faction or playerData.faction <= 0 then
        outputChatBox("❌ Ban khong thuoc faction nao.", player, 255, 100, 100)
        return
    end
    
    if playerData.faction ~= targetData.faction then
        outputChatBox("❌ Nguoi choi khong cung faction.", player, 255, 100, 100)
        return
    end
    
    if (playerData.factionRank or 0) <= (targetData.factionRank or 0) then
        outputChatBox("❌ Ban khong co quyen kick nguoi nay.", player, 255, 100, 100)
        return
    end
    
    local factionData = getServerData("faction_" .. playerData.faction)
    if factionData then
        factionData.members[getPlayerName(targetPlayer)] = nil
        setServerData("faction_" .. playerData.faction, factionData)
    end
    
    targetData.faction = 0
    targetData.factionRank = 0
    setElementData(targetPlayer, "playerData", targetData)
    
    outputChatBox(string.format("✅ Da kick %s khoi faction.", getPlayerName(targetPlayer)), player, 0, 255, 0)
    outputChatBox("❌ Ban da bi kick khoi faction.", targetPlayer, 255, 100, 100)
    
    -- Notify faction
    for _, p in ipairs(getElementsByType("player")) do
        local pData = getElementData(p, "playerData") or {}
        if pData.faction == playerData.faction and p ~= player and p ~= targetPlayer then
            outputChatBox(string.format("🏢 %s da bi kick boi %s.", getPlayerName(targetPlayer), getPlayerName(player)), p, 255, 255, 100)
        end
    end
end)

-- Faction rank system
addCommandHandler("setrank", function(player, cmd, targetName, rank)
    if not targetName or not rank then
        outputChatBox("Su dung: /setrank [player] [rank 1-9]", player, 255, 255, 255)
        return
    end
    
    local newRank = tonumber(rank)
    if not newRank or newRank < 1 or newRank > 9 then
        outputChatBox("❌ Rank phai tu 1-9.", player, 255, 100, 100)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    local targetPlayer = getPlayerFromNameOrId(targetName)
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    
    -- Check permissions
    if not playerData.faction or playerData.faction <= 0 then
        outputChatBox("❌ Ban khong thuoc faction nao.", player, 255, 100, 100)
        return
    end
    
    if playerData.faction ~= targetData.faction then
        outputChatBox("❌ Nguoi choi khong cung faction.", player, 255, 100, 100)
        return
    end
    
    if (playerData.factionRank or 0) < 9 then
        outputChatBox("❌ Ban can rank 9+ de set rank.", player, 255, 100, 100)
        return
    end
    
    if newRank >= (playerData.factionRank or 0) then
        outputChatBox("❌ Ban khong the set rank cao hon hoac bang rank cua ban.", player, 255, 100, 100)
        return
    end
    
    targetData.factionRank = newRank
    setElementData(targetPlayer, "playerData", targetData)
    
    -- Update faction data
    local factionData = getServerData("faction_" .. playerData.faction)
    if factionData and factionData.members[getPlayerName(targetPlayer)] then
        factionData.members[getPlayerName(targetPlayer)].rank = newRank
        setServerData("faction_" .. playerData.faction, factionData)
    end
    
    local rankNames = {
        [1] = "Newbie", [2] = "Member", [3] = "Senior", [4] = "Corporal", [5] = "Sergeant",
        [6] = "Lieutenant", [7] = "Captain", [8] = "High Command", [9] = "Deputy", [10] = "Leader"
    }
    
    outputChatBox(string.format("✅ Da set rank %s cho %s (Rank %d - %s).", newRank, getPlayerName(targetPlayer), newRank, rankNames[newRank]), player, 0, 255, 0)
    outputChatBox(string.format("📈 Rank cua ban da duoc set thanh %d (%s).", newRank, rankNames[newRank]), targetPlayer, 0, 255, 0)
end)

-- Faction online members
addCommandHandler("fonline", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.faction or playerData.faction <= 0 then
        outputChatBox("❌ Ban khong thuoc faction nao.", player, 255, 100, 100)
        return
    end
    
    local factionData = getServerData("faction_" .. playerData.faction)
    if not factionData then
        outputChatBox("❌ Faction data khong ton tai.", player, 255, 100, 100)
        return
    end
    
    outputChatBox(string.format("🏢 ===== %s ONLINE =====", string.upper(factionData.name)), player, 255, 255, 0)
    
    local onlineMembers = {}
    for _, p in ipairs(getElementsByType("player")) do
        local pData = getElementData(p, "playerData") or {}
        if pData.faction == playerData.faction then
            table.insert(onlineMembers, {
                name = getPlayerName(p),
                rank = pData.factionRank or 1
            })
        end
    end
    
    if #onlineMembers == 0 then
        outputChatBox("• Khong co thanh vien nao online.", player, 255, 255, 255)
    else
        -- Sort by rank
        table.sort(onlineMembers, function(a, b) return a.rank > b.rank end)
        
        local rankNames = {
            [1] = "Newbie", [2] = "Member", [3] = "Senior", [4] = "Corporal", [5] = "Sergeant",
            [6] = "Lieutenant", [7] = "Captain", [8] = "High Command", [9] = "Deputy", [10] = "Leader"
        }
        
        for _, member in ipairs(onlineMembers) do
            outputChatBox(string.format("• %s - %s (Rank %d)", member.name, rankNames[member.rank] or "Unknown", member.rank), player, 255, 255, 255)
        end
    end
    
    outputChatBox(string.format("Total: %d members online", #onlineMembers), player, 255, 255, 100)
end)

-- Faction chat
addCommandHandler("f", function(player, cmd, ...)
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /f [message]", player, 255, 255, 255)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.faction or playerData.faction <= 0 then
        outputChatBox("❌ Ban khong thuoc faction nao.", player, 255, 100, 100)
        return
    end
    
    local factionData = getServerData("faction_" .. playerData.faction)
    if not factionData then
        outputChatBox("❌ Faction data khong ton tai.", player, 255, 100, 100)
        return
    end
    
    local rankNames = {
        [1] = "Newbie", [2] = "Member", [3] = "Senior", [4] = "Corporal", [5] = "Sergeant",
        [6] = "Lieutenant", [7] = "Captain", [8] = "High Command", [9] = "Deputy", [10] = "Leader"
    }
    
    local rankName = rankNames[playerData.factionRank or 1] or "Unknown"
    local chatMessage = string.format("(( [%s] %s %s: %s ))", factionData.name, rankName, getPlayerName(player), message)
    
    -- Send to all faction members
    for _, p in ipairs(getElementsByType("player")) do
        local pData = getElementData(p, "playerData") or {}
        if pData.faction == playerData.faction then
            outputChatBox(chatMessage, p, 255, 255, 0)
        end
    end
end)

-- Faction info
addCommandHandler("finfo", function(player, cmd, factionID)
    local playerData = getElementData(player, "playerData") or {}
    
    if not factionID then
        factionID = playerData.faction
    else
        factionID = tonumber(factionID)
    end
    
    if not factionID or factionID <= 0 then
        outputChatBox("Su dung: /finfo [faction_id] hoac /finfo (faction cua ban)", player, 255, 255, 255)
        return
    end
    
    local factionData = getServerData("faction_" .. factionID)
    if not factionData then
        outputChatBox("❌ Faction khong ton tai.", player, 255, 100, 100)
        return
    end
    
    outputChatBox(string.format("🏢 ===== %s INFO =====", string.upper(factionData.name)), player, 255, 255, 0)
    outputChatBox(string.format("• ID: %d", factionData.id), player, 255, 255, 255)
    outputChatBox(string.format("• Type: %s", factionData.type), player, 255, 255, 255)
    outputChatBox(string.format("• Leader: %s", factionData.leader), player, 255, 255, 255)
    outputChatBox(string.format("• Money: $%d", factionData.money or 0), player, 255, 255, 255)
    outputChatBox(string.format("• Members: %d", getTableSize(factionData.members or {})), player, 255, 255, 255)
    outputChatBox(string.format("• Vehicles: %d", #(factionData.vehicles or {})), player, 255, 255, 255)
    outputChatBox(string.format("• Properties: %d", #(factionData.properties or {})), player, 255, 255, 255)
    
    local createdDate = os.date("%d/%m/%Y", factionData.created or 0)
    outputChatBox(string.format("• Created: %s", createdDate), player, 255, 255, 255)
end)

-- Transfer leadership
addCommandHandler("transferleadership", function(player, cmd, targetName)
    if not targetName then
        outputChatBox("Su dung: /transferleadership [player]", player, 255, 255, 255)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    local targetPlayer = getPlayerFromNameOrId(targetName)
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    
    -- Check if current player is leader
    if not playerData.faction or playerData.faction <= 0 or (playerData.factionRank or 0) < 10 then
        outputChatBox("❌ Ban khong phai leader cua faction nao.", player, 255, 100, 100)
        return
    end
    
    if playerData.faction ~= targetData.faction then
        outputChatBox("❌ Nguoi choi khong cung faction.", player, 255, 100, 100)
        return
    end
    
    if targetPlayer == player then
        outputChatBox("❌ Ban khong the transfer cho chinh minh.", player, 255, 100, 100)
        return
    end
    
    -- Transfer leadership
    playerData.factionRank = 9 -- Deputy
    targetData.factionRank = 10 -- Leader
    
    setElementData(player, "playerData", playerData)
    setElementData(targetPlayer, "playerData", targetData)
    
    -- Update faction data
    local factionData = getServerData("faction_" .. playerData.faction)
    if factionData then
        factionData.leader = getPlayerName(targetPlayer)
        if factionData.members[getPlayerName(player)] then
            factionData.members[getPlayerName(player)].rank = 9
        end
        if factionData.members[getPlayerName(targetPlayer)] then
            factionData.members[getPlayerName(targetPlayer)].rank = 10
        end
        setServerData("faction_" .. playerData.faction, factionData)
    end
    
    outputChatBox(string.format("✅ Da transfer leadership cho %s.", getPlayerName(targetPlayer)), player, 0, 255, 0)
    outputChatBox("🏆 Ban da tro thanh leader cua faction!", targetPlayer, 0, 255, 0)
    
    -- Notify all faction members
    for _, p in ipairs(getElementsByType("player")) do
        local pData = getElementData(p, "playerData") or {}
        if pData.faction == playerData.faction and p ~= player and p ~= targetPlayer then
            outputChatBox(string.format("🏢 %s da transfer leadership cho %s.", getPlayerName(player), getPlayerName(targetPlayer)), p, 255, 255, 0)
        end
    end
end)

-- Helper function to get table size
function getTableSize(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

-- Helper function to get server data
function getServerData(key)
    return getElementData(getResourceRootElement(), key)
end

-- Helper function to set server data
function setServerData(key, value)
    setElementData(getResourceRootElement(), key, value)
end

outputDebugString("[AMB] Faction & Organization system loaded - 12 commands")
