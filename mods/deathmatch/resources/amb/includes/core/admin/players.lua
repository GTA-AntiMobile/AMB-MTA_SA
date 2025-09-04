-- ================================
-- AMB MTA:SA - Admin Players Management
-- Core admin commands for player management
-- ================================
-- Dummy function to prevent errors (statistics tracking can be added later)
function incrementCommandStat(category)
    -- Do nothing for now, can be implemented later for statistics
end

-- Admin player management commands
local adminPlayerCommands = {"kick", "ban", "unban", "mute", "unmute", "freeze", "unfreeze", "slap", "kill", "heal",
                             "armor", "setskin", "setinterior", "tp", "gethere", "spec", "unspec", "jail", "unjail",
                             "warn", "unwarn"}

-- Mute player command
addCommandHandler("mute", function(player, _, playerIdOrName, time, ...)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not time then
        outputChatBox("USAGE: /mute [player] [time_minutes] [reason]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local muteTime = tonumber(time)
    if not muteTime or muteTime <= 0 then
        outputChatBox("Thoi gian mute khong hop le!", player, 255, 0, 0)
        return
    end

    local reason = table.concat({...}, " ") or "Khong co ly do"

    -- Set player mute
    setElementData(target, "muted", true)
    setElementData(target, "muteTime", getRealTime().timestamp + (muteTime * 60))
    setElementData(target, "muteReason", reason)

    outputChatBox("Ban da bi mute boi admin " .. getPlayerName(player) .. " trong " .. muteTime .. " phut. Ly do: " ..
                      reason, target, 255, 255, 0)
    outputChatBox("Ban da mute " .. getPlayerName(target) .. " trong " .. muteTime .. " phut.", player, 255, 255, 0)

    -- Auto unmute timer
    setTimer(function()
        if isElement(target) then
            setElementData(target, "muted", false)
            outputChatBox("Ban da het thoi gian bi mute.", target, 0, 255, 0)
        end
    end, muteTime * 60 * 1000, 1)

    -- Log action
    if logAdminAction then
        logAdminAction(player, "MUTE", getPlayerName(target), reason .. " (" .. muteTime .. " minutes)")
    end

    incrementCommandStat("adminCommands")
end)

-- Teleport to player command (SA-MP style: /tp [player])
addCommandHandler("tp", function(player, _, playerIdOrName)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("USAGE: /tp [player]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local x, y, z = getElementPosition(target)
    local interior = getElementInterior(target)
    local dimension = getElementDimension(target)

    -- Check if player is in a vehicle
    local vehicle = getPedOccupiedVehicle(player)
    if vehicle then
        -- Teleport the vehicle with player
        setElementPosition(vehicle, x + 2, y, z + 1) -- Offset a bit to avoid collision
        setElementInterior(vehicle, interior)
        setElementDimension(vehicle, dimension)
        outputChatBox("Ban da teleport cung xe den " .. getPlayerName(target), player, 255, 255, 0)
    else
        -- Teleport just the player
        setElementPosition(player, x + 1, y, z)
        setElementInterior(player, interior)
        setElementDimension(player, dimension)
        outputChatBox("Ban da teleport den " .. getPlayerName(target), player, 255, 255, 0)
    end

    -- Log action
    if logAdminAction then
        logAdminAction(player, "TP", getPlayerName(target),
            "Teleported to player" .. (vehicle and " (with vehicle)" or ""))
    end
end)

-- Get player here command
addCommandHandler("gethere", function(player, _, playerIdOrName)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) then
        outputChatBox("Ban khong co quyen su dung lenh nay!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("USAGE: /gethere [player]", player, 255, 255, 255)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox("Khong tim thay player!", player, 255, 0, 0)
        return
    end

    local x, y, z = getElementPosition(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)

    -- Check if target is in a vehicle
    local vehicle = getPedOccupiedVehicle(target)
    if vehicle then
        -- Teleport the vehicle with target
        setElementPosition(vehicle, x + 2, y, z + 1) -- Offset a bit to avoid collision
        setElementInterior(vehicle, interior)
        setElementDimension(vehicle, dimension)
        outputChatBox("Ban da goi " .. getPlayerName(target) .. " cung xe den ben minh", player, 255, 255, 0)
        outputChatBox("Ban da bi admin " .. getPlayerName(player) .. " goi cung xe den", target, 255, 255, 0)
    else
        -- Teleport just the target
        setElementPosition(target, x + 1, y, z)
        setElementInterior(target, interior)
        setElementDimension(target, dimension)
        outputChatBox("Ban da goi " .. getPlayerName(target) .. " den ben minh", player, 255, 255, 0)
        outputChatBox("Ban da bi admin " .. getPlayerName(player) .. " goi den", target, 255, 255, 0)
    end

    -- Log action
    if logAdminAction then
        logAdminAction(player, "GETHERE", getPlayerName(target),
            "Teleported player to admin" .. (vehicle and " (with vehicle)" or ""))
    end

    incrementCommandStat("adminCommands")
end)

-- /goto command - Teleport to locations (SA-MP style) - FIXED VERSION
addCommandHandler("goto", function(player, _, location)
    outputDebugString("[GOTO] Command called by " .. getPlayerName(player))
    outputChatBox("🔧 GOTO command received!", player, 255, 255, 0)

    -- Check admin permission: EventCreator or Admin level 1+
    local adminLevel = getElementData(player, "adminLevel") or 0
    local isEventCreator = getElementData(player, "isEventCreator") or false

    outputChatBox("Your admin level: " .. adminLevel .. ", EventCreator: " .. tostring(isEventCreator), player, 255,
        255, 0)

    if not isEventCreator and adminLevel < ADMIN_LEVELS.MODERATOR then
        outputChatBox("❌ Ban khong duoc phep su dung lenh nay (need Level 1+ or EventCreator).", player, 255, 100,
            100, false)
        return
    end

    if not location then
        outputChatBox("✅ SU DUNG: /goto [location]", player, 255, 255, 100, false)
        outputChatBox("Locations 1: LS,SF,LV,RC,ElQue,Bayside,LSVIP,SFVIP,LVVIP,Famed,MHC,stadium1", player, 255, 255,
            255, false)
        outputChatBox("Locations 2: stadium2,stadium3,stadium4,int1,bank,mall,allsaints", player, 255, 255, 255, false)
        outputChatBox("Locations 3: countygen,cracklab,gym,rodeo,flint,idlewood,fbi,island,demorgan,doc", player, 255,
            255, 255, false)
        outputChatBox("Locations 4: garagesm,garagemed,garagelg,garagexlg,cave,sfairport,dillimore", player, 255, 255,
            255, false)
        return
    end

    location = string.lower(location)
    local teleportData = {
        -- Main cities
        ls = {1529.6, -1691.2, 13.3, 0, 0},
        sf = {-1605.0, 720.0, 12.0, 0, 0},
        lv = {1699.2, 1435.1, 10.7, 0, 0},
        rc = {1253.70, 343.73, 19.41, 0, 0},

        -- VIP areas
        lsvip = {1810.39, -1601.15, 13.54, 0, 0},
        sfvip = {-2433.63, 511.45, 30.38, 0, 0},
        lvvip = {1875.7731, 1366.0796, 16.8998, 0, 0},

        -- Special locations
        bank = {1487.91, -1030.60, 23.66, 0, 0},
        mall = {1133.71, -1464.52, 15.77, 0, 0},
        allsaints = {1192.78, -1292.68, 13.38, 0, 0},
        famed = {1020.29, -1129.06, 23.87, 0, 0},
        gym = {2227.60, -1674.89, 14.62, 0, 0},
        fbi = {344.77, -1526.08, 33.28, 0, 0},

        -- Small towns
        elque = {-1446.5997, 2608.4478, 55.8359, 0, 0},
        bayside = {-2465.1348, 2333.6572, 4.8359, 0, 0},
        dillimore = {634.9734, -594.6402, 16.3359, 0, 0},
        rodeo = {587.0106, -1238.3374, 17.8049, 0, 0},
        flint = {-108.1058, -1172.5293, 2.8906, 0, 0},
        idlewood = {1955.1357, -1796.8896, 13.5469, 0, 0},

        -- Special areas
        island = {-1081.0, 4297.9, 4.4, 0, 0},
        cave = {-1993.01, -1580.44, 86.39, 0, 0},
        sfairport = {-1412.5375, -301.8998, 14.1411, 0, 0},
        cracklab = {2348.2871, -1146.8298, 27.3183, 0, 0},
        countygen = {2000.05, -1409.36, 16.99, 0, 0},

        -- Prisons
        demorgan = {112.67, 1917.55, 18.72, 0, 0},
        doc = {-2029.2322, -78.3302, 35.3203, 0, 0},
        icprison = {-2069.76, -200.05, 991.53, 10, 0},
        oocprison = {-298.13, 1881.85, 29.89, 1, 0},

        -- Stadiums (interiors)
        stadium1 = {-1424.93, -664.59, 1059.86, 4, 0},
        stadium2 = {-1395.96, -208.20, 1051.28, 7, 0},
        stadium3 = {-1410.72, 1591.16, 1052.53, 14, 0},
        stadium4 = {-1394.20, 987.62, 1023.96, 15, 0},

        -- Interior test
        int1 = {1416.107000, 0.268620, 1000.926000, 1, 0},

        -- Garages (high altitude)
        garagesm = {1198.1407, 1589.2153, 5290.2871, 0, 0},
        garagemed = {1069.1473, 1582.1029, 5290.2529, 0, 0},
        garagelg = {1192.8501, 1540.0295, 5290.2871, 0, 0},
        garagexlg = {1111.0139, 1546.9510, 5290.2793, 0, 0},

        -- Special (MHC needs custom streaming)
        mhc = {1649.7531, 1463.1614, 1151.9687, 0, 0}
    }

    local data = teleportData[location]
    if not data then
        outputChatBox("❌ Dia diem khong hop le! Su dung /goto de xem danh sach", player, 255, 100, 100, false)
        return
    end

    local x, y, z, interior, vw = data[1], data[2], data[3], data[4], data[5]

    -- Check if player is in vehicle
    local vehicle = getPedOccupiedVehicle(player)
    if vehicle then
        setElementPosition(vehicle, x, y, z)
        setElementInterior(vehicle, interior)
        setElementDimension(vehicle, vw)
    else
        setElementPosition(player, x, y, z)
    end

    setElementInterior(player, interior)
    setElementDimension(player, vw)

    -- Update player data
    local playerData = getElementData(player, "playerData") or {}
    playerData.interior = interior
    playerData.dimension = vw
    setElementData(player, "playerData", playerData)

    outputChatBox("✅ Ban da duoc dich chuyen den " .. location .. "!", player, 100, 255, 100, false)
    outputDebugString("[GOTO] " .. getPlayerName(player) .. " teleported to " .. location)
end)

-- SA-MP Style Player ID System (0-based, reuse slots)
local MAX_PLAYERS = 500
local playerSlots = {} -- Track used slots

local function getNextAvailableID()
    for i = 0, MAX_PLAYERS - 1 do
        if not playerSlots[i] then
            return i
        end
    end
    return -1 -- Server full
end

local function releasePlayerID(id)
    if id and id >= 0 and id < MAX_PLAYERS then
        playerSlots[id] = nil
    end
end

-- Initialize player IDs for players already connected (server restart handling)
addEventHandler("onResourceStart", resourceRoot, function()
    outputDebugString("[PLAYER] Initializing player IDs after resource restart...")

    -- Clear the slots table to start fresh
    playerSlots = {}

    -- Reassign IDs to all currently connected players
    for _, player in ipairs(getElementsByType("player")) do
        local playerID = getNextAvailableID()
        if playerID >= 0 then
            playerSlots[playerID] = player
            setElementData(player, "ID", playerID) -- Use "ID" consistently
            outputDebugString("[PLAYER] Reassigned ID " .. playerID .. " to " .. getPlayerName(player) ..
                                  " after restart")
        else
            outputDebugString("[PLAYER] Server full during restart! Cannot assign ID to " .. getPlayerName(player), 2)
        end
    end

    outputDebugString("[PLAYER] Player ID initialization complete. " .. #getElementsByType("player") ..
                          " players assigned IDs.")
end)

-- Assign Player ID when joining (SA-MP style: 0-based, reuse slots)
addEventHandler("onPlayerJoin", root, function()
    local playerID = getNextAvailableID()
    if playerID >= 0 then
        playerSlots[playerID] = source
        setElementData(source, "ID", playerID) -- Use "ID" consistently
        -- outputDebugString("[PLAYER] Assigned ID " .. playerID .. " to " .. getPlayerName(source))
    else
        outputDebugString("[PLAYER] Server full! Cannot assign ID to " .. getPlayerName(source), 2)
        kickPlayer(source, "Server full")
    end
end)

-- Release Player ID when quitting
addEventHandler("onPlayerQuit", root, function()
    local playerID = getElementData(source, "ID")
    if playerID and playerSlots then -- Add safety check for playerSlots table
        releasePlayerID(playerID)
        -- outputDebugString("[PLAYER] Released ID " .. playerID .. " from " .. getPlayerName(source))
    elseif playerID then
        outputDebugString("[PLAYER] Warning: Player " .. getPlayerName(source) .. " had ID " .. playerID ..
                              " but playerSlots table not available (resource stopping?)")
    end
end)

-- Clean up when resource stops (prevent errors during restart)
addEventHandler("onResourceStop", resourceRoot, function()
    outputDebugString("[PLAYER] Resource stopping - clearing player slots table")
    playerSlots = nil -- Clear the table to prevent errors during restart
end)
