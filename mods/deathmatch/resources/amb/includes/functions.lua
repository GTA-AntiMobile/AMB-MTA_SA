-- ================================
-- AMB MTA:SA - Utility Functions
-- Common functions used throughout the gamemode
-- ================================

-- Player utility functions
function getPlayerFromPartialName(partialName)
    if not partialName then return nil end
    partialName = partialName:lower()
    
    -- First try exact match
    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerName(player):lower() == partialName then
            return player
        end
    end
    
    -- Then try partial match
    for _, player in ipairs(getElementsByType("player")) do
        if getPlayerName(player):lower():find(partialName, 1, true) then
            return player
        end
    end
    
    return nil
end

function isPlayerAdmin(player, requiredLevel)
    if not isElement(player) then return false end
    local adminLevel = getElementData(player, "adminLevel") or 0
    return adminLevel >= requiredLevel
end

-- Permission system for role-based access control with GOD support
function hasPermission(player, permission, level)
    if not isElement(player) then return false end
    
    level = level or 1
    
    -- Get admin level from both playerData and elementData
    local playerData = getElementData(player, "playerData")
    local adminLevel = getElementData(player, "adminLevel") or 0
    
    -- Use the higher value from either source, ensure it's a number
    if playerData and playerData.adminLevel then
        local dataAdminLevel = tonumber(playerData.adminLevel) or 0
        adminLevel = math.max(tonumber(adminLevel) or 0, dataAdminLevel)
    else
        adminLevel = tonumber(adminLevel) or 0
    end
    
    outputDebugString("[PERMISSION] Player " .. getPlayerName(player) .. " has admin level: " .. adminLevel .. ", checking " .. permission .. " level " .. level)
    
    -- GOD level (99999) has all permissions
    if adminLevel >= 99999 then
        outputDebugString("[PERMISSION] GOD level access granted")
        return true
    end
    
    if permission == "admin" then
        return adminLevel >= level
        
    elseif permission == "police" then
        local job = getElementData(player, "job") or ""
        local faction = getElementData(player, "faction") or ""
        return job == "police" or faction == "LSPD" or faction == "SFPD" or faction == "LVPD" or hasPermission(player, "admin", ADMIN_LEVELS.HELPER)
        
    elseif permission == "vip" then
        local vipLevel = getElementData(player, "vipLevel") or 0
        return vipLevel >= level
        
    elseif permission == "helper" then
        local isHelper = getElementData(player, "helper") or false
        return isHelper or hasPermission(player, "admin", ADMIN_LEVELS.HELPER)
        
    elseif permission == "mechanic" then
        local job = getElementData(player, "job") or ""
        return job == "mechanic" or hasPermission(player, "admin", ADMIN_LEVELS.HELPER)
        
    elseif permission == "lawyer" then
        local job = getElementData(player, "job") or ""
        return job == "lawyer" or hasPermission(player, "admin", ADMIN_LEVELS.HELPER)
        
    elseif permission == "taxi" then
        local job = getElementData(player, "job") or ""
        return job == "taxi" or hasPermission(player, "admin", ADMIN_LEVELS.HELPER)
        
    end
    
    return false
end

function formatMoney(amount)
    local formatted = tostring(amount)
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then
            break
        end
    end
    return formatted
end

function sendMessageToAdmins(message, minLevel)
    minLevel = minLevel or ADMIN_LEVEL_MODERATOR
    for _, player in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(player, minLevel) then
            outputChatBox(message, player, 255, 255, 0)
        end
    end
end

function logAdminAction(admin, action, target, details)
    local timestamp = getRealTime().timestamp
    local logData = {
        admin = getPlayerName(admin),
        adminSerial = getPlayerSerial(admin),
        action = action,
        target = target,
        details = details,
        timestamp = timestamp
    }
    
    -- Save to database or file
    -- This would connect to your logging system
    print("[ADMIN LOG] " .. getPlayerName(admin) .. " used " .. action .. " on " .. target .. " - " .. details)
end

function logVehiclePurchase(player, vehicle, dealership)
    local logData = {
        player = getPlayerName(player),
        playerSerial = getPlayerSerial(player),
        vehicle = vehicle.name,
        model = vehicle.model,
        price = vehicle.price,
        dealership = dealership,
        timestamp = getRealTime().timestamp
    }
    
    print("[VEHICLE LOG] " .. getPlayerName(player) .. " purchased " .. vehicle.name .. " for $" .. formatMoney(vehicle.price))
end

-- Distance and position functions
function getDistance2D(x1, y1, x2, y2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

function getDistance3D(x1, y1, z1, x2, y2, z2)
    return math.sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)
end

function isPlayerInRangeOfPoint(player, range, x, y, z)
    if not isElement(player) then return false end
    local px, py, pz = getElementPosition(player)
    return getDistance3D(px, py, pz, x, y, z) <= range
end

-- Time and date functions
function getTimeString()
    local time = getRealTime()
    return string.format("%02d:%02d:%02d", time.hour, time.minute, time.second)
end

function getDateString()
    local time = getRealTime()
    return string.format("%02d/%02d/%04d", time.monthday, time.month + 1, time.year + 1900)
end

function getTimestamp()
    return getRealTime().timestamp
end

-- Text formatting functions
function removeColorCodes(text)
    return text:gsub("#%x%x%x%x%x%x", "")
end

function capitalizeFirst(str)
    return str:sub(1,1):upper() .. str:sub(2):lower()
end

function splitString(str, delimiter)
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)"
    for match in str:gmatch(pattern) do
        table.insert(result, match)
    end
    return result
end

-- Vehicle functions
function getVehicleOccupants(vehicle)
    local occupants = {}
    local maxSeats = getVehicleMaxPassengers(vehicle) or 4
    
    for seat = 0, maxSeats do
        local occupant = getVehicleOccupant(vehicle, seat)
        if occupant then
            table.insert(occupants, occupant)
        end
    end
    
    return occupants
end

function isVehicleOwner(player, vehicle)
    if not isElement(player) or not isElement(vehicle) then return false end
    local owner = getElementData(vehicle, "owner")
    return owner == getPlayerName(player)
end

-- Custom utility functions (avoiding MTA built-in conflicts)
function getRandomFloat(min, max)
    return min + (max - min) * math.random()
end

function tableCount(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
end

function tableContains(tbl, element)
    for _, value in pairs(tbl) do
        if value == element then
            return true
        end
    end
    return false
end

-- Validation functions
function isValidName(name)
    if not name or #name < 3 or #name > 20 then return false end
    return name:match("^[a-zA-Z_]+$") ~= nil
end

function isValidPassword(password)
    if not password or #password < 4 or #password > 50 then return false end
    return true
end

function isValidEmail(email)
    if not email then return false end
    return email:match("^[%w%.%-_]+@[%w%.%-_]+%.%w+$") ~= nil
end

-- Color functions
function hexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber(hex:sub(1,2), 16), tonumber(hex:sub(3,4), 16), tonumber(hex:sub(5,6), 16)
end

function rgbToHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

-- Security functions
function sanitizeInput(input)
    if not input then return "" end
    -- Remove potentially dangerous characters
    input = input:gsub("[<>\"'&]", "")
    return input:sub(1, 100) -- Limit length
end

function isValidSerial(serial)
    return serial and #serial == 32 and serial:match("^%x+$") ~= nil
end

-- Database utility functions (placeholders for actual implementation)
function escapeString(str)
    if not str then return "" end
    return str:gsub("'", "''"):gsub("\\", "\\\\")
end

-- Debug and development functions
function debugMessage(message, player)
    if player and isPlayerAdmin(player, ADMIN_LEVEL_ADMIN) then
        outputChatBox("[DEBUG] " .. tostring(message), player, 255, 255, 0)
    else
        print("[DEBUG] " .. tostring(message))
    end
end

function dumpTable(table, player)
    if type(table) ~= "table" then return end
    
    local function serialize(obj, depth)
        depth = depth or 0
        if depth > 3 then return "..." end
        
        local str = "{\n"
        for k, v in pairs(obj) do
            str = str .. string.rep("  ", depth + 1) .. tostring(k) .. " = "
            if type(v) == "table" then
                str = str .. serialize(v, depth + 1)
            else
                str = str .. tostring(v)
            end
            str = str .. ",\n"
        end
        str = str .. string.rep("  ", depth) .. "}"
        return str
    end
    
    local result = serialize(table)
    if player then
        outputChatBox(result, player, 255, 255, 0)
    else
        print(result)
    end
end

print("🔧 Functions loaded")
