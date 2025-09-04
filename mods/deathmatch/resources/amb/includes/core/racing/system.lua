-- ================================
-- AMB MTA:SA - Racing & Sports Commands
-- Mass migration of racing and sports commands
-- ================================

-- Start race
addCommandHandler("startrace", function(player, cmd, raceType, bet)
    local playerData = getElementData(player, "playerData") or {}
    
    if not raceType then
        outputChatBox("Su dung: /startrace [street/drag/circuit] [bet_amount]", player, 255, 255, 255)
        return
    end
    
    if playerData.inRace then
        outputChatBox("❌ Ban da o trong race roi.", player, 255, 100, 100)
        return
    end
    
    local betAmount = tonumber(bet) or 0
    if betAmount > 0 and (playerData.money or 0) < betAmount then
        outputChatBox("❌ Ban khong co du tien de bet.", player, 255, 100, 100)
        return
    end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban can o trong xe de start race.", player, 255, 100, 100)
        return
    end
    
    -- Create race
    local raceID = getRealTime().timestamp
    local races = getElementData(getResourceRootElement(), "activeRaces") or {}
    
    races[raceID] = {
        creator = player,
        type = raceType,
        bet = betAmount,
        participants = {player},
        status = "waiting",
        startTime = nil,
        checkpoints = {},
        laps = 1
    }
    
    setElementData(getResourceRootElement(), "activeRaces", races)
    
    playerData.inRace = raceID
    playerData.racePosition = 1
    setElementData(player, "playerData", playerData)
    
    outputChatBox(string.format("🏁 Da tao %s race voi bet $%d. Cho nguoi khac join.", raceType, betAmount), player, 255, 255, 0)
    
    -- Notify other players
    for _, otherPlayer in ipairs(getElementsByType("player")) do
        if otherPlayer ~= player then
            outputChatBox(string.format("🏁 %s da tao %s race ($%d bet). Su dung /joinrace %d", 
                getPlayerName(player), raceType, betAmount, raceID), otherPlayer, 255, 255, 100)
        end
    end
end)

-- Join race
addCommandHandler("joinrace", function(player, cmd, raceID)
    local playerData = getElementData(player, "playerData") or {}
    
    if not raceID then
        outputChatBox("Su dung: /joinrace [race_id]", player, 255, 255, 255)
        return
    end
    
    if playerData.inRace then
        outputChatBox("❌ Ban da o trong race roi.", player, 255, 100, 100)
        return
    end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban can o trong xe de join race.", player, 255, 100, 100)
        return
    end
    
    local races = getElementData(getResourceRootElement(), "activeRaces") or {}
    local race = races[tonumber(raceID)]
    
    if not race then
        outputChatBox("❌ Race khong ton tai.", player, 255, 100, 100)
        return
    end
    
    if race.status ~= "waiting" then
        outputChatBox("❌ Race da bat dau roi.", player, 255, 100, 100)
        return
    end
    
    if race.bet > 0 and (playerData.money or 0) < race.bet then
        outputChatBox(string.format("❌ Ban can $%d de join race.", race.bet), player, 255, 100, 100)
        return
    end
    
    -- Join race
    table.insert(race.participants, player)
    races[tonumber(raceID)] = race
    setElementData(getResourceRootElement(), "activeRaces", races)
    
    playerData.inRace = tonumber(raceID)
    playerData.racePosition = #race.participants
    setElementData(player, "playerData", playerData)
    
    outputChatBox(string.format("✅ Da join race! (%d/%d players)", #race.participants, 8), player, 0, 255, 0)
    
    -- Notify other participants
    for _, participant in ipairs(race.participants) do
        if participant ~= player and isElement(participant) then
            outputChatBox(string.format("🏁 %s da join race! (%d players)", 
                getPlayerName(player), #race.participants), participant, 255, 255, 100)
        end
    end
    
    -- Auto start if 8 players
    if #race.participants >= 8 then
        outputChatBox("🏁 Race tu dong bat dau! (8/8 players)", player, 255, 255, 0)
        -- Trigger race start logic here
    end
end)

-- Leave race
addCommandHandler("leaverace", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.inRace then
        outputChatBox("❌ Ban khong o trong race nao.", player, 255, 100, 100)
        return
    end
    
    local races = getElementData(getResourceRootElement(), "activeRaces") or {}
    local race = races[playerData.inRace]
    
    if race then
        -- Remove from participants
        for i, participant in ipairs(race.participants) do
            if participant == player then
                table.remove(race.participants, i)
                break
            end
        end
        
        -- Cancel race if creator leaves
        if race.creator == player then
            for _, participant in ipairs(race.participants) do
                if isElement(participant) then
                    local pData = getElementData(participant, "playerData") or {}
                    pData.inRace = nil
                    setElementData(participant, "playerData", pData)
                    outputChatBox("❌ Race bi cancel vi creator da leave.", participant, 255, 100, 100)
                end
            end
            races[playerData.inRace] = nil
        else
            races[playerData.inRace] = race
        end
        
        setElementData(getResourceRootElement(), "activeRaces", races)
    end
    
    playerData.inRace = nil
    playerData.racePosition = nil
    setElementData(player, "playerData", playerData)
    
    outputChatBox("❌ Da leave race.", player, 255, 255, 100)
end)

-- Race countdown
addCommandHandler("countdown", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.inRace then
        outputChatBox("❌ Ban khong o trong race.", player, 255, 100, 100)
        return
    end
    
    local races = getElementData(getResourceRootElement(), "activeRaces") or {}
    local race = races[playerData.inRace]
    
    if not race or race.creator ~= player then
        outputChatBox("❌ Chi race creator moi co the start countdown.", player, 255, 100, 100)
        return
    end
    
    if #race.participants < 2 then
        outputChatBox("❌ Can it nhat 2 players de start race.", player, 255, 100, 100)
        return
    end
    
    if race.status ~= "waiting" then
        outputChatBox("❌ Race da start roi.", player, 255, 100, 100)
        return
    end
    
    -- Start countdown
    race.status = "countdown"
    races[playerData.inRace] = race
    setElementData(getResourceRootElement(), "activeRaces", races)
    
    -- Countdown logic
    for i = 3, 1, -1 do
        setTimer(function()
            for _, participant in ipairs(race.participants) do
                if isElement(participant) then
                    outputChatBox(string.format("🏁 COUNTDOWN: %d", i), participant, 255, 255, 0)
                end
            end
        end, (4-i) * 1000, 1)
    end
    
    -- Start race
    setTimer(function()
        race.status = "racing"
        race.startTime = getRealTime().timestamp
        races[playerData.inRace] = race
        setElementData(getResourceRootElement(), "activeRaces", races)
        
        for _, participant in ipairs(race.participants) do
            if isElement(participant) then
                outputChatBox("🏁 GO! GO! GO!", participant, 0, 255, 0)
                setVehicleEngineState(getPedOccupiedVehicle(participant), true)
            end
        end
    end, 4000, 1)
end)

-- Drag race
addCommandHandler("drag", function(player, cmd, playerIdOrName, distance, bet)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerIdOrName then
        outputChatBox("Su dung: /drag [player_id] [distance] [bet]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    if targetPlayer == player then
        outputChatBox("❌ Ban khong the drag voi chinh minh.", player, 255, 100, 100)
        return
    end
    
    local vehicle = getPedOccupiedVehicle(player)
    local targetVehicle = getPedOccupiedVehicle(targetPlayer)
    
    if not vehicle or not targetVehicle then
        outputChatBox("❌ Ca 2 nguoi can o trong xe.", player, 255, 100, 100)
        return
    end
    
    local dragDistance = tonumber(distance) or 400
    local betAmount = tonumber(bet) or 0
    
    if betAmount > 0 then
        if (playerData.money or 0) < betAmount then
            outputChatBox("❌ Ban khong co du tien de bet.", player, 255, 100, 100)
            return
        end
        
        local targetData = getElementData(targetPlayer, "playerData") or {}
        if (targetData.money or 0) < betAmount then
            outputChatBox("❌ Doi thu khong co du tien de bet.", player, 255, 100, 100)
            return
        end
    end
    
    -- Send drag challenge
    local targetData = getElementData(targetPlayer, "playerData") or {}
    targetData.dragChallenge = {
        from = player,
        distance = dragDistance,
        bet = betAmount,
        time = getRealTime().timestamp
    }
    setElementData(targetPlayer, "playerData", targetData)
    
    outputChatBox(string.format("🏁 Da gui drag challenge den %s (%dm, $%d).", 
        getPlayerName(targetPlayer), dragDistance, betAmount), player, 255, 255, 100)
    outputChatBox(string.format("🏁 %s thach ban drag race (%dm, $%d). Su dung /acceptdrag.", 
        getPlayerName(player), dragDistance, betAmount), targetPlayer, 255, 255, 100)
end)

-- Accept drag race
addCommandHandler("acceptdrag", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.dragChallenge then
        outputChatBox("❌ Ban khong co drag challenge.", player, 255, 100, 100)
        return
    end
    
    local challenge = playerData.dragChallenge
    if not isElement(challenge.from) then
        outputChatBox("❌ Challenge da expired.", player, 255, 100, 100)
        playerData.dragChallenge = nil
        setElementData(player, "playerData", playerData)
        return
    end
    
    -- Start drag race
    local challenger = challenge.from
    playerData.dragChallenge = nil
    
    playerData.inDrag = {
        opponent = challenger,
        distance = challenge.distance,
        bet = challenge.bet,
        startTime = getRealTime().timestamp,
        startPos = {getElementPosition(player)}
    }
    
    local challengerData = getElementData(challenger, "playerData") or {}
    challengerData.inDrag = {
        opponent = player,
        distance = challenge.distance,
        bet = challenge.bet,
        startTime = getRealTime().timestamp,
        startPos = {getElementPosition(challenger)}
    }
    
    setElementData(player, "playerData", playerData)
    setElementData(challenger, "playerData", challengerData)
    
    outputChatBox(string.format("🏁 DRAG RACE STARTED! First to %dm wins!", challenge.distance), player, 0, 255, 0)
    outputChatBox(string.format("🏁 DRAG RACE STARTED! First to %dm wins!", challenge.distance), challenger, 0, 255, 0)
end)

-- Street race
addCommandHandler("streetrace", function(player, cmd, action, bet)
    local playerData = getElementData(player, "playerData") or {}
    
    if not action then
        outputChatBox("Su dung: /streetrace [create/join/start/leave] [bet]", player, 255, 255, 255)
        return
    end
    
    if action == "create" then
        if playerData.inStreetRace then
            outputChatBox("❌ Ban da o trong street race roi.", player, 255, 100, 100)
            return
        end
        
        local betAmount = tonumber(bet) or 0
        if betAmount > 0 and (playerData.money or 0) < betAmount then
            outputChatBox("❌ Ban khong co du tien de bet.", player, 255, 100, 100)
            return
        end
        
        local vehicle = getPedOccupiedVehicle(player)
        if not vehicle then
            outputChatBox("❌ Ban can o trong xe.", player, 255, 100, 100)
            return
        end
        
        -- Create street race
        local raceID = "street_" .. getRealTime().timestamp
        local streetRaces = getElementData(getResourceRootElement(), "streetRaces") or {}
        
        streetRaces[raceID] = {
            creator = player,
            bet = betAmount,
            participants = {player},
            status = "waiting",
            checkpoints = {},
            currentCP = 1
        }
        
        setElementData(getResourceRootElement(), "streetRaces", streetRaces)
        
        playerData.inStreetRace = raceID
        setElementData(player, "playerData", playerData)
        
        outputChatBox(string.format("🏁 Da tao street race voi bet $%d. ID: %s", betAmount, raceID), player, 255, 255, 0)
        
    elseif action == "join" then
        if playerData.inStreetRace then
            outputChatBox("❌ Ban da o trong street race roi.", player, 255, 100, 100)
            return
        end
        
        local raceID = bet -- Using bet parameter as race ID
        if not raceID then
            outputChatBox("Su dung: /streetrace join [race_id]", player, 255, 255, 255)
            return
        end
        
        local streetRaces = getElementData(getResourceRootElement(), "streetRaces") or {}
        local race = streetRaces[raceID]
        
        if not race then
            outputChatBox("❌ Street race khong ton tai.", player, 255, 100, 100)
            return
        end
        
        if race.bet > 0 and (playerData.money or 0) < race.bet then
            outputChatBox(string.format("❌ Ban can $%d de join.", race.bet), player, 255, 100, 100)
            return
        end
        
        table.insert(race.participants, player)
        streetRaces[raceID] = race
        setElementData(getResourceRootElement(), "streetRaces", streetRaces)
        
        playerData.inStreetRace = raceID
        setElementData(player, "playerData", playerData)
        
        outputChatBox("✅ Da join street race!", player, 0, 255, 0)
    end
end)

-- Racing stats
addCommandHandler("racestats", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    local wins = playerData.raceWins or 0
    local losses = playerData.raceLosses or 0
    local total = wins + losses
    local winRate = total > 0 and math.floor((wins / total) * 100) or 0
    
    outputChatBox("🏁 ===== RACING STATS =====", player, 255, 255, 0)
    outputChatBox(string.format("• Total Races: %d", total), player, 255, 255, 255)
    outputChatBox(string.format("• Wins: %d", wins), player, 255, 255, 255)
    outputChatBox(string.format("• Losses: %d", losses), player, 255, 255, 255)
    outputChatBox(string.format("• Win Rate: %d%%", winRate), player, 255, 255, 255)
    outputChatBox(string.format("• Best Time: %s", playerData.bestRaceTime or "N/A"), player, 255, 255, 255)
    outputChatBox(string.format("• Total Winnings: $%d", playerData.raceWinnings or 0), player, 255, 255, 255)
end)

-- Nitro boost
addCommandHandler("nitro", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban khong o trong xe.", player, 255, 100, 100)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.hasNitro then
        outputChatBox("❌ Xe khong co nitro.", player, 255, 100, 100)
        return
    end
    
    if playerData.nitroUsed then
        outputChatBox("❌ Nitro da duoc su dung roi.", player, 255, 100, 100)
        return
    end
    
    -- Add nitro effect
    addVehicleUpgrade(vehicle, 1010) -- Nitro upgrade
    
    playerData.nitroUsed = true
    setElementData(player, "playerData", playerData)
    
    outputChatBox("🚀 NITRO ACTIVATED!", player, 0, 255, 255)
    
    -- Remove nitro after 5 seconds
    setTimer(function()
        if isElement(vehicle) then
            removeVehicleUpgrade(vehicle, 1010)
        end
    end, 5000, 1)
end)

-- Repair in race
addCommandHandler("racerepair", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.inRace and not playerData.inDrag and not playerData.inStreetRace then
        outputChatBox("❌ Ban khong o trong race nao.", player, 255, 100, 100)
        return
    end
    
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("❌ Ban khong o trong xe.", player, 255, 100, 100)
        return
    end
    
    if playerData.raceRepairUsed then
        outputChatBox("❌ Ban da su dung repair trong race nay roi.", player, 255, 100, 100)
        return
    end
    
    -- Repair vehicle
    fixVehicle(vehicle)
    playerData.raceRepairUsed = true
    setElementData(player, "playerData", playerData)
    
    outputChatBox("🔧 Vehicle repaired! (1 time per race)", player, 0, 255, 0)
end)

outputDebugString("[AMB] Racing & Sports system loaded - 11 commands")
