-- ================================
-- AMB MTA:SA - Utility Functions
-- Common functions used throughout the gamemode
-- ================================

-- Player utility functions - SA-MP style (support both ID and name)
function getPlayerFromNameOrId(nameOrID)
    if not nameOrID then return nil end
    
    -- Try to convert to number first (player ID)
    local playerID = tonumber(nameOrID)
    if playerID then
        for _, player in ipairs(getElementsByType("player")) do
            if getElementData(player, "ID") == playerID then
                return player
            end
        end
        return nil -- Player ID not found
    end
    
    -- Search by name (exact match first, then partial)
    local nameOrID_lower = nameOrID:lower()
    local exactMatch = nil
    local partialMatches = {}
    
    for _, player in ipairs(getElementsByType("player")) do
        local playerName = getPlayerName(player):lower()
        if playerName == nameOrID_lower then
            exactMatch = player
            break
        elseif playerName:find(nameOrID_lower, 1, true) then
            table.insert(partialMatches, player)
        end
    end
    
    -- Return exact match if found
    if exactMatch then
        return exactMatch
    end
    
    -- Return single partial match, or nil if multiple/none
    if #partialMatches == 1 then
        return partialMatches[1]
    elseif #partialMatches > 1 then
        return nil, "Multiple players found" -- Too many matches
    else
        return nil, "Player not found" -- No matches
    end
end

-- Legacy compatibility functions
function getPlayerFromName(nameOrID)
    return getPlayerFromNameOrId(nameOrID)
end

function getPlayerFromPartialName(partialName)
    local player, error = getPlayerFromNameOrId(partialName)
    return player, error
end

function getPlayerById(id)
    return getPlayerFromNameOrId(tostring(id))
end

function isPlayerAdmin(player, requiredLevel)
    if not isElement(player) then return false end
    
    -- Try to get adminLevel from ElementData first (more reliable)
    local adminLevel = getElementData(player, "adminLevel")
    
    -- Fallback to playerData if ElementData not set
    if not adminLevel then
        local playerData = getElementData(player, "playerData")
        adminLevel = playerData and playerData.adminLevel or 0
    else
        adminLevel = tonumber(adminLevel) or 0
    end
    
    -- GOD level có toàn quyền
    if adminLevel == ADMIN_LEVELS.GOD then
        outputDebugString("[ADMIN] GOD level detected, granting access")
        return true
    end
    
    -- Also check if admin level is higher than GOD (just in case)
    if adminLevel >= ADMIN_LEVELS.GOD then
        outputDebugString("[ADMIN] Admin level >= GOD, granting access")
        return true
    end
    
    local result = adminLevel >= requiredLevel
    outputDebugString("[ADMIN] Access " .. (result and "GRANTED" or "DENIED") .. " (Level: " .. adminLevel .. " vs Required: " .. requiredLevel .. ")")
    return result
end

-- Custom Vehicle Name System
function getCustomVehicleName(vehicle)
    if not isElement(vehicle) or getElementType(vehicle) ~= "vehicle" then
        return "Unknown Vehicle"
    end
    
    -- Get vehicle model ID
    local modelID = getElementModel(vehicle)
    
    -- For standard GTA vehicles (400-611), ALWAYS use default names
    if modelID >= 400 and modelID <= 611 then
        return getVehicleName(vehicle) or VEHICLE_NAMES[modelID] or ("Vehicle " .. modelID)
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
    
    -- Fallback for any other vehicles (shouldn't happen normally)
    return getVehicleName(vehicle) or ("Vehicle " .. modelID)
end

-- Enhanced vehicle name function with custom support
function getVehicleNameWithCustom(vehicle)
    return getCustomVehicleName(vehicle)
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
    minLevel = minLevel or ADMIN_LEVELS.MODERATOR
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
