-- ================================
-- AMB Speedometer System
-- Shows speed, health, fuel for vehicles
-- ================================

local screenW, screenH = guiGetScreenSize()
local speedometerEnabled = true
local font = "default-bold"

-- Speedometer position and size
local SPEEDO_X = screenW - 250
local SPEEDO_Y = screenH - 120
local SPEEDO_WIDTH = 240
local SPEEDO_HEIGHT = 100

-- Current vehicle data
local currentVehicle = nil
local currentSpeed = 0
local currentHealth = 100
local currentFuel = 100

-- Get vehicle speed in KM/H
function getVehicleSpeed(vehicle)
    if not vehicle then return 0 end
    
    local vx, vy, vz = getElementVelocity(vehicle)
    local speed = math.sqrt(vx^2 + vy^2 + vz^2) * 180 -- Convert to KM/H
    return math.floor(speed)
end

-- Custom Vehicle Name System (Client)
function getCustomVehicleName(vehicle)
    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        return "Unknown Vehicle"
    end
    
    -- Get vehicle model ID
    local modelID = getElementModel(vehicle)
    
    -- For standard GTA vehicles (400-611), always use default names
    if modelID >= 400 and modelID <= 611 then
        return getVehicleName(vehicle) or ("Vehicle " .. modelID)
    end
    
    -- For custom vehicles (30001+), try to get custom name
    if modelID >= 30001 then
        -- First check element data for temporary custom names
        local tempName = getElementData(vehicle, "customVehicleName")
        if tempName then
            return tempName
        end
        
        -- Try to get custom vehicle name from newmodels_azul
        local customName = exports.newmodels_azul:getCustomModelName(modelID)
        if customName then
            return customName
        end
        
        -- Fallback: Check if it's a registered custom vehicle
        local customModels = exports.newmodels_azul:getCustomModels()
        if customModels and customModels[modelID] then
            return customModels[modelID].name or ("Custom Vehicle " .. modelID)
        end
        
        -- Final fallback for custom vehicles
        return "Custom Vehicle " .. modelID
    end
    
    -- Fallback for any other vehicles
    return getVehicleName(vehicle) or ("Vehicle " .. modelID)
end

-- Get vehicle health percentage
function getVehicleHealthPercent(vehicle)
    if not vehicle then return 100 end
    
    local health = getElementHealth(vehicle)
    return math.floor((health / 1000) * 100)
end

-- Draw speedometer
function drawSpeedometer()
    if not speedometerEnabled then return end
    
    local player = getLocalPlayer()
    local vehicle = getPedOccupiedVehicle(player)
    
    if not vehicle then
        currentVehicle = nil
        return
    end
    
    currentVehicle = vehicle
    currentSpeed = getVehicleSpeed(vehicle)
    currentHealth = getVehicleHealthPercent(vehicle)
    
    -- Background
    dxDrawRectangle(SPEEDO_X, SPEEDO_Y, SPEEDO_WIDTH, SPEEDO_HEIGHT, tocolor(0, 0, 0, 150))
    dxDrawRectangle(SPEEDO_X, SPEEDO_Y, SPEEDO_WIDTH, 3, tocolor(255, 165, 0, 255)) -- Orange top border
    
    -- Vehicle name with custom support
    local vehicleName = getCustomVehicleName(vehicle)
    dxDrawText(vehicleName, SPEEDO_X + 10, SPEEDO_Y + 10, SPEEDO_X + SPEEDO_WIDTH - 10, SPEEDO_Y + 30, tocolor(255, 255, 255, 255), 0.8, font, "center")
    
    -- Speed
    dxDrawText("Speed", SPEEDO_X + 10, SPEEDO_Y + 35, 0, 0, tocolor(255, 255, 255, 255), 0.7, font)
    dxDrawText(currentSpeed .. " KM/H", SPEEDO_X + 70, SPEEDO_Y + 35, 0, 0, tocolor(0, 255, 127, 255), 0.8, font)
    
    -- Health bar
    dxDrawText("Health", SPEEDO_X + 10, SPEEDO_Y + 55, 0, 0, tocolor(255, 255, 255, 255), 0.7, font)
    local healthBarWidth = 100
    local healthColor = tocolor(255, 0, 0, 255)
    if currentHealth > 50 then
        healthColor = tocolor(0, 255, 0, 255)
    elseif currentHealth > 25 then
        healthColor = tocolor(255, 255, 0, 255)
    end
    
    -- Health bar background
    dxDrawRectangle(SPEEDO_X + 70, SPEEDO_Y + 57, healthBarWidth, 12, tocolor(50, 50, 50, 255))
    -- Health bar fill
    dxDrawRectangle(SPEEDO_X + 70, SPEEDO_Y + 57, (healthBarWidth * currentHealth) / 100, 12, healthColor)
    -- Health percentage text
    dxDrawText(currentHealth .. "%", SPEEDO_X + 180, SPEEDO_Y + 55, 0, 0, tocolor(255, 255, 255, 255), 0.7, font)
    
    -- Fuel bar (simulated)
    dxDrawText("Fuel", SPEEDO_X + 10, SPEEDO_Y + 75, 0, 0, tocolor(255, 255, 255, 255), 0.7, font)
    -- Simulate fuel decrease over time
    if not getElementData(vehicle, "fuel") then
        setElementData(vehicle, "fuel", 100)
    end
    
    currentFuel = getElementData(vehicle, "fuel") or 100
    local fuelColor = tocolor(0, 150, 255, 255)
    if currentFuel < 25 then
        fuelColor = tocolor(255, 0, 0, 255)
    elseif currentFuel < 50 then
        fuelColor = tocolor(255, 255, 0, 255)
    end
    
    -- Fuel bar background
    dxDrawRectangle(SPEEDO_X + 70, SPEEDO_Y + 77, healthBarWidth, 12, tocolor(50, 50, 50, 255))
    -- Fuel bar fill
    dxDrawRectangle(SPEEDO_X + 70, SPEEDO_Y + 77, (healthBarWidth * currentFuel) / 100, 12, fuelColor)
    -- Fuel percentage text
    dxDrawText(currentFuel .. "%", SPEEDO_X + 180, SPEEDO_Y + 75, 0, 0, tocolor(255, 255, 255, 255), 0.7, font)
end

-- Start speedometer
function startSpeedometer()
    addEventHandler("onClientRender", root, drawSpeedometer)
    speedometerEnabled = true
    outputChatBox("🏎️ Speedometer enabled", 0, 255, 127)
end

-- Stop speedometer  
function stopSpeedometer()
    removeEventHandler("onClientRender", root, drawSpeedometer)
    speedometerEnabled = false
    outputChatBox("🏎️ Speedometer disabled", 255, 100, 100)
end

-- Toggle speedometer
function toggleSpeedometer()
    if speedometerEnabled then
        stopSpeedometer()
    else
        startSpeedometer()
    end
end

-- Fuel consumption simulation
setTimer(function()
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        local occupant = getVehicleOccupant(vehicle)
        if occupant then
            local fuel = getElementData(vehicle, "fuel") or 100
            if fuel > 0 then
                -- Decrease fuel based on speed
                local speed = getVehicleSpeed(vehicle)
                local consumption = 0.1 + (speed * 0.001) -- Base consumption + speed factor
                fuel = fuel - consumption
                
                if fuel < 0 then fuel = 0 end
                setElementData(vehicle, "fuel", fuel)
                
                -- Stop engine if no fuel
                if fuel <= 0 then
                    setVehicleEngineState(vehicle, false)
                end
            end
        end
    end
end, 1000, 0) -- Every second

-- Commands
addCommandHandler("speedo", toggleSpeedometer)
addCommandHandler("speedometer", toggleSpeedometer)

-- Auto-start speedometer
startSpeedometer()

outputChatBox("🏎️ Speedometer loaded! Use /speedo to toggle", 0, 255, 127)
