-- ================================
-- AMB MTA:SA - Custom Vehicle Sounds System
-- Horn and Engine Sound Replacement
-- ================================

local vehicleSounds = {
    engines = {}, -- Vehicle engine sounds
    horns = {},   -- Vehicle horn sounds
    customSounds = {
        -- Custom horn sounds for different vehicles
        [30001] = "files/sounds/vehicles/lamborghini_horn.mp3", -- Lamborghini custom horn
        [411] = "files/sounds/vehicles/sports_horn.mp3",        -- Infernus horn
        [522] = "files/sounds/vehicles/bike_horn.mp3",          -- NRG horn

        -- Custom engine sounds
        engines = {
            [30001] = "files/sounds/vehicles/lamborghini_engine.mp3", -- Lamborghini engine
            [411] = "files/sounds/vehicles/v8_engine.mp3",            -- Infernus V8
            [522] = "files/sounds/vehicles/bike_engine.mp3",          -- NRG engine
        }
    }
}

-- Function to play custom horn sound
local function playCustomHorn(vehicle, player)
    local modelID = getElementModel(vehicle)
    local hornSound = vehicleSounds.customSounds[modelID]

    if hornSound then
        -- Stop any existing horn sound for this vehicle
        if vehicleSounds.horns[vehicle] then
            stopSound(vehicleSounds.horns[vehicle])
        end

        local x, y, z = getElementPosition(vehicle)
        vehicleSounds.horns[vehicle] = playSound3D(hornSound, x, y, z, false)

        if vehicleSounds.horns[vehicle] then
            setSoundMaxDistance(vehicleSounds.horns[vehicle], 50)
            attachElements(vehicleSounds.horns[vehicle], vehicle)
            setSoundVolume(vehicleSounds.horns[vehicle], 0.7)

            -- Auto cleanup after sound finishes
            setTimer(function()
                if vehicleSounds.horns[vehicle] then
                    stopSound(vehicleSounds.horns[vehicle])
                    vehicleSounds.horns[vehicle] = nil
                end
            end, 3000, 1)

            return true
        end
    end

    return false
end

-- Function to play custom engine sound
local function playCustomEngine(vehicle)
    local modelID = getElementModel(vehicle)
    local engineSound = vehicleSounds.customSounds.engines[modelID]

    if engineSound then
        -- Stop any existing engine sound for this vehicle
        if vehicleSounds.engines[vehicle] then
            stopSound(vehicleSounds.engines[vehicle])
        end

        local x, y, z = getElementPosition(vehicle)
        vehicleSounds.engines[vehicle] = playSound3D(engineSound, x, y, z, true) -- Loop engine sound

        if vehicleSounds.engines[vehicle] then
            setSoundMaxDistance(vehicleSounds.engines[vehicle], 30)
            attachElements(vehicleSounds.engines[vehicle], vehicle)
            setSoundVolume(vehicleSounds.engines[vehicle], 0.5)

            return true
        end
    end

    return false
end

-- Client-side event handlers
if (getElementType(localPlayer) == "player") then
    -- Handle horn key press (default: H key)
    addEventHandler("onClientKey", root, function(key, press)
        if key == "h" and press then
            local vehicle = getPedOccupiedVehicle(localPlayer)
            if vehicle then
                local seat = getPedOccupiedVehicleSeat(localPlayer)
                if seat == 0 then -- Only driver can use horn
                    if playCustomHorn(vehicle, localPlayer) then
                        -- Cancel default horn sound
                        cancelEvent()
                    end
                end
            end
        end
    end)

    -- Handle vehicle enter (start engine sound)
    addEventHandler("onClientVehicleEnter", root, function(player, seat)
        if player == localPlayer and seat == 0 then -- Driver seat
            setTimer(function()
                if getPedOccupiedVehicle(localPlayer) == source then
                    playCustomEngine(source)
                end
            end, 1000, 1) -- Delay to let vehicle settle
        end
    end)

    -- Handle vehicle exit (stop engine sound)
    addEventHandler("onClientVehicleExit", root, function(player, seat)
        if player == localPlayer and seat == 0 then -- Driver seat
            if vehicleSounds.engines[source] then
                stopSound(vehicleSounds.engines[source])
                vehicleSounds.engines[source] = nil
            end
        end
    end)

    -- Handle vehicle explosion (cleanup sounds)
    addEventHandler("onClientVehicleExplode", root, function()
        if vehicleSounds.engines[source] then
            stopSound(vehicleSounds.engines[source])
            vehicleSounds.engines[source] = nil
        end
        if vehicleSounds.horns[source] then
            stopSound(vehicleSounds.horns[source])
            vehicleSounds.horns[source] = nil
        end
    end)
end

-- Admin commands for testing sounds
addCommandHandler("testhorn", function(player, _, modelID)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Ban can o trong xe!", player, 255, 0, 0)
        return
    end

    if modelID then
        modelID = tonumber(modelID)
        setElementModel(vehicle, modelID)
    end

    playCustomHorn(vehicle, player)
    outputChatBox("Test horn for model: " .. getElementModel(vehicle), player, 0, 255, 0)
end)

addCommandHandler("testengine", function(player, _, modelID)
    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Ban can o trong xe!", player, 255, 0, 0)
        return
    end

    if modelID then
        modelID = tonumber(modelID)
        setElementModel(vehicle, modelID)
    end

    playCustomEngine(vehicle)
    outputChatBox("Test engine for model: " .. getElementModel(vehicle), player, 0, 255, 0)
end)

-- Add custom sound for specific vehicle model
addCommandHandler("addsound", function(player, _, soundType, modelID, soundFile)
    if not hasPermission(player, "admin") then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not soundType or not modelID or not soundFile then
        outputChatBox("Su dung: /addsound [horn/engine] [modelID] [soundFile]", player, 255, 255, 255)
        return
    end

    modelID = tonumber(modelID)
    if not modelID then
        outputChatBox("ModelID phai la so!", player, 255, 0, 0)
        return
    end

    if soundType == "horn" then
        vehicleSounds.customSounds[modelID] = soundFile
        outputChatBox("Da them horn sound cho model " .. modelID .. ": " .. soundFile, player, 0, 255, 0)
    elseif soundType == "engine" then
        vehicleSounds.customSounds.engines[modelID] = soundFile
        outputChatBox("Da them engine sound cho model " .. modelID .. ": " .. soundFile, player, 0, 255, 0)
    else
        outputChatBox("SoundType phai la 'horn' hoac 'engine'!", player, 255, 0, 0)
    end
end)

-- List custom sounds
addCommandHandler("listsounds", function(player)
    outputChatBox("=== CUSTOM VEHICLE SOUNDS ===", player, 255, 255, 0)

    outputChatBox("--- Horn Sounds ---", player, 255, 255, 100)
    for modelID, soundFile in pairs(vehicleSounds.customSounds) do
        if type(soundFile) == "string" then
            outputChatBox("Model " .. modelID .. ": " .. soundFile, player, 200, 200, 200)
        end
    end

    outputChatBox("--- Engine Sounds ---", player, 255, 255, 100)
    for modelID, soundFile in pairs(vehicleSounds.customSounds.engines) do
        outputChatBox("Model " .. modelID .. ": " .. soundFile, player, 200, 200, 200)
    end
end)

-- Vehicle sounds system loaded
outputDebugString("[AMB] Vehicle Custom Sounds System loaded")
