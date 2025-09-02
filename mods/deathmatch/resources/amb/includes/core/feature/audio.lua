-- ================================
-- AMB MTA:SA - Audio System Commands
-- Migrated from SA-MP open.mp server
-- ================================

-- Audio/Music system for vehicles and boomboxes
local audioSystem = {
    vehicles = {},
    boomboxes = {},
    stations = {
        {name = "Radio Los Santos", url = "http://radio.ls.com/stream"},
        {name = "K-DST", url = "http://kdst.radio.com/stream"},
        {name = "Radio X", url = "http://radiox.com/stream"},
        {name = "CSR 103.9", url = "http://csr1039.com/stream"},
        {name = "K-JAH West", url = "http://kjah.com/stream"}
    }
}

-- Set boombox for player
addCommandHandler("setboombox", function(player, _, playerIdOrName)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /setboombox [player]", player, 255, 255, 255)
        return
    end
    
    local target = getPlayerFromName(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end
    
    local hasBox = getElementData(target, "player.boombox") or false
    setElementData(target, "player.boombox", not hasBox)
    
    if hasBox then
        outputChatBox("Da xoa boombox cua " .. getPlayerName(target), player, 0, 255, 0)
        outputChatBox("Admin " .. getPlayerName(player) .. " da thu hoi boombox cua ban", target, 255, 255, 0)
    else
        outputChatBox("Da trao boombox cho " .. getPlayerName(target), player, 0, 255, 0)
        outputChatBox("Admin " .. getPlayerName(player) .. " da trao boombox cho ban", target, 0, 255, 0)
    end
end)

-- Set radio station
addCommandHandler("setstation", function(player, _, stationID)
    local hasBoombox = getElementData(player, "player.boombox")
    if not hasBoombox then
        outputChatBox("Ban khong co boombox!", player, 255, 0, 0)
        return
    end
    
    if not stationID then
        outputChatBox("Su dung: /setstation [1-5]", player, 255, 255, 255)
        outputChatBox("Cac kenh:", player, 255, 255, 255)
        for i, station in ipairs(audioSystem.stations) do
            outputChatBox(i .. ". " .. station.name, player, 200, 200, 200)
        end
        return
    end
    
    local id = tonumber(stationID)
    if not id or id < 1 or id > #audioSystem.stations then
        outputChatBox("ID kenh khong hop le! (1-5)", player, 255, 0, 0)
        return
    end
    
    local station = audioSystem.stations[id]
    local x, y, z = getElementPosition(player)
    
    -- Stop current boombox music
    if audioSystem.boomboxes[player] then
        stopSound(audioSystem.boomboxes[player])
    end
    
    -- Play new station
    audioSystem.boomboxes[player] = playSound3D(station.url, x, y, z, true)
    if audioSystem.boomboxes[player] then
        setSoundMaxDistance(audioSystem.boomboxes[player], 30)
        attachElements(audioSystem.boomboxes[player], player)
        outputChatBox("Dang phat: " .. station.name, player, 0, 255, 0)
        
        -- Notify nearby players
        for _, nearbyPlayer in ipairs(getElementsByType("player")) do
            if nearbyPlayer ~= player then
                local px, py, pz = getElementPosition(nearbyPlayer)
                local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
                if distance <= 30 then
                    outputChatBox(getPlayerName(player) .. " dang phat nhac: " .. station.name, nearbyPlayer, 200, 200, 200)
                end
            end
        end
    else
        outputChatBox("Loi: Khong the phat nhac!", player, 255, 0, 0)
    end
end)

-- Stop audio URL
addCommandHandler("audiostopurl", function(player)
    local hasBoombox = getElementData(player, "player.boombox")
    if not hasBoombox then
        outputChatBox("Ban khong co boombox!", player, 255, 0, 0)
        return
    end
    
    if audioSystem.boomboxes[player] then
        stopSound(audioSystem.boomboxes[player])
        audioSystem.boomboxes[player] = nil
        outputChatBox("Da dung phat nhac", player, 255, 255, 0)
        
        -- Notify nearby players
        local x, y, z = getElementPosition(player)
        for _, nearbyPlayer in ipairs(getElementsByType("player")) do
            if nearbyPlayer ~= player then
                local px, py, pz = getElementPosition(nearbyPlayer)
                local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
                if distance <= 30 then
                    outputChatBox(getPlayerName(player) .. " da dung phat nhac", nearbyPlayer, 200, 200, 200)
                end
            end
        end
    else
        outputChatBox("Ban khong dang phat nhac nao!", player, 255, 0, 0)
    end
end)

-- Play custom audio URL
addCommandHandler("audiourl", function(player, _, url)
    local hasBoombox = getElementData(player, "player.boombox")
    if not hasBoombox then
        outputChatBox("Ban khong co boombox!", player, 255, 0, 0)
        return
    end
    
    if not url then
        outputChatBox("Su dung: /audiourl [URL]", player, 255, 255, 255)
        return
    end
    
    -- Basic URL validation
    if not (string.find(url, "http://") or string.find(url, "https://")) then
        outputChatBox("URL khong hop le! Can bat dau bang http:// hoac https://", player, 255, 0, 0)
        return
    end
    
    local x, y, z = getElementPosition(player)
    
    -- Stop current boombox music
    if audioSystem.boomboxes[player] then
        stopSound(audioSystem.boomboxes[player])
    end
    
    -- Play custom URL
    audioSystem.boomboxes[player] = playSound3D(url, x, y, z, true)
    if audioSystem.boomboxes[player] then
        setSoundMaxDistance(audioSystem.boomboxes[player], 30)
        attachElements(audioSystem.boomboxes[player], player)
        outputChatBox("Dang phat URL: " .. url, player, 0, 255, 0)
        
        -- Notify nearby players
        for _, nearbyPlayer in ipairs(getElementsByType("player")) do
            if nearbyPlayer ~= player then
                local px, py, pz = getElementPosition(nearbyPlayer)
                local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)
                if distance <= 30 then
                    outputChatBox(getPlayerName(player) .. " dang phat nhac tu URL", nearbyPlayer, 200, 200, 200)
                end
            end
        end
    else
        outputChatBox("Loi: Khong the phat URL nay!", player, 255, 0, 0)
    end
end)

-- Vehicle music system
addCommandHandler("carmusic", function(player, _, action, ...)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Ban can o trong xe!", player, 255, 0, 0)
        return
    end
    
    local seat = getPedOccupiedVehicleSeat(player)
    if seat ~= 0 then
        outputChatBox("Chi tai xe moi co the dieu khien nhac!", player, 255, 0, 0)
        return
    end
    
    if not action then
        outputChatBox("Su dung: /carmusic [play/stop/station] [url/station_id]", player, 255, 255, 255)
        return
    end
    
    if action == "play" then
        local url = table.concat({...}, " ")
        if not url or url == "" then
            outputChatBox("Su dung: /carmusic play [URL]", player, 255, 255, 255)
            return
        end
        
        -- Stop current vehicle music
        if audioSystem.vehicles[vehicle] then
            stopSound(audioSystem.vehicles[vehicle])
        end
        
        local x, y, z = getElementPosition(vehicle)
        audioSystem.vehicles[vehicle] = playSound3D(url, x, y, z, true)
        
        if audioSystem.vehicles[vehicle] then
            setSoundMaxDistance(audioSystem.vehicles[vehicle], 20)
            attachElements(audioSystem.vehicles[vehicle], vehicle)
            outputChatBox("Dang phat nhac trong xe: " .. url, player, 0, 255, 0)
        else
            outputChatBox("Loi: Khong the phat URL nay!", player, 255, 0, 0)
        end
        
    elseif action == "stop" then
        if audioSystem.vehicles[vehicle] then
            stopSound(audioSystem.vehicles[vehicle])
            audioSystem.vehicles[vehicle] = nil
            outputChatBox("Da dung nhac trong xe", player, 255, 255, 0)
        else
            outputChatBox("Xe khong dang phat nhac!", player, 255, 0, 0)
        end
        
    elseif action == "station" then
        local stationID = tonumber(({...})[1])
        if not stationID or stationID < 1 or stationID > #audioSystem.stations then
            outputChatBox("ID kenh khong hop le! (1-5)", player, 255, 0, 0)
            for i, station in ipairs(audioSystem.stations) do
                outputChatBox(i .. ". " .. station.name, player, 200, 200, 200)
            end
            return
        end
        
        local station = audioSystem.stations[stationID]
        
        -- Stop current vehicle music
        if audioSystem.vehicles[vehicle] then
            stopSound(audioSystem.vehicles[vehicle])
        end
        
        local x, y, z = getElementPosition(vehicle)
        audioSystem.vehicles[vehicle] = playSound3D(station.url, x, y, z, true)
        
        if audioSystem.vehicles[vehicle] then
            setSoundMaxDistance(audioSystem.vehicles[vehicle], 20)
            attachElements(audioSystem.vehicles[vehicle], vehicle)
            outputChatBox("Dang phat kenh: " .. station.name, player, 0, 255, 0)
        else
            outputChatBox("Loi: Khong the phat kenh!", player, 255, 0, 0)
        end
    end
end)

-- Cleanup when player leaves
addEventHandler("onPlayerQuit", root, function()
    if audioSystem.boomboxes[source] then
        stopSound(audioSystem.boomboxes[source])
        audioSystem.boomboxes[source] = nil
    end
end)

-- Cleanup when vehicle is destroyed
addEventHandler("onVehicleExplode", root, function()
    if audioSystem.vehicles[source] then
        stopSound(audioSystem.vehicles[source])
        audioSystem.vehicles[source] = nil
    end
end)

-- Audio system loaded
registerCommandSystem("Audio/Boombox", 5, true)
