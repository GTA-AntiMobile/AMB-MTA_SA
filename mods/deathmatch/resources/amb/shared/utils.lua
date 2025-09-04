-- AMB Roleplay Shared Utilities
-- Common utility functions used across client and server
-- String Utilities
function string.split(str, delimiter)
    local result = {}
    local pattern = string.format("([^%s]+)", delimiter)
    for match in string.gmatch(str, pattern) do
        table.insert(result, match)
    end
    return result
end

function string.trim(str)
    return string.match(str, "^%s*(.-)%s*$")
end

function string.capitalize(str)
    return string.upper(string.sub(str, 1, 1)) .. string.lower(string.sub(str, 2))
end

function string.titleCase(str)
    return string.gsub(str, "(%a)([%w_']*)", function(first, rest)
        return string.upper(first) .. string.lower(rest)
    end)
end

function string.contains(str, substr)
    return string.find(str, substr, 1, true) ~= nil
end

function string.startsWith(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end

function string.endsWith(str, suffix)
    return string.sub(str, -string.len(suffix)) == suffix
end

-- Table Utilities
function table.copy(orig)
    local copy = {}
    for k, v in pairs(orig) do
        if type(v) == "table" then
            copy[k] = table.copy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

function table.merge(t1, t2)
    local result = table.copy(t1)
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

function table.size(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function table.contains(t, value)
    for _, v in pairs(t) do
        if v == value then
            return true
        end
    end
    return false
end

function table.findKey(t, value)
    for k, v in pairs(t) do
        if v == value then
            return k
        end
    end
    return nil
end

function table.removeValue(t, value)
    for i = #t, 1, -1 do
        if t[i] == value then
            table.remove(t, i)
        end
    end
end

function table.isEmpty(t)
    return next(t) == nil
end

-- Math Utilities
function math.round(num, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(num * mult + 0.5) / mult
end

function math.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function math.lerp(a, b, t)
    return a + (b - a) * t
end

function math.distance2D(x1, y1, x2, y2)
    local dx = x2 - x1
    local dy = y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

function math.distance3D(x1, y1, z1, x2, y2, z2)
    local dx = x2 - x1
    local dy = y2 - y1
    local dz = z2 - z1
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

function math.angleBetweenPoints(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

-- Color Utilities
function hexToRGB(hex)
    hex = hex:gsub("#", "")
    return {tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)}
end

function rgbToHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

function interpolateColor(color1, color2, factor)
    factor = math.clamp(factor, 0, 1)
    return {math.floor(color1[1] + (color2[1] - color1[1]) * factor),
            math.floor(color1[2] + (color2[2] - color1[2]) * factor),
            math.floor(color1[3] + (color2[3] - color1[3]) * factor)}
end

-- Time Utilities
function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

function formatDuration(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60

    local parts = {}
    if days > 0 then
        table.insert(parts, days .. " day" .. (days ~= 1 and "s" or ""))
    end
    if hours > 0 then
        table.insert(parts, hours .. " hour" .. (hours ~= 1 and "s" or ""))
    end
    if minutes > 0 then
        table.insert(parts, minutes .. " minute" .. (minutes ~= 1 and "s" or ""))
    end
    if secs > 0 then
        table.insert(parts, secs .. " second" .. (secs ~= 1 and "s" or ""))
    end

    if #parts == 0 then
        return "0 seconds"
    elseif #parts == 1 then
        return parts[1]
    else
        return table.concat(parts, ", ", 1, #parts - 1) .. " and " .. parts[#parts]
    end
end

function getTimeStamp()
    return os.time()
end

function formatTimeStamp(timestamp, format)
    format = format or "%Y-%m-%d %H:%M:%S"
    return os.date(format, timestamp)
end

function parseMoney(str)
    str = str:gsub("[$,]", "")
    return tonumber(str) or 0
end

-- Validation Utilities
function isValidEmail(email)
    local pattern = "^[%w%.%-_]+@[%w%.%-_]+%.%a+$"
    return string.match(email, pattern) ~= nil
end

function isValidUsername(username)
    if not username or #username < 3 or #username > 24 then
        return false
    end
    return string.match(username, "^[%w_]+$") ~= nil
end

function isValidPassword(password)
    if not password or #password < 6 or #password > 128 then
        return false
    end
    return true
end

function isValidName(name)
    if not name or #name < 2 or #name > 24 then
        return false
    end
    return string.match(name, "^[%a%s]+$") ~= nil
end

-- Position Utilities
function isPlayerNearPosition(player, x, y, z, radius)
    if not isElement(player) then
        return false
    end
    local px, py, pz = getElementPosition(player)
    return math.distance3D(px, py, pz, x, y, z) <= radius
end

function getClosestPlayer(player, maxDistance)
    if not isElement(player) then
        return nil
    end

    local px, py, pz = getElementPosition(player)
    local closestPlayer = nil
    local closestDistance = maxDistance or math.huge

    for _, target in ipairs(getElementsByType("player")) do
        if target ~= player then
            local tx, ty, tz = getElementPosition(target)
            local distance = math.distance3D(px, py, pz, tx, ty, tz)

            if distance < closestDistance then
                closestDistance = distance
                closestPlayer = target
            end
        end
    end

    return closestPlayer, closestDistance
end

-- Random Utilities
function getRandomElement(t)
    if #t == 0 then
        return nil
    end
    return t[math.random(#t)]
end

function shuffle(t)
    local result = table.copy(t)
    for i = #result, 2, -1 do
        local j = math.random(i)
        result[i], result[j] = result[j], result[i]
    end
    return result
end

function randomFloat(min, max)
    return min + math.random() * (max - min)
end

function randomBool(chance)
    chance = chance or 0.5
    return math.random() < chance
end

-- File Utilities (Server-side only)
function fileExists(path)
    local file = fileOpen(path)
    if file then
        fileClose(file)
        return true
    end
    return false
end

function readFileContents(path)
    local file = fileOpen(path)
    if not file then
        return nil
    end

    local content = fileRead(file, fileGetSize(file))
    fileClose(file)
    return content
end

function writeFileContents(path, content)
    local file = fileCreate(path)
    if not file then
        return false
    end

    fileWrite(file, content)
    fileClose(file)
    return true
end

-- Chat Utilities
function removeColorCodes(text)
    return string.gsub(text, "#%x%x%x%x%x%x", "")
end

function stripColors(text)
    return removeColorCodes(text)
end

function wordWrap(text, width)
    local lines = {}
    local currentLine = ""

    for word in text:gmatch("%S+") do
        if #currentLine + #word + 1 <= width then
            if #currentLine > 0 then
                currentLine = currentLine .. " " .. word
            else
                currentLine = word
            end
        else
            if #currentLine > 0 then
                table.insert(lines, currentLine)
                currentLine = word
            else
                table.insert(lines, word)
            end
        end
    end

    if #currentLine > 0 then
        table.insert(lines, currentLine)
    end

    return lines
end

-- Debug Utilities
function debugPrint(...)
    if DEBUG_MODE then
        outputDebugString("[AMB DEBUG] " .. table.concat({...}, " "))
    end
end

function dumpTable(t, indent)
    indent = indent or 0
    local spacing = string.rep("  ", indent)

    for k, v in pairs(t) do
        if type(v) == "table" then
            print(spacing .. tostring(k) .. " = {")
            dumpTable(v, indent + 1)
            print(spacing .. "}")
        else
            print(spacing .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

function getCustomModelData(modelID, dataTable, baseStartID)
    for idx, v in ipairs(dataTable) do
        local expectedID = baseStartID + (idx - 1)
        if expectedID == modelID then
            return v
        end
    end
    return nil
end

function isValidVehicleModel(id)
    return id >= 400 and id <= 611 or id >= 30001 and id <= 40000
end

function isCustomSkin(id)
    return id >= 20001 and id <= 21000
end

function isCustomObject(id)
    return id >= 19001 and id <= 19999
end

-- Helper: lấy real model id từ baseId theo map của client
function getRealModelID(player, mtype, baseID)
    local map = player:getData("customModelMap")
    if map and map[mtype] and map[mtype][baseID] then
        return map[mtype][baseID]
    end
    return baseID -- fallback về ID gốc nếu không có custom
end

-- Dynamic vehicle folder scanner - fully automatic
local function scanVehicleFolderStructure()
    local vehicles = {}
    outputDebugString("[SCAN] Starting automatic vehicle folder scan...")

    -- Function to scan a specific path for .dff files
    local function scanPath(path, baseModel, folderName)
        outputDebugString("[SCAN] Scanning path: " .. path)

        -- Try a range of common custom vehicle IDs
        for modelId = 30001, 30050 do
            local dffFile = path .. "/" .. modelId .. ".dff"
            local txdFile = path .. "/" .. modelId .. ".txd"

            if fileExists(dffFile) and fileExists(txdFile) then
                table.insert(vehicles, {
                    id = modelId,
                    name = folderName,
                    baseModel = baseModel,
                    dffPath = dffFile,
                    txdPath = txdFile
                })
                outputDebugString("[SCAN] ✅ Found: " .. folderName .. " (ID: " .. modelId .. ") -> Base: " ..
                                      baseModel)
            end
        end
    end

    -- Scan all possible base vehicle model directories (400-611)
    for baseModel = 400, 611 do
        local basePath = ":newmodels_azul/models/vehicle/" .. baseModel

        -- Check if base directory exists
        if fileExists(basePath) then
            outputDebugString("[SCAN] Found base directory: " .. baseModel)

            -- Try to find subdirectories by checking common patterns
            local commonNames = {"Lamborghini", "BMW", "BMW 2010", "BMW 2020", "Audi", "Mercedes", "Ferrari", "Porsche",
                                 "Toyota", "Honda", "Nissan", "Mazda", "Subaru", "Mitsubishi", "Volkswagen", "Ford",
                                 "Chevrolet", "Dodge", "Jeep", "Hyundai", "Kia", "Sport", "Luxury", "Custom", "Tuned",
                                 "Modified", "Racing", "Drift"}

            for _, folderName in ipairs(commonNames) do
                local folderPath = basePath .. "/" .. folderName

                -- Check if this folder contains vehicle files
                local hasFiles = false
                for testId = 30001, 30050 do
                    if fileExists(folderPath .. "/" .. testId .. ".dff") then
                        hasFiles = true
                        break
                    end
                end

                if hasFiles then
                    scanPath(folderPath, baseModel, folderName)
                end
            end

            -- Also try scanning with exact folder names from your structure
            if baseModel == 411 then
                scanPath(basePath .. "/Lamborghini", baseModel, "Lamborghini")
            elseif baseModel == 412 then
                scanPath(basePath .. "/BMW", baseModel, "BMW")
                scanPath(basePath .. "/BMW 2010", baseModel, "BMW 2010")
            end
        end
    end

    -- If no vehicles found, try direct file scan in known locations
    if #vehicles == 0 then
        outputDebugString("[SCAN] No vehicles found, trying direct scan...")

        -- Direct check for your exact structure
        local directPaths = {{
            path = ":newmodels_azul/models/vehicle/411/Lamborghini",
            base = 411,
            name = "Lamborghini"
        }, {
            path = ":newmodels_azul/models/vehicle/412/BMW",
            base = 412,
            name = "BMW"
        }, {
            path = ":newmodels_azul/models/vehicle/412/BMW 2010",
            base = 412,
            name = "BMW 2010"
        }}

        for _, pathInfo in ipairs(directPaths) do
            scanPath(pathInfo.path, pathInfo.base, pathInfo.name)
        end
    end

    outputDebugString("[SCAN] Automatic scan complete. Found " .. #vehicles .. " vehicles")
    return vehicles
end

-- Dynamic model scanning functions for newmodels_azul
function getNewmodelsAvailableModels()
    local models = {
        vehicles = {},
        objects = {},
        peds = {}
    }

    local newmodelsResource = getResourceFromName("newmodels_azul")
    if not newmodelsResource or getResourceState(newmodelsResource) ~= "running" then
        outputDebugString("[LISTCV] newmodels_azul resource not running")
        return models
    end

    -- Try to get from exports first (preferred method)
    if exports["newmodels_azul"] and exports["newmodels_azul"].getCustomModels then
        local customModels = exports["newmodels_azul"]:getCustomModels()

        if customModels and next(customModels) then
            for id, modelData in pairs(customModels) do
                if modelData.type == "vehicle" then
                    table.insert(models.vehicles, {
                        id = id,
                        name = modelData.name or "Unknown Vehicle",
                        baseModel = modelData.baseModel
                    })
                elseif modelData.type == "object" then
                    table.insert(models.objects, {
                        id = id,
                        name = modelData.name or "Unknown Object",
                        baseModel = modelData.baseModel
                    })
                elseif modelData.type == "ped" then
                    table.insert(models.peds, {
                        id = id,
                        name = modelData.name or "Unknown Ped",
                        baseModel = modelData.baseModel
                    })
                end
            end
            return models
        end
    end

    -- Fallback: Scan folder structure directly
    outputDebugString("[LISTCV] Exports not available, scanning folder structure...")
    models.vehicles = scanVehicleFolderStructure()

    return models
end

-- Custom Vehicle Name System - Improved with /cv logic
function getCustomVehicleName(vehicle)
    if not isElement(vehicle) then
        return "Unknown Vehicle"
    end
    local id = getElementData(vehicle, "customVehicleID") or getElementModel(vehicle)
    -- Xe custom
    if id >= 30001 and id < 40000 then
        local name = getElementData(vehicle, "customVehicleName")
        if name and tostring(name) ~= "" then
            return name
        end
        -- Nếu chưa có, lấy từ mapping custom
        local models = getNewmodelsAvailableModels()
        for _, customVehicle in ipairs(models.vehicles) do
            if id == customVehicle.id then
                return customVehicle.name or ("Custom Vehicle " .. id)
            end
        end
        return "Custom Vehicle " .. id
    end
    -- Xe thường
    if id >= 400 and id <= 611 then
        return getVehicleName(vehicle) or ("Vehicle " .. id)
    end
    -- Fallback cuối cùng
    return "Unknown Vehicle " .. id
end

-- Kiểm tra khoảng cách đến bank/ATM
function isPlayerNearBankOrATM(player)
    local x, y, z = getElementPosition(player)
    for _, bank in ipairs(banks) do
        local bx, by, bz = bank[1], bank[2], bank[3]
        if getDistanceBetweenPoints3D(x, y, z, bx, by, bz) <= 15 then
            return true
        end
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

-- Export utilities to global namespace
_G.AMB_UTILS = {
    -- String utilities
    split = string.split,
    trim = string.trim,
    capitalize = string.capitalize,
    titleCase = string.titleCase,
    contains = string.contains,
    startsWith = string.startsWith,
    endsWith = string.endsWith,

    -- Table utilities
    tableCopy = table.copy,
    tableMerge = table.merge,
    tableSize = table.size,
    tableContains = table.contains,
    tableFindKey = table.findKey,
    tableRemoveValue = table.removeValue,
    tableIsEmpty = table.isEmpty,

    -- Math utilities
    round = math.round,
    clamp = math.clamp,
    lerp = math.lerp,
    distance2D = math.distance2D,
    distance3D = math.distance3D,
    angleBetweenPoints = math.angleBetweenPoints,

    -- Color utilities
    hexToRGB = hexToRGB,
    rgbToHex = rgbToHex,
    interpolateColor = interpolateColor,

    -- Time utilities
    formatTime = formatTime,
    formatDuration = formatDuration,
    getTimeStamp = getTimeStamp,
    formatTimeStamp = formatTimeStamp,

    -- Money utilities
    formatMoney = formatMoney,
    parseMoney = parseMoney,

    -- Validation utilities
    isValidEmail = isValidEmail,
    isValidUsername = isValidUsername,
    isValidPassword = isValidPassword,
    isValidName = isValidName,

    -- Position utilities
    isPlayerNearPosition = isPlayerNearPosition,
    getClosestPlayer = getClosestPlayer,

    -- Random utilities
    getRandomElement = getRandomElement,
    shuffle = shuffle,
    randomFloat = randomFloat,
    randomBool = randomBool,

    -- File utilities
    fileExists = fileExists,
    readFileContents = readFileContents,
    writeFileContents = writeFileContents,

    -- Chat utilities
    removeColorCodes = removeColorCodes,
    stripColors = stripColors,
    wordWrap = wordWrap,

    -- Debug utilities
    debugPrint = debugPrint,
    dumpTable = dumpTable
}
