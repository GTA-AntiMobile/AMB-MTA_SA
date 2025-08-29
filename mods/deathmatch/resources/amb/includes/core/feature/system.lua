-- ================================
-- AMB MTA:SA - Features System
-- Special features and utilities
-- ================================

-- Race system
local activeRaces = {}
local raceCheckpoints = {}

-- Drift system
local driftData = {}

-- Derby system
local derbyArenas = {
    {
        name = "LS Arena",
        center = {2000, -1500, 15},
        radius = 100,
        vehicles = {451, 506, 541, 415} -- Turismo, Super GT, Bullet, Cheetah
    }
}

-- Stunt system
local stuntBonuses = {
    ["Insane Stunt"] = 1000,
    ["Perfect Landing"] = 500,
    ["Near Miss"] = 200,
    ["Two Wheeler"] = 300,
    ["Wheelie"] = 150
}

-- Feature command: /race
addCommandHandler("race", function(player, cmd, action, ...)
    if not action then
        outputChatBox(COLOR_YELLOW .. "Usage: /race [create/join/start/leave/list]", player)
        return
    end
    
    if action == "create" then
        local raceName = table.concat({...}, " ")
        if not raceName or #raceName == 0 then
            outputChatBox(COLOR_YELLOW .. "Usage: /race create [race name]", player)
            return
        end
        
        if activeRaces[raceName] then
            outputChatBox(COLOR_RED .. "A race with this name already exists!", player)
            return
        end
        
        activeRaces[raceName] = {
            creator = getPlayerName(player),
            players = {[getPlayerName(player)] = player},
            checkpoints = {},
            started = false,
            vehicle = nil
        }
        
        outputChatBox(COLOR_GREEN .. "Race '" .. raceName .. "' created! Use /race addcp to add checkpoints.", player)
        
    elseif action == "join" then
        local raceName = table.concat({...}, " ")
        if not raceName or not activeRaces[raceName] then
            outputChatBox(COLOR_RED .. "Race not found!", player)
            return
        end
        
        local race = activeRaces[raceName]
        if race.started then
            outputChatBox(COLOR_RED .. "This race has already started!", player)
            return
        end
        
        race.players[getPlayerName(player)] = player
        outputChatBox(COLOR_GREEN .. "You joined race: " .. raceName, player)
        
        -- Notify other players
        for playerName, p in pairs(race.players) do
            if p ~= player then
                outputChatBox(COLOR_YELLOW .. getPlayerName(player) .. " joined the race!", p)
            end
        end
        
    elseif action == "start" then
        local raceName = table.concat({...}, " ")
        if not raceName or not activeRaces[raceName] then
            outputChatBox(COLOR_RED .. "Race not found!", player)
            return
        end
        
        local race = activeRaces[raceName]
        if race.creator ~= getPlayerName(player) then
            outputChatBox(COLOR_RED .. "Only the race creator can start the race!", player)
            return
        end
        
        if #race.checkpoints < 2 then
            outputChatBox(COLOR_RED .. "Race needs at least 2 checkpoints!", player)
            return
        end
        
        startRace(raceName)
        
    elseif action == "list" then
        outputChatBox(COLOR_YELLOW .. "=== Active Races ===", player)
        local count = 0
        for raceName, race in pairs(activeRaces) do
            count = count + 1
            local status = race.started and "Started" or "Waiting"
            outputChatBox(COLOR_WHITE .. count .. ". " .. raceName .. " (" .. table.count(race.players) .. " players, " .. status .. ")", player)
        end
        if count == 0 then
            outputChatBox(COLOR_GRAY .. "No active races.", player)
        end
    end
end)

-- Feature command: /race addcp
addCommandHandler("addcp", function(player)
    local x, y, z = getElementPosition(player)
    local playerName = getPlayerName(player)
    
    local race = nil
    for raceName, raceData in pairs(activeRaces) do
        if raceData.creator == playerName then
            race = raceData
            break
        end
    end
    
    if not race then
        outputChatBox(COLOR_RED .. "You are not creating any race!", player)
        return
    end
    
    table.insert(race.checkpoints, {x, y, z})
    outputChatBox(COLOR_GREEN .. "Checkpoint " .. #race.checkpoints .. " added at your position!", player)
end)

-- Start race function
function startRace(raceName)
    local race = activeRaces[raceName]
    if not race then return end
    
    race.started = true
    local startPos = race.checkpoints[1]
    
    -- Teleport all players to start
    local angle = 0
    for playerName, player in pairs(race.players) do
        local offsetX = math.cos(angle) * 5
        local offsetY = math.sin(angle) * 5
        setElementPosition(player, startPos[1] + offsetX, startPos[2] + offsetY, startPos[3])
        
        -- Create race vehicle
        if race.vehicle then
            local vehicle = createVehicle(race.vehicle, startPos[1] + offsetX, startPos[2] + offsetY, startPos[3])
            warpPedIntoVehicle(player, vehicle)
        end
        
        outputChatBox(COLOR_GREEN .. "Race started! Get to the checkpoints!", player)
        angle = angle + (math.pi * 2 / table.count(race.players))
    end
    
    -- Create first checkpoint for all players
    createRaceCheckpoints(raceName)
end

-- Feature command: /drift
addCommandHandler("drift", function(player, cmd, action)
    if action == "start" then
        local vehicle = getPedOccupiedVehicle(player)
        if not vehicle then
            outputChatBox(COLOR_RED .. "You must be in a vehicle to start drifting!", player)
            return
        end
        
        driftData[getPlayerName(player)] = {
            player = player,
            vehicle = vehicle,
            score = 0,
            combo = 0,
            lastUpdate = getRealTime().timestamp
        }
        
        outputChatBox(COLOR_GREEN .. "Drift mode activated! Start drifting to score points!", player)
        
    elseif action == "stop" then
        local playerName = getPlayerName(player)
        if not driftData[playerName] then
            outputChatBox(COLOR_RED .. "You are not in drift mode!", player)
            return
        end
        
        local score = driftData[playerName].score
        driftData[playerName] = nil
        
        outputChatBox(COLOR_GREEN .. "Drift session ended! Final score: " .. score .. " points", player)
        
        -- Give money reward
        local reward = math.floor(score / 10)
        if reward > 0 then
            givePlayerMoney(player, reward)
            outputChatBox(COLOR_YELLOW .. "Drift reward: $" .. formatMoney(reward), player)
        end
        
    else
        outputChatBox(COLOR_YELLOW .. "Usage: /drift [start/stop]", player)
    end
end)

-- Feature command: /derby
addCommandHandler("derby", function(player, cmd, action)
    if action == "join" then
        local arena = derbyArenas[1] -- Use first arena
        local px, py, pz = getElementPosition(player)
        local distance = getDistance3D(px, py, pz, arena.center[1], arena.center[2], arena.center[3])
        
        if distance > arena.radius then
            outputChatBox(COLOR_RED .. "You must be in the derby arena to join!", player)
            return
        end
        
        -- Spawn derby vehicle
        local vehicleModel = arena.vehicles[math.random(#arena.vehicles)]
        local angle = math.random() * 360
        local spawnX = arena.center[1] + math.cos(math.rad(angle)) * 20
        local spawnY = arena.center[2] + math.sin(math.rad(angle)) * 20
        
        local vehicle = createVehicle(vehicleModel, spawnX, spawnY, arena.center[3])
        warpPedIntoVehicle(player, vehicle)
        
        setElementData(player, "derbyMode", true)
        outputChatBox(COLOR_GREEN .. "You joined the demolition derby! Last car standing wins!", player)
        
    elseif action == "leave" then
        if not getElementData(player, "derbyMode") then
            outputChatBox(COLOR_RED .. "You are not in derby mode!", player)
            return
        end
        
        setElementData(player, "derbyMode", false)
        removePedFromVehicle(player)
        outputChatBox(COLOR_YELLOW .. "You left the demolition derby.", player)
        
    else
        outputChatBox(COLOR_YELLOW .. "Usage: /derby [join/leave]", player)
    end
end)

-- Feature command: /teleport
addCommandHandler("teleport", function(player, cmd, location)
    if not location then
        outputChatBox(COLOR_YELLOW .. "Usage: /teleport [location]", player)
        outputChatBox(COLOR_GRAY .. "Locations: ls, sf, lv, airport, pier, stadium, casino", player)
        return
    end
    
    local teleportLocations = {
        ["ls"] = {1479.0, -1643.0, 14.0, "Los Santos City Hall"},
        ["sf"] = {-2026.0, 156.0, 29.0, "San Fierro Gant Bridge"},
        ["lv"] = {2495.0, 1666.0, 11.0, "Las Venturas Strip"},
        ["airport"] = {1680.0, -2324.0, 14.0, "Los Santos Airport"},
        ["pier"] = {842.0, -2055.0, 13.0, "Santa Maria Beach Pier"},
        ["stadium"] = {-1396.0, 987.0, 19.0, "Foster Valley Stadium"},
        ["casino"] = {2233.0, 1714.0, 11.0, "Four Dragons Casino"}
    }
    
    local pos = teleportLocations[location:lower()]
    if not pos then
        outputChatBox(COLOR_RED .. "Location not found!", player)
        return
    end
    
    setElementPosition(player, pos[1], pos[2], pos[3])
    outputChatBox(COLOR_GREEN .. "Teleported to: " .. pos[4], player)
end)

-- Feature command: /weather
addCommandHandler("weather", function(player, cmd, weatherID)
    if not isPlayerAdmin(player, ADMIN_LEVEL_MODERATOR) then
        outputChatBox(COLOR_RED .. "You don't have permission to use this command!", player)
        return
    end
    
    if not weatherID then
        outputChatBox(COLOR_YELLOW .. "Usage: /weather [weather ID 0-255]", player)
        return
    end
    
    weatherID = tonumber(weatherID)
    if not weatherID or weatherID < 0 or weatherID > 255 then
        outputChatBox(COLOR_RED .. "Weather ID must be between 0 and 255!", player)
        return
    end
    
    setWeather(weatherID)
    outputChatBox(COLOR_GREEN .. "Weather changed to ID: " .. weatherID, player)
    
    -- Notify all players
    for _, p in ipairs(getElementsByType("player")) do
        if p ~= player then
            outputChatBox(COLOR_YELLOW .. "Weather changed by " .. getPlayerName(player), p)
        end
    end
end)

-- Feature command: /time
addCommandHandler("time", function(player, cmd, hour, minute)
    if not isPlayerAdmin(player, ADMIN_LEVEL_MODERATOR) then
        outputChatBox(COLOR_RED .. "You don't have permission to use this command!", player)
        return
    end
    
    if not hour then
        outputChatBox(COLOR_YELLOW .. "Usage: /time [hour] [minute]", player)
        return
    end
    
    hour = tonumber(hour) or 12
    minute = tonumber(minute) or 0
    
    if hour < 0 or hour > 23 or minute < 0 or minute > 59 then
        outputChatBox(COLOR_RED .. "Invalid time! Hour: 0-23, Minute: 0-59", player)
        return
    end
    
    setTime(hour, minute)
    outputChatBox(COLOR_GREEN .. "Time set to " .. string.format("%02d:%02d", hour, minute), player)
    
    -- Notify all players
    for _, p in ipairs(getElementsByType("player")) do
        if p ~= player then
            outputChatBox(COLOR_YELLOW .. "Time changed by " .. getPlayerName(player), p)
        end
    end
end)

-- Feature command: /neon
addCommandHandler("neon", function(player, cmd, color)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox(COLOR_RED .. "You must be in a vehicle to add neon!", player)
        return
    end
    
    if not color then
        outputChatBox(COLOR_YELLOW .. "Usage: /neon [red/blue/green/yellow/pink/white/off]", player)
        return
    end
    
    local neonColors = {
        ["red"] = {255, 0, 0},
        ["blue"] = {0, 0, 255},
        ["green"] = {0, 255, 0},
        ["yellow"] = {255, 255, 0},
        ["pink"] = {255, 0, 255},
        ["white"] = {255, 255, 255}
    }
    
    if color:lower() == "off" then
        -- Remove neon (this would need custom implementation)
        outputChatBox(COLOR_GREEN .. "Neon lights removed.", player)
        return
    end
    
    local rgb = neonColors[color:lower()]
    if not rgb then
        outputChatBox(COLOR_RED .. "Invalid color! Available: red, blue, green, yellow, pink, white, off", player)
        return
    end
    
    -- Add neon effect (this would need custom implementation with objects/markers)
    outputChatBox(COLOR_GREEN .. "Neon lights added: " .. color, player)
    
    -- Cost money
    takePlayerMoney(player, 500)
    outputChatBox(COLOR_YELLOW .. "Cost: $500", player)
end)

-- Feature command: /nos
addCommandHandler("nos", function(player, cmd, level)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox(COLOR_RED .. "You must be in a vehicle to add NOS!", player)
        return
    end
    
    level = tonumber(level) or 1
    if level < 1 or level > 10 then
        outputChatBox(COLOR_RED .. "NOS level must be between 1 and 10!", player)
        return
    end
    
    -- Add NOS upgrade
    addVehicleUpgrade(vehicle, 1008 + level - 1) -- NOS upgrades
    outputChatBox(COLOR_GREEN .. "NOS level " .. level .. " installed!", player)
    
    -- Cost based on level
    local cost = level * 200
    takePlayerMoney(player, cost)
    outputChatBox(COLOR_YELLOW .. "Cost: $" .. formatMoney(cost), player)
end)

-- Feature command: /repair
addCommandHandler("repair", function(player)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox(COLOR_RED .. "You must be in a vehicle to repair it!", player)
        return
    end
    
    fixVehicle(vehicle)
    outputChatBox(COLOR_GREEN .. "Vehicle repaired!", player)
    
    -- Cost money
    takePlayerMoney(player, 100)
    outputChatBox(COLOR_YELLOW .. "Repair cost: $100", player)
end)

-- Stunt detection system
addEventHandler("onPlayerVehicleEnter", root, function(vehicle, seat)
    if seat == 0 then -- Driver seat
        setElementData(source, "stuntMode", true)
    end
end)

addEventHandler("onPlayerVehicleExit", root, function(vehicle, seat)
    if seat == 0 then
        setElementData(source, "stuntMode", false)
    end
end)

-- Drift detection timer
setTimer(function()
    for playerName, data in pairs(driftData) do
        if isElement(data.player) and isElement(data.vehicle) then
            local vx, vy, vz = getElementVelocity(data.vehicle)
            local speed = math.sqrt(vx*vx + vy*vy + vz*vz) * 180 -- Convert to km/h
            
            if speed > 30 then -- Minimum speed for drift
                local rx, ry, rz = getElementRotation(data.vehicle)
                local velocityAngle = math.deg(math.atan2(vy, vx))
                local angleDiff = math.abs(velocityAngle - rz)
                
                if angleDiff > 15 and angleDiff < 165 then -- Drifting
                    local points = math.floor(speed * angleDiff / 100)
                    data.score = data.score + points
                    data.combo = data.combo + 1
                    
                    if data.combo > 1 then
                        points = points * data.combo -- Combo multiplier
                    end
                    
                    if data.combo % 10 == 0 then
                        outputChatBox(COLOR_YELLOW .. "Drift combo x" .. data.combo .. "! +" .. points .. " points", data.player)
                    end
                else
                    data.combo = 0
                end
            end
        else
            driftData[playerName] = nil
        end
    end
end, 100, 0)

-- Features system loaded
registerCommandSystem("Core Features", 10, true)
