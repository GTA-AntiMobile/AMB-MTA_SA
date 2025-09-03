-- ================================
-- AMB GPS Navigation System
-- Navigate to locations, players, and POIs
-- ================================

local gpsEnabled = false
local targetPosition = nil
local targetName = ""
local gpsBlip = nil
local routeMarkers = {}

-- Important locations in SA
local locations = {
    -- Los Santos
    ["lspd"] = {1554.2, -1675.6, 16.2, "Los Santos Police Department"},
    ["hospital"] = {1177.1, -1323.8, 14.1, "All Saints General Hospital"},
    ["bank"] = {1456.1, -1014.5, 26.8, "Bank of Los Santos"},
    ["dmv"] = {1435.8, -1641.2, 13.5, "Department of Motor Vehicles"},
    ["airport"] = {1681.5, -2329.8, 13.5, "Los Santos Airport"},
    ["beach"] = {228.5, -1684.8, 11.5, "Santa Maria Beach"},
    ["pier"] = {827.1, -1347.6, 13.5, "Santa Monica Pier"},
    
    -- San Fierro
    ["sfpd"] = {-1605.6, 711.9, 13.9, "San Fierro Police Department"},
    ["sfairport"] = {-1364.9, -486.3, 14.1, "San Fierro Airport"},
    ["sfgarage"] = {-1904.7, 284.5, 41.0, "Wang Cars Garage"},
    
    -- Las Venturas
    ["lvpd"] = {2287.5, 2432.1, 10.8, "Las Venturas Police Department"},
    ["lvairport"] = {1678.0, 1448.7, 10.8, "Las Venturas Airport"},
    ["casino"] = {2196.8, 1677.2, 12.4, "Four Dragons Casino"}
}

-- Create GPS blip
function createGPSBlip(x, y, z, name)
    if gpsBlip then
        destroyElement(gpsBlip)
    end
    
    gpsBlip = createBlip(x, y, z, 0, 2, 255, 0, 0, 255) -- Red blip
    setBlipVisibleDistance(gpsBlip, 999999)
    
    outputChatBox("🗺️ GPS: Route to " .. name .. " has been set", 0, 255, 127)
    
    targetPosition = {x, y, z}
    targetName = name
    gpsEnabled = true
end

-- Navigate to location
function navigateToLocation(locationName)
    if not locationName then
        outputChatBox("❌ Usage: /gps [location]", 255, 100, 100)
        outputChatBox("📍 Available locations:", 255, 255, 255)
        
        for key, data in pairs(locations) do
            outputChatBox("  • " .. key .. " - " .. data[4], 200, 200, 200)
        end
        return
    end
    
    locationName = string.lower(locationName)
    local location = locations[locationName]
    
    if not location then
        outputChatBox("❌ Location '" .. locationName .. "' not found", 255, 100, 100)
        outputChatBox("📍 Use /gps to see available locations", 255, 255, 255)
        return
    end
    
    createGPSBlip(location[1], location[2], location[3], location[4])
end

-- Navigate to player
function navigateToPlayer(playerName)
    if not playerName then
        outputChatBox("❌ Usage: /gps player [playername]", 255, 100, 100)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(playerName)
    if not targetPlayer then
        outputChatBox("❌ Player '" .. playerName .. "' not found", 255, 100, 100)
        return
    end
    
    if targetPlayer == localPlayer then
        outputChatBox("❌ You cannot navigate to yourself", 255, 100, 100)
        return
    end
    
    local x, y, z = getElementPosition(targetPlayer)
    createGPSBlip(x, y, z, "Player: " .. getPlayerName(targetPlayer))
end

-- Clear GPS
function clearGPS()
    if gpsBlip then
        destroyElement(gpsBlip)
        gpsBlip = nil
    end
    
    for _, marker in ipairs(routeMarkers) do
        if isElement(marker) then
            destroyElement(marker)
        end
    end
    routeMarkers = {}
    
    gpsEnabled = false
    targetPosition = nil
    targetName = ""
    
    outputChatBox("🗺️ GPS cleared", 255, 255, 0)
end

-- Show GPS info
function showGPSInfo()
    if not gpsEnabled or not targetPosition then
        outputChatBox("❌ No GPS destination set", 255, 100, 100)
        return
    end
    
    local px, py, pz = getElementPosition(localPlayer)
    local distance = getDistanceBetweenPoints3D(px, py, pz, targetPosition[1], targetPosition[2], targetPosition[3])
    
    outputChatBox("🗺️ GPS Info:", 0, 255, 127)
    outputChatBox("📍 Destination: " .. targetName, 255, 255, 255)
    outputChatBox("📏 Distance: " .. math.floor(distance) .. " meters", 255, 255, 255)
end

-- Draw GPS HUD
function drawGPSHUD()
    if not gpsEnabled or not targetPosition then return end
    
    local screenW, screenH = guiGetScreenSize()
    local px, py, pz = getElementPosition(localPlayer)
    local distance = getDistanceBetweenPoints3D(px, py, pz, targetPosition[1], targetPosition[2], targetPosition[3])
    
    -- GPS HUD background
    dxDrawRectangle(10, 10, 300, 80, tocolor(0, 0, 0, 150))
    dxDrawRectangle(10, 10, 300, 3, tocolor(0, 255, 127, 255)) -- Green top border
    
    -- GPS info
    dxDrawText("🗺️ GPS Navigation", 20, 20, 0, 0, tocolor(0, 255, 127, 255), 0.9, "default-bold")
    dxDrawText("📍 " .. targetName, 20, 40, 0, 0, tocolor(255, 255, 255, 255), 0.8)
    dxDrawText("📏 " .. math.floor(distance) .. " meters", 20, 60, 0, 0, tocolor(255, 255, 0, 255), 0.8)
    
    -- Direction arrow (simplified)
    local angle = math.atan2(targetPosition[2] - py, targetPosition[1] - px)
    local arrowText = "➤" -- Simple arrow
    dxDrawText(arrowText, 260, 45, 0, 0, tocolor(255, 0, 0, 255), 1.5)
    
    -- Arrival check
    if distance < 10 then
        outputChatBox("🎯 You have arrived at " .. targetName, 0, 255, 0)
        clearGPS()
    end
end

-- Main GPS command handler
function handleGPSCommand(commandName, arg1, arg2)
    if not arg1 then
        navigateToLocation(nil) -- Show help
        return
    end
    
    arg1 = string.lower(arg1)
    
    if arg1 == "clear" or arg1 == "stop" then
        clearGPS()
    elseif arg1 == "info" then
        showGPSInfo()
    elseif arg1 == "player" and arg2 then
        navigateToPlayer(arg2)
    else
        navigateToLocation(arg1)
    end
end

-- Commands
addCommandHandler("gps", handleGPSCommand)
addCommandHandler("navigate", handleGPSCommand)
addCommandHandler("nav", handleGPSCommand)

-- Auto-start GPS HUD
addEventHandler("onClientRender", root, drawGPSHUD)

outputChatBox("🗺️ GPS Navigation loaded!", 0, 255, 127)
outputChatBox("📍 Use /gps [location] or /gps player [name]", 255, 255, 255)
