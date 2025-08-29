-- ================================
-- AMB GPS Server-side Support
-- Manages custom locations and player waypoints
-- ================================

-- GPS events
addEvent("onPlayerGPSUpdate", true)
addEvent("onPlayerAddLocation", true)
addEvent("onPlayerRemoveLocation", true)

-- Player custom locations storage
local playerCustomLocations = {}

-- Server-side location database (extended)
local serverLocations = {
    -- Police stations
    ["LSPD - Pershing Square"] = {x = 1553.9, y = -1675.6, z = 16.2, type = "police"},
    ["LSPD - Vinewood"] = {x = 617.7, y = -571.2, z = 17.9, type = "police"},
    ["SFPD - Downtown"] = {x = -1605.6, y = 711.4, z = 13.9, type = "police"},
    ["LVPD - The Strip"] = {x = 2288.4, y = 2432.7, z = 10.8, type = "police"},
    
    -- Hospitals
    ["All Saints General - Downtown LS"] = {x = 1178.7, y = -1323.5, z = 14.1, type = "hospital"},
    ["County General - Jefferson"] = {x = 2034.0, y = -1401.6, z = 17.3, type = "hospital"},
    ["San Fierro Medical"] = {x = -2654.9, y = 639.4, z = 14.5, type = "hospital"},
    ["Las Venturas Hospital"] = {x = 1607.2, y = 1815.6, z = 10.8, type = "hospital"},
    
    -- Banks
    ["Bank of San Andreas - Downtown LS"] = {x = 1459.4, y = -1010.8, z = 26.8, type = "bank"},
    ["Bank of San Andreas - SF"] = {x = -1379.7, y = 492.0, z = 11.2, type = "bank"},
    ["Caligula's Bank - LV"] = {x = 2109.0, y = 1398.8, z = 11.3, type = "bank"},
    
    -- Vehicle dealerships
    ["Otto's Autos"] = {x = -1658.2, y = 1213.6, z = 21.2, type = "dealership"},
    ["Grotti Dealership - LV"] = {x = 2131.2, y = 1398.8, z = 11.3, type = "dealership"},
    ["Wang Cars"] = {x = -1955.2, y = 302.5, z = 35.5, type = "dealership"},
    
    -- Gas stations
    ["Gas Station - Grove Street"] = {x = 2202.2, y = -1948.9, z = 13.5, type = "gas"},
    ["Gas Station - SF Airport"] = {x = -1471.0, y = -79.8, z = 14.1, type = "gas"},
    ["Gas Station - LV Strip"] = {x = 1595.8, y = 2199.7, z = 10.8, type = "gas"},
    
    -- Jobs
    ["Trucking Depot - Doherty"] = {x = -2136.5, y = -247.3, z = 35.3, type = "job"},
    ["LS Docks"] = {x = 2751.8, y = -2405.3, z = 13.6, type = "job"},
    ["Airport Baggage"] = {x = 1681.4, y = -2335.0, z = 13.5, type = "job"},
    ["Pizza Stack"] = {x = 2105.5, y = -1806.5, z = 13.6, type = "job"},
}

-- Handle GPS updates from client
addEventHandler("onPlayerGPSUpdate", root, function(targetX, targetY, targetZ, description)
    local player = source
    if not player then return end
    
    -- Validate coordinates
    if type(targetX) ~= "number" or type(targetY) ~= "number" or type(targetZ) ~= "number" then
        outputChatBox("❌ Invalid GPS coordinates", player, 255, 100, 100)
        return
    end
    
    -- Store target waypoint for player
    setElementData(player, "gpsTarget", {
        x = targetX,
        y = targetY,
        z = targetZ,
        description = description or "Custom Waypoint"
    })
    
    outputChatBox("📍 GPS target set: " .. (description or "Custom location"), player, 100, 255, 100)
end)

-- Handle adding custom location
addEventHandler("onPlayerAddLocation", root, function(name, x, y, z, category)
    local player = source
    if not player then return end
    
    local playerName = getPlayerName(player)
    
    -- Initialize player locations if needed
    if not playerCustomLocations[playerName] then
        playerCustomLocations[playerName] = {}
    end
    
    -- Validate inputs
    if not name or name == "" then
        outputChatBox("❌ Location name cannot be empty", player, 255, 100, 100)
        return
    end
    
    if type(x) ~= "number" or type(y) ~= "number" or type(z) ~= "number" then
        outputChatBox("❌ Invalid coordinates", player, 255, 100, 100)
        return
    end
    
    -- Add location
    playerCustomLocations[playerName][name] = {
        x = x,
        y = y,
        z = z,
        type = category or "custom",
        added = getRealTime().timestamp
    }
    
    outputChatBox("📍 Location '" .. name .. "' saved", player, 100, 255, 100)
    outputDebugString("[GPS] " .. playerName .. " added location: " .. name)
end)

-- Handle removing custom location
addEventHandler("onPlayerRemoveLocation", root, function(name)
    local player = source
    if not player then return end
    
    local playerName = getPlayerName(player)
    
    if not playerCustomLocations[playerName] or not playerCustomLocations[playerName][name] then
        outputChatBox("❌ Location not found", player, 255, 100, 100)
        return
    end
    
    playerCustomLocations[playerName][name] = nil
    outputChatBox("📍 Location '" .. name .. "' removed", player, 100, 255, 100)
    outputDebugString("[GPS] " .. playerName .. " removed location: " .. name)
end)

-- Command to get custom locations
addCommandHandler("gpslist", function(player)
    local playerName = getPlayerName(player)
    
    if not playerCustomLocations[playerName] or not next(playerCustomLocations[playerName]) then
        outputChatBox("📍 You have no saved locations", player, 255, 255, 100)
        return
    end
    
    outputChatBox("📍 Your saved GPS locations:", player, 255, 255, 100)
    for name, data in pairs(playerCustomLocations[playerName]) do
        outputChatBox("• " .. name .. " (" .. data.type .. ")", player, 200, 200, 200)
    end
end)

-- Admin command to manage server locations
addCommandHandler("addserverlocation", function(player, cmd, name, x, y, z, category)
    local adminLevel = getElementData(player, "adminLevel") or 0
    
    if adminLevel < 3 then
        outputChatBox("❌ Insufficient admin level", player, 255, 100, 100)
        return
    end
    
    if not name or not x or not y or not z then
        outputChatBox("Usage: /addserverlocation [name] [x] [y] [z] [category]", player, 255, 255, 0)
        return
    end
    
    local coordX, coordY, coordZ = tonumber(x), tonumber(y), tonumber(z)
    if not coordX or not coordY or not coordZ then
        outputChatBox("❌ Invalid coordinates", player, 255, 100, 100)
        return
    end
    
    serverLocations[name] = {
        x = coordX,
        y = coordY,
        z = coordZ,
        type = category or "admin"
    }
    
    outputChatBox("📍 Server location '" .. name .. "' added", player, 100, 255, 100)
    outputDebugString("[GPS] Admin " .. getPlayerName(player) .. " added server location: " .. name)
end)

-- Function to get all locations for a player
function getPlayerGPSLocations(player)
    local playerName = getPlayerName(player)
    local locations = {}
    
    -- Add server locations
    for name, data in pairs(serverLocations) do
        locations[name] = data
    end
    
    -- Add player custom locations
    if playerCustomLocations[playerName] then
        for name, data in pairs(playerCustomLocations[playerName]) do
            locations[name] = data
        end
    end
    
    return locations
end

-- Export function for other resources
addEvent("onRequestGPSLocations", true)
addEventHandler("onRequestGPSLocations", root, function()
    local player = source
    local locations = getPlayerGPSLocations(player)
    triggerClientEvent(player, "onReceiveGPSLocations", player, locations)
end)

-- Clean up on player quit
addEventHandler("onPlayerQuit", root, function()
    local playerName = getPlayerName(source)
    playerCustomLocations[playerName] = nil
end)

-- Count server locations
local locationCount = 0
for _ in pairs(serverLocations) do
    locationCount = locationCount + 1
end

outputDebugString("[GPS] GPS server support loaded with " .. locationCount .. " default locations")
