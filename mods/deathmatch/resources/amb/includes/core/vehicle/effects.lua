--[[
    VEHICLE CONTROL CLIENT EFFECTS
    
    Xử lý hiệu ứng âm thanh và visual cho vehicle control system
]]

-- Vehicle Sound Effects
local vehicleSounds = {}

function playVehicleSound(soundType, element)
    if soundType == "lock" then
        local sound = playSound("files/sounds/vehicles/car_lock.mp3")
        if sound then
            setSoundVolume(sound, 0.5)
        end
        
    elseif soundType == "unlock" then
        local sound = playSound("files/sounds/vehicles/car_unlock.mp3")
        if sound then
            setSoundVolume(sound, 0.5)
        end
        
    elseif soundType == "alarm" then
        if vehicleSounds[element] then
            stopSound(vehicleSounds[element])
        end
        
        local sound = playSound("files/sounds/vehicles/car_alarm.mp3", true) -- Loop
        if sound then
            setSoundVolume(sound, 0.8)
            vehicleSounds[element] = sound
        end
        
    elseif soundType == "alarm_stop" then
        if vehicleSounds[element] then
            stopSound(vehicleSounds[element])
            vehicleSounds[element] = nil
        end
    end
end

addEvent("vehicle:playSound", true)
addEventHandler("vehicle:playSound", getRootElement(), function(soundType)
    playVehicleSound(soundType)
end)

addEvent("vehicle:startAlarm", true)
addEventHandler("vehicle:startAlarm", getRootElement(), function(vehicle)
    playVehicleSound("alarm", vehicle)
end)

addEvent("vehicle:stopAlarm", true)
addEventHandler("vehicle:stopAlarm", getRootElement(), function(vehicle)
    playVehicleSound("alarm_stop", vehicle)
end)

-- Engine Start Effect
addEvent("vehicle:engineStart", true)
addEventHandler("vehicle:engineStart", getRootElement(), function(vehicle)
    if vehicle then
        local sound = playSound("files/sounds/vehicles/engine_start.mp3")
        if sound then
            setSoundVolume(sound, 0.6)
        end
    end
end)

-- Engine Stop Effect
addEvent("vehicle:engineStop", true)
addEventHandler("vehicle:engineStop", getRootElement(), function(vehicle)
    if vehicle then
        local sound = playSound("files/sounds/vehicles/engine_stop.mp3")
        if sound then
            setSoundVolume(sound, 0.4)
        end
    end
end)

-- Cleanup on resource stop
addEventHandler("onClientResourceStop", getResourceRootElement(), function()
    for element, sound in pairs(vehicleSounds) do
        if isElement(sound) then
            stopSound(sound)
        end
    end
    vehicleSounds = {}
end)

outputDebugString("Vehicle Control Client Effects loaded successfully!")
