-- ================================
-- AMB MTA:SA - Police System
-- Police commands and functionality
-- ================================

-- Police team/faction data
local policeTeams = {
    ["LSPD"] = {
        name = "Los Santos Police Department",
        color = {0, 0, 255},
        vehicles = {596, 597, 598, 599, 427, 523}, -- Police cars, bikes
        weapons = {3, 22, 23, 24, 25, 29, 31}, -- Nightstick, pistol, silenced, deagle, shotgun, MP5, M4
        headquarters = {1554.8, -1675.6, 16.2},
        garage = {1588.2, -1638.1, 13.5}
    },
    ["SFPD"] = {
        name = "San Fierro Police Department",
        color = {0, 0, 255},
        vehicles = {596, 597, 598, 599, 427, 523},
        weapons = {3, 22, 23, 24, 25, 29, 31},
        headquarters = {-2451.2, 503.4, 30.0},
        garage = {-2425.1, 523.7, 29.9}
    },
    ["LVPD"] = {
        name = "Las Venturas Police Department",
        color = {0, 0, 255},
        vehicles = {596, 597, 598, 599, 427, 523},
        weapons = {3, 22, 23, 24, 25, 29, 31},
        headquarters = {2275.3, 2477.8, 10.8},
        garage = {2312.1, 2456.9, 3.2}
    }
}

-- Police ranks
local policeRanks = {
    [0] = "Cadet",
    [1] = "Officer",
    [2] = "Corporal", 
    [3] = "Sergeant",
    [4] = "Lieutenant",
    [5] = "Captain",
    [6] = "Chief"
}

-- Arrest system
function arrestPlayer(cop, suspect, reason, time)
    if not isElement(cop) or not isElement(suspect) then return false end
    if not isPlayerCop(cop) then return false end
    if getElementData(suspect, "arrested") then return false end
    
    time = time or 300 -- 5 minutes default
    reason = reason or "No reason specified"
    
    -- Set arrest data
    setElementData(suspect, "arrested", true)
    setElementData(suspect, "arrestTime", time)
    setElementData(suspect, "arrestReason", reason)
    setElementData(suspect, "arrestedBy", getPlayerName(cop))
    
    -- Teleport to jail
    local jailPos = getJailPosition()
    setElementPosition(suspect, jailPos.x, jailPos.y, jailPos.z)
    setElementInterior(suspect, jailPos.interior)
    setElementDimension(suspect, jailPos.dimension)
    
    -- Remove weapons
    takeAllWeapons(suspect)
    
    -- Start timer
    setTimer(function()
        if isElement(suspect) and getElementData(suspect, "arrested") then
            releasePlayer(suspect)
        end
    end, time * 1000, 1)
    
    -- Notifications
    outputChatBox(COLOR_ORANGE .. "You have been arrested by " .. getPlayerName(cop) .. " for: " .. reason, suspect)
    outputChatBox(COLOR_ORANGE .. "Jail time: " .. time .. " seconds", suspect)
    outputChatBox(COLOR_GREEN .. "You arrested " .. getPlayerName(suspect) .. " for: " .. reason, cop)
    
    -- Log action
    logPoliceAction(cop, "arrest", getPlayerName(suspect), reason .. " (" .. time .. "s)")
    
    return true
end

-- Release player from jail
function releasePlayer(player)
    if not isElement(player) then return false end
    if not getElementData(player, "arrested") then return false end
    
    -- Remove arrest data
    setElementData(player, "arrested", false)
    setElementData(player, "arrestTime", nil)
    setElementData(player, "arrestReason", nil)
    setElementData(player, "arrestedBy", nil)
    
    -- Teleport to hospital
    local hospitalPos = {1172.0, -1323.4, 15.4, 270}
    setElementPosition(player, hospitalPos[1], hospitalPos[2], hospitalPos[3])
    setElementRotation(player, 0, 0, hospitalPos[4])
    setElementInterior(player, 0)
    setElementDimension(player, 0)
    
    outputChatBox(COLOR_GREEN .. "You have been released from jail.", player)
    return true
end

-- Check if player is a cop
function isPlayerCop(player)
    if not isElement(player) then return false end
    local team = getPlayerTeam(player)
    if not team then return false end
    local teamName = getTeamName(team)
    return policeTeams[teamName] ~= nil
end

-- Get jail position
function getJailPosition()
    return {
        x = 264.3,
        y = 77.5,
        z = 1001.0,
        interior = 6,
        dimension = 1
    }
end

-- Police command: /arrest
addCommandHandler("arrest", function(player, _, playerIdOrName, time, ...)
    if not isPlayerCop(player) then
        outputChatBox(COLOR_RED .. "You are not a police officer!", player)
        return
    end
    
    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /arrest [player] [time] [reason]", player)
        return
    end
    
    local target = getPlayerFromPartialName(playerIdOrName)
    if not target then
        outputChatBox(COLOR_RED .. "Player not found!", player)
        return
    end
    
    if target == player then
        outputChatBox(COLOR_RED .. "You cannot arrest yourself!", player)
        return
    end
    
    time = tonumber(time) or 300
    local reason = table.concat({...}, " ") or "No reason specified"
    
    if time < 60 or time > 3600 then
        outputChatBox(COLOR_RED .. "Arrest time must be between 60 and 3600 seconds!", player)
        return
    end
    
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(target)
    
    if getDistance3D(px, py, pz, tx, ty, tz) > 10 then
        outputChatBox(COLOR_RED .. "You must be close to the player to arrest them!", player)
        return
    end
    
    if arrestPlayer(player, target, reason, time) then
        sendMessageToTeam(getPlayerTeam(player), COLOR_BLUE .. getPlayerName(player) .. " arrested " .. getPlayerName(target) .. " (" .. reason .. ")")
    end
end)

-- Police command: /release
addCommandHandler("release", function(player, _, playerIdOrName)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) and not isPlayerCop(player) then
        outputChatBox(COLOR_RED .. "You don't have permission to use this command!", player)
        return
    end
    
    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /release [player]", player)
        return
    end
    
    local target = getPlayerFromPartialName(playerIdOrName)
    if not target then
        outputChatBox(COLOR_RED .. "Player not found!", player)
        return
    end
    
    if not getElementData(target, "arrested") then
        outputChatBox(COLOR_RED .. "This player is not arrested!", player)
        return
    end
    
    if releasePlayer(target) then
        outputChatBox(COLOR_GREEN .. "You released " .. getPlayerName(target) .. " from jail.", player)
        logPoliceAction(player, "release", getPlayerName(target), "Released from jail")
    end
end)

-- Police command: /wanted
addCommandHandler("wanted", function(player, _, playerIdOrName, level, ...)
    if not isPlayerCop(player) then
        outputChatBox(COLOR_RED .. "You are not a police officer!", player)
        return
    end
    
    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /wanted [player] [level 1-6] [reason]", player)
        return
    end
    
    local target = getPlayerFromPartialName(playerIdOrName)
    if not target then
        outputChatBox(COLOR_RED .. "Player not found!", player)
        return
    end
    
    level = tonumber(level) or 1
    if level < 1 or level > 6 then
        outputChatBox(COLOR_RED .. "Wanted level must be between 1 and 6!", player)
        return
    end
    
    local reason = table.concat({...}, " ") or "Criminal activity"
    
    setPlayerWantedLevel(target, level)
    setElementData(target, "wantedReason", reason)
    setElementData(target, "wantedBy", getPlayerName(player))
    
    outputChatBox(COLOR_ORANGE .. "You have been given wanted level " .. level .. " by " .. getPlayerName(player), target)
    outputChatBox(COLOR_ORANGE .. "Reason: " .. reason, target)
    outputChatBox(COLOR_GREEN .. "You gave " .. getPlayerName(target) .. " wanted level " .. level, player)
    
    sendMessageToTeam(getPlayerTeam(player), COLOR_BLUE .. getPlayerName(target) .. " is now wanted (Level " .. level .. ") - " .. reason)
    logPoliceAction(player, "wanted", getPlayerName(target), "Level " .. level .. " - " .. reason)
end)

-- Police command: /unwanted
addCommandHandler("unwanted", function(player, _, playerIdOrName)
    if not isPlayerCop(player) then
        outputChatBox(COLOR_RED .. "You are not a police officer!", player)
        return
    end
    
    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /unwanted [player]", player)
        return
    end
    
    local target = getPlayerFromPartialName(playerIdOrName)
    if not target then
        outputChatBox(COLOR_RED .. "Player not found!", player)
        return
    end
    
    if getPlayerWantedLevel(target) == 0 then
        outputChatBox(COLOR_RED .. "This player is not wanted!", player)
        return
    end
    
    setPlayerWantedLevel(target, 0)
    setElementData(target, "wantedReason", nil)
    setElementData(target, "wantedBy", nil)
    
    outputChatBox(COLOR_GREEN .. "Your wanted level has been cleared by " .. getPlayerName(player), target)
    outputChatBox(COLOR_GREEN .. "You cleared " .. getPlayerName(target) .. "'s wanted level.", player)
    
    logPoliceAction(player, "unwanted", getPlayerName(target), "Wanted level cleared")
end)

-- Police command: /ticket
addCommandHandler("ticket", function(player, _, playerIdOrName, amount, ...)
    if not isPlayerCop(player) then
        outputChatBox(COLOR_RED .. "You are not a police officer!", player)
        return
    end
    
    if not playerIdOrName or not amount then
        outputChatBox(COLOR_YELLOW .. "Usage: /ticket [player] [amount] [reason]", player)
        return
    end
    
    local target = getPlayerFromPartialName(playerIdOrName)
    if not target then
        outputChatBox(COLOR_RED .. "Player not found!", player)
        return
    end
    
    amount = tonumber(amount)
    if not amount or amount < 50 or amount > 50000 then
        outputChatBox(COLOR_RED .. "Ticket amount must be between $50 and $50,000!", player)
        return
    end
    
    local reason = table.concat({...}, " ") or "Traffic violation"
    local playerMoney = getPlayerMoney(target)
    
    if playerMoney < amount then
        outputChatBox(COLOR_RED .. "Player doesn't have enough money for this ticket!", player)
        return
    end
    
    takePlayerMoney(target, amount)
    givePlayerMoney(player, math.floor(amount * 0.1)) -- 10% commission for cop
    
    outputChatBox(COLOR_ORANGE .. "You received a ticket of $" .. formatMoney(amount) .. " from " .. getPlayerName(player), target)
    outputChatBox(COLOR_ORANGE .. "Reason: " .. reason, target)
    outputChatBox(COLOR_GREEN .. "You issued a $" .. formatMoney(amount) .. " ticket to " .. getPlayerName(target), player)
    
    logPoliceAction(player, "ticket", getPlayerName(target), "$" .. formatMoney(amount) .. " - " .. reason)
end)

-- Police command: /backup
addCommandHandler("backup", function(player, _, ...)
    if not isPlayerCop(player) then
        outputChatBox(COLOR_RED .. "You are not a police officer!", player)
        return
    end
    
    local message = table.concat({...}, " ")
    if not message or #message == 0 then
        outputChatBox(COLOR_YELLOW .. "Usage: /backup [message]", player)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local zone = getZoneName(x, y, z)
    
    local backupMsg = COLOR_RED .. "[BACKUP REQUESTED] " .. COLOR_WHITE .. getPlayerName(player) .. " at " .. zone .. ": " .. message
    
    -- Send to all police officers
    for _, p in ipairs(getElementsByType("player")) do
        if isPlayerCop(p) then
            outputChatBox(backupMsg, p)
            -- Create blip for backup location
            local blip = createBlip(x, y, z, 41, 2, 255, 0, 0, 255, 0, 99999, p)
            setTimer(destroyElement, 30000, 1, blip) -- Remove blip after 30 seconds
        end
    end
    
    logPoliceAction(player, "backup", "ALL", message .. " at " .. zone)
end)

-- Police command: /tazer
addCommandHandler("tazer", function(player, _, playerIdOrName)
    if not isPlayerCop(player) then
        outputChatBox(COLOR_RED .. "You are not a police officer!", player)
        return
    end
    
    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /tazer [player]", player)
        return
    end
    
    local target = getPlayerFromPartialName(playerIdOrName)
    if not target then
        outputChatBox(COLOR_RED .. "Player not found!", player)
        return
    end
    
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(target)
    
    if getDistance3D(px, py, pz, tx, ty, tz) > 5 then
        outputChatBox(COLOR_RED .. "You must be close to the player to taze them!", player)
        return
    end
    
    if getElementData(target, "tazed") then
        outputChatBox(COLOR_RED .. "This player is already tazed!", player)
        return
    end
    
    -- Taze effect
    setElementData(target, "tazed", true)
    setElementFrozen(target, true)
    
    outputChatBox(COLOR_YELLOW .. "You have been tazed by " .. getPlayerName(player) .. "!", target)
    outputChatBox(COLOR_GREEN .. "You tazed " .. getPlayerName(target) .. ".", player)
    
    -- Remove taze effect after 5 seconds
    setTimer(function()
        if isElement(target) then
            setElementData(target, "tazed", false)
            setElementFrozen(target, false)
            outputChatBox(COLOR_GREEN .. "You can move again.", target)
        end
    end, 5000, 1)
    
    logPoliceAction(player, "tazer", getPlayerName(target), "Player tazed")
end)

-- Utility functions
function sendMessageToTeam(team, message)
    if not team then return end
    for _, player in ipairs(getPlayersInTeam(team)) do
        outputChatBox(message, player)
    end
end

function logPoliceAction(cop, action, target, details)
    local logData = {
        cop = getPlayerName(cop),
        copSerial = getPlayerSerial(cop),
        action = action,
        target = target,
        details = details,
        timestamp = getRealTime().timestamp
    }
    
    print("[POLICE LOG] " .. getPlayerName(cop) .. " used " .. action .. " on " .. target .. " - " .. details)
end

-- Initialize police teams
addEventHandler("onResourceStart", resourceRoot, function()
    for teamName, teamData in pairs(policeTeams) do
        local team = createTeam(teamName, teamData.color[1], teamData.color[2], teamData.color[3])
        if team then
            print("Created police team: " .. teamName)
        end
    end
end)

outputDebugString("[AMB] Police System loaded successfully!")
