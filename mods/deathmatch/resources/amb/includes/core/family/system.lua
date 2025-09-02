-- ================================
-- AMB MTA:SA - Family/Gang System
-- Gang management and warfare
-- ================================

-- Family/Gang data structure
local families = {}
local familyWars = {}

-- Family ranks
local familyRanks = {
    [0] = "Associate",
    [1] = "Soldier",
    [2] = "Lieutenant",
    [3] = "Captain",
    [4] = "Underboss",
    [5] = "Boss"
}

-- Default families
local defaultFamilies = {
    ["Grove Street"] = {
        color = { 0, 255, 0 },
        spawn = { 2495.1, -1687.4, 13.5 },
        territory = { { 2400, -1800, 2600, -1600 } },
        maxMembers = 25,
        vehicles = { 567, 536, 575, 534 },  -- Savanna, Blade, Broadway, Remington
        weapons = { 22, 24, 25, 28, 30, 31 }, -- Pistol, Deagle, Shotgun, Uzi, AK, M4
        headquarters = { 2495.1, -1687.4, 13.5 }
    },
    ["Ballas"] = {
        color = { 255, 0, 255 },
        spawn = { 2000.8, -1114.4, 26.6 },
        territory = { { 1900, -1200, 2100, -1000 } },
        maxMembers = 25,
        vehicles = { 567, 536, 575, 534 },
        weapons = { 22, 24, 25, 28, 30, 31 },
        headquarters = { 2000.8, -1114.4, 26.6 }
    },
    ["Vagos"] = {
        color = { 255, 255, 0 },
        spawn = { 2787.8, -1926.1, 13.5 },
        territory = { { 2700, -2000, 2900, -1800 } },
        maxMembers = 25,
        vehicles = { 567, 536, 575, 534 },
        weapons = { 22, 24, 25, 28, 30, 31 },
        headquarters = { 2787.8, -1926.1, 13.5 }
    },
    ["Aztecas"] = {
        color = { 0, 255, 255 },
        spawn = { 1672.1, -2335.0, 13.5 },
        territory = { { 1600, -2400, 1800, -2200 } },
        maxMembers = 25,
        vehicles = { 567, 536, 575, 534 },
        weapons = { 22, 24, 25, 28, 30, 31 },
        headquarters = { 1672.1, -2335.0, 13.5 }
    }
}

-- Create a family
function createFamily(name, leader, color)
    if families[name] then return false end

    families[name] = {
        name = name,
        leader = leader,
        members = { [leader] = 5 }, -- Leader starts as Boss (rank 5)
        color = color or { 255, 255, 255 },
        money = 0,
        created = getRealTime().timestamp,
        territory = {},
        vehicles = {},
        headquarters = nil,
        maxMembers = 15
    }

    -- Set player family
    setElementData(getPlayerFromName(leader), "family", name)
    setElementData(getPlayerFromName(leader), "familyRank", 5)

    return true
end

-- Invite player to family
function invitePlayerToFamily(family, player, inviter)
    if not families[family] then return false end
    if families[family].members[player] then return false end
    if table.count(families[family].members) >= families[family].maxMembers then return false end

    -- Check if inviter has permission (rank 3+)
    local inviterRank = families[family].members[inviter] or 0
    if inviterRank < 3 then return false end

    families[family].members[player] = 0 -- Start as Associate
    setElementData(getPlayerFromName(player), "family", family)
    setElementData(getPlayerFromName(player), "familyRank", 0)

    return true
end

-- Remove player from family
function removePlayerFromFamily(family, player, remover)
    if not families[family] then return false end
    if not families[family].members[player] then return false end

    -- Check permissions
    local removerRank = families[family].members[remover] or 0
    local playerRank = families[family].members[player] or 0

    if remover ~= player and removerRank <= playerRank then return false end
    if families[family].leader == player then return false end -- Can't remove leader

    families[family].members[player] = nil
    local playerElement = getPlayerFromName(player)
    if playerElement then
        setElementData(playerElement, "family", nil)
        setElementData(playerElement, "familyRank", nil)
    end

    return true
end

-- Get player's family
function getPlayerFamily(player)
    return getElementData(player, "family")
end

-- Get player's family rank
function getPlayerFamilyRank(player)
    return getElementData(player, "familyRank") or 0
end

-- Family command: /families
addCommandHandler("families", function(player)
    outputChatBox(COLOR_YELLOW .. "=== Active Families ===", player)
    local count = 0
    for name, data in pairs(families) do
        count = count + 1
        local memberCount = table.count(data.members)
        outputChatBox(
        COLOR_WHITE .. count .. ". " .. name .. " (Leader: " .. data.leader .. ", Members: " .. memberCount .. ")",
            player)
    end
    if count == 0 then
        outputChatBox(COLOR_GRAY .. "No families found.", player)
    end
end)

-- Family command: /fam
addCommandHandler("fam", function(player, _, ...)
    local family = getPlayerFamily(player)
    if not family then
        outputChatBox(COLOR_RED .. "You are not in a family!", player)
        return
    end

    local message = table.concat({ ... }, " ")
    if not message or #message == 0 then
        outputChatBox(COLOR_YELLOW .. "Usage: /fam [message]", player)
        return
    end

    local playerName = getPlayerName(player)
    local rank = getPlayerFamilyRank(player)
    local rankName = familyRanks[rank] or "Unknown"

    local chatMessage = COLOR_GREEN .. "[FAMILY] " .. COLOR_WHITE .. rankName .. " " .. playerName .. ": " .. message

    -- Send to all family members
    for memberName, _ in pairs(families[family].members) do
        local member = getPlayerFromName(memberName)
        if member then
            outputChatBox(chatMessage, member)
        end
    end
end)

-- Family command: /finvite
addCommandHandler("finvite", function(player, _, playerIdOrName)
    local family = getPlayerFamily(player)
    if not family then
        outputChatBox(COLOR_RED .. "You are not in a family!", player)
        return
    end

    local rank = getPlayerFamilyRank(player)
    if rank < 3 then
        outputChatBox(COLOR_RED .. "You need to be at least Captain rank to invite members!", player)
        return
    end

    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /finvite [player]", player)
        return
    end

    local target = getPlayerFromPartialName(playerIdOrName)
    if not target then
        outputChatBox(COLOR_RED .. "Player not found!", player)
        return
    end

    if getPlayerFamily(target) then
        outputChatBox(COLOR_RED .. "This player is already in a family!", player)
        return
    end

    if invitePlayerToFamily(family, getPlayerName(target), getPlayerName(player)) then
        outputChatBox(COLOR_GREEN .. "You invited " .. getPlayerName(target) .. " to " .. family .. ".", player)
        outputChatBox(COLOR_GREEN .. "You have been invited to " .. family .. " by " .. getPlayerName(player) .. ".",
            target)
        outputChatBox(COLOR_GREEN .. "Welcome to the family!", target)

        -- Notify family
        local message = COLOR_YELLOW ..
        getPlayerName(target) .. " has joined the family (invited by " .. getPlayerName(player) .. ")"
        for memberName, _ in pairs(families[family].members) do
            local member = getPlayerFromName(memberName)
            if member and member ~= target then
                outputChatBox(message, member)
            end
        end
    else
        outputChatBox(COLOR_RED .. "Failed to invite player. Family might be full.", player)
    end
end)

-- Family command: /fkick
addCommandHandler("fkick", function(player, _, playerIdOrName)
    local family = getPlayerFamily(player)
    if not family then
        outputChatBox(COLOR_RED .. "You are not in a family!", player)
        return
    end

    local rank = getPlayerFamilyRank(player)
    if rank < 3 then
        outputChatBox(COLOR_RED .. "You need to be at least Captain rank to kick members!", player)
        return
    end

    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /fkick [player]", player)
        return
    end

    local target = getPlayerFromPartialName(playerIdOrName)
    if target then
        playerIdOrName = getPlayerName(target)
    end

    if not families[family].members[playerIdOrName] then
        outputChatBox(COLOR_RED .. "This player is not in your family!", player)
        return
    end

    if removePlayerFromFamily(family, playerIdOrName, getPlayerName(player)) then
        outputChatBox(COLOR_GREEN .. "You kicked " .. playerIdOrName .. " from the family.", player)
        if target then
            outputChatBox(COLOR_RED .. "You have been kicked from " .. family .. " by " .. getPlayerName(player) .. ".",
                target)
        end

        -- Notify family
        local message = COLOR_YELLOW .. playerIdOrName .. " has been kicked from the family by " .. getPlayerName(player)
        for memberName, _ in pairs(families[family].members) do
            local member = getPlayerFromName(memberName)
            if member and member ~= target then
                outputChatBox(message, member)
            end
        end
    else
        outputChatBox(COLOR_RED .. "You cannot kick this member!", player)
    end
end)

-- Family command: /fquit
addCommandHandler("fquit", function(player)
    local family = getPlayerFamily(player)
    if not family then
        outputChatBox(COLOR_RED .. "You are not in a family!", player)
        return
    end

    if families[family].leader == getPlayerName(player) then
        outputChatBox(COLOR_RED .. "You cannot quit as the family leader! Transfer leadership first.", player)
        return
    end

    if removePlayerFromFamily(family, getPlayerName(player), getPlayerName(player)) then
        outputChatBox(COLOR_GREEN .. "You left " .. family .. ".", player)

        -- Notify family
        local message = COLOR_YELLOW .. getPlayerName(player) .. " left the family"
        for memberName, _ in pairs(families[family].members) do
            local member = getPlayerFromName(memberName)
            if member then
                outputChatBox(message, member)
            end
        end
    end
end)

-- Family command: /fmembers
addCommandHandler("fmembers", function(player)
    local family = getPlayerFamily(player)
    if not family then
        outputChatBox(COLOR_RED .. "You are not in a family!", player)
        return
    end

    outputChatBox(COLOR_YELLOW .. "=== " .. family .. " Members ===", player)
    local count = 0
    for memberName, rank in pairs(families[family].members) do
        count = count + 1
        local rankName = familyRanks[rank] or "Unknown"
        local status = "Offline"
        if getPlayerFromName(memberName) then
            status = "Online"
        end
        outputChatBox(COLOR_WHITE .. count .. ". " .. memberName .. " (" .. rankName .. ") - " .. status, player)
    end
end)

-- Family command: /fpromote
addCommandHandler("fpromote", function(player, _, playerIdOrName)
    local family = getPlayerFamily(player)
    if not family then
        outputChatBox(COLOR_RED .. "You are not in a family!", player)
        return
    end

    if families[family].leader ~= getPlayerName(player) then
        outputChatBox(COLOR_RED .. "Only the family leader can promote members!", player)
        return
    end

    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /fpromote [player]", player)
        return
    end

    local target = getPlayerFromPartialName(playerIdOrName)
    if target then
        playerIdOrName = getPlayerName(target)
    end

    if not families[family].members[playerIdOrName] then
        outputChatBox(COLOR_RED .. "This player is not in your family!", player)
        return
    end

    local currentRank = families[family].members[playerIdOrName]
    if currentRank >= 4 then
        outputChatBox(COLOR_RED .. "This player is already at maximum rank!", player)
        return
    end

    families[family].members[playerIdOrName] = currentRank + 1
    if target then
        setElementData(target, "familyRank", currentRank + 1)
    end

    local newRankName = familyRanks[currentRank + 1]
    outputChatBox(COLOR_GREEN .. "You promoted " .. playerIdOrName .. " to " .. newRankName .. ".", player)
    if target then
        outputChatBox(
        COLOR_GREEN .. "You have been promoted to " .. newRankName .. " by " .. getPlayerName(player) .. ".", target)
    end
end)

-- Family command: /fdemote
addCommandHandler("fdemote", function(player, _, playerIdOrName)
    local family = getPlayerFamily(player)
    if not family then
        outputChatBox(COLOR_RED .. "You are not in a family!", player)
        return
    end

    if families[family].leader ~= getPlayerName(player) then
        outputChatBox(COLOR_RED .. "Only the family leader can demote members!", player)
        return
    end

    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /fdemote [player]", player)
        return
    end

    local target = getPlayerFromPartialName(playerIdOrName)
    if target then
        playerIdOrName = getPlayerName(target)
    end

    if not families[family].members[playerIdOrName] then
        outputChatBox(COLOR_RED .. "This player is not in your family!", player)
        return
    end

    local currentRank = families[family].members[playerIdOrName]
    if currentRank <= 0 then
        outputChatBox(COLOR_RED .. "This player is already at minimum rank!", player)
        return
    end

    families[family].members[playerIdOrName] = currentRank - 1
    if target then
        setElementData(target, "familyRank", currentRank - 1)
    end

    local newRankName = familyRanks[currentRank - 1]
    outputChatBox(COLOR_GREEN .. "You demoted " .. playerIdOrName .. " to " .. newRankName .. ".", player)
    if target then
        outputChatBox(
        COLOR_ORANGE .. "You have been demoted to " .. newRankName .. " by " .. getPlayerName(player) .. ".", target)
    end
end)

-- Family command: /fwar
addCommandHandler("fwar", function(player, _, targetFamily)
    local family = getPlayerFamily(player)
    if not family then
        outputChatBox(COLOR_RED .. "You are not in a family!", player)
        return
    end

    local rank = getPlayerFamilyRank(player)
    if rank < 4 then
        outputChatBox(COLOR_RED .. "You need to be at least Underboss rank to declare war!", player)
        return
    end

    if not targetFamily then
        outputChatBox(COLOR_YELLOW .. "Usage: /fwar [family name]", player)
        return
    end

    if not families[targetFamily] then
        outputChatBox(COLOR_RED .. "Family not found!", player)
        return
    end

    if targetFamily == family then
        outputChatBox(COLOR_RED .. "You cannot declare war on your own family!", player)
        return
    end

    if familyWars[family] and familyWars[family][targetFamily] then
        outputChatBox(COLOR_RED .. "You are already at war with " .. targetFamily .. "!", player)
        return
    end

    -- Initialize war data
    if not familyWars[family] then familyWars[family] = {} end
    if not familyWars[targetFamily] then familyWars[targetFamily] = {} end

    familyWars[family][targetFamily] = {
        started = getRealTime().timestamp,
        kills = { [family] = 0, [targetFamily] = 0 }
    }
    familyWars[targetFamily][family] = familyWars[family][targetFamily]

    -- Notify both families
    local warMessage = COLOR_RED .. "WAR DECLARED! " .. COLOR_WHITE .. family .. " vs " .. targetFamily
    for _, fam in ipairs({ family, targetFamily }) do
        for memberName, _ in pairs(families[fam].members) do
            local member = getPlayerFromName(memberName)
            if member then
                outputChatBox(warMessage, member)
            end
        end
    end

    outputChatBox(COLOR_GREEN .. "You declared war on " .. targetFamily .. "!", player)
end)

-- Initialize default families on resource start
addEventHandler("onResourceStart", resourceRoot, function()
    for name, data in pairs(defaultFamilies) do
        local team = createTeam(name, data.color[1], data.color[2], data.color[3])
        if team then
            print("Created family team: " .. name)
        end
    end
end)

outputDebugString("[AMB] Family System loaded successfully!")
