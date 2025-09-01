-- ========================================
-- AMB Admin Commands System (MTA Server)
-- Migrated from server/commands.lua for better organization
-- Uses centralized ADMIN_LEVELS from shared/enums.lua
-- ========================================

-- Helper functions for SA-MP style playerId conversion
local function getPlayerFromId(playerId)
    -- Convert SA-MP style playerId (0-based) to MTA player element
    playerId = tonumber(playerId)
    if not playerId or playerId < 0 then return nil end

    local players = getElementsByType("player")
    for i, player in ipairs(players) do
        local playerSlot = getElementData(player, "playerSlot") or (i - 1)
        if playerSlot == playerId then
            return player
        end
    end
    return nil
end

local function getPlayerSlot(player)
    -- Get SA-MP style playerId (0-based) from MTA player element
    if not isElement(player) then return -1 end
    return getElementData(player, "playerSlot") or -1
end

local function getPlayerNameById(playerId)
    local player = getPlayerFromId(playerId)
    return player and getPlayerName(player) or "Invalid"
end

-- Permission check function with GOD level support (SA-MP style)
-- Note: Using global isPlayerAdmin function from functions.lua

-- Function to get player from name or return error
local function getPlayerFromName(nameOrId)
    -- Try by ID first (SA-MP style)
    local playerId = tonumber(nameOrId)
    if playerId then
        local player = getPlayerFromId(playerId)
        if player then
            return player, nil
        end
    end

    -- Try by name (exact match first)
    local players = getElementsByType("player")
    for _, player in ipairs(players) do
        if string.lower(getPlayerName(player)) == string.lower(nameOrId) then
            return player, nil
        end
    end

    -- Try partial name match
    local matches = {}
    for _, player in ipairs(players) do
        if string.find(string.lower(getPlayerName(player)), string.lower(nameOrId), 1, true) then
            table.insert(matches, player)
        end
    end

    if #matches == 1 then
        return matches[1], nil
    elseif #matches > 1 then
        return nil, "Multiple players found with that name."
    end

    return nil, "Player not found."
end

-- /tp command moved to players.lua for better integration

-- /goto command - Teleport to locations (SA-MP style) - FIXED VERSION
addCommandHandler("goto", function(player, _, location)
    outputDebugString("[GOTO] Command called by " .. getPlayerName(player))
    outputChatBox("🔧 GOTO command received!", player, 255, 255, 0)

    -- Check admin permission: EventCreator or Admin level 1+
    local adminLevel = getElementData(player, "adminLevel") or 0
    local isEventCreator = getElementData(player, "isEventCreator") or false

    outputChatBox("Your admin level: " .. adminLevel .. ", EventCreator: " .. tostring(isEventCreator), player, 255, 255,
        0)

    if not isEventCreator and adminLevel < ADMIN_LEVELS.MODERATOR then
        outputChatBox("❌ Ban khong duoc phep su dung lenh nay (need Level 1+ or EventCreator).", player, 255, 100, 100,
            false)
        return
    end

    if not location then
        outputChatBox("✅ SU DUNG: /goto [location]", player, 255, 255, 100, false)
        outputChatBox("Locations 1: LS,SF,LV,RC,ElQue,Bayside,LSVIP,SFVIP,LVVIP,Famed,MHC,stadium1", player, 255,
            255, 255, false)
        outputChatBox("Locations 2: stadium2,stadium3,stadium4,int1,bank,mall,allsaints", player, 255, 255, 255,
            false)
        outputChatBox("Locations 3: countygen,cracklab,gym,rodeo,flint,idlewood,fbi,island,demorgan,doc", player,
            255, 255, 255, false)
        outputChatBox("Locations 4: garagesm,garagemed,garagelg,garagexlg,cave,sfairport,dillimore", player, 255,
            255, 255, false)
        return
    end

    location = string.lower(location)
    local teleportData = {
        -- Main cities
        ls = { 1529.6, -1691.2, 13.3, 0, 0 },
        sf = { -1605.0, 720.0, 12.0, 0, 0 },
        lv = { 1699.2, 1435.1, 10.7, 0, 0 },
        rc = { 1253.70, 343.73, 19.41, 0, 0 },

        -- VIP areas
        lsvip = { 1810.39, -1601.15, 13.54, 0, 0 },
        sfvip = { -2433.63, 511.45, 30.38, 0, 0 },
        lvvip = { 1875.7731, 1366.0796, 16.8998, 0, 0 },

        -- Special locations
        bank = { 1487.91, -1030.60, 23.66, 0, 0 },
        mall = { 1133.71, -1464.52, 15.77, 0, 0 },
        allsaints = { 1192.78, -1292.68, 13.38, 0, 0 },
        famed = { 1020.29, -1129.06, 23.87, 0, 0 },
        gym = { 2227.60, -1674.89, 14.62, 0, 0 },
        fbi = { 344.77, -1526.08, 33.28, 0, 0 },

        -- Small towns
        elque = { -1446.5997, 2608.4478, 55.8359, 0, 0 },
        bayside = { -2465.1348, 2333.6572, 4.8359, 0, 0 },
        dillimore = { 634.9734, -594.6402, 16.3359, 0, 0 },
        rodeo = { 587.0106, -1238.3374, 17.8049, 0, 0 },
        flint = { -108.1058, -1172.5293, 2.8906, 0, 0 },
        idlewood = { 1955.1357, -1796.8896, 13.5469, 0, 0 },

        -- Special areas
        island = { -1081.0, 4297.9, 4.4, 0, 0 },
        cave = { -1993.01, -1580.44, 86.39, 0, 0 },
        sfairport = { -1412.5375, -301.8998, 14.1411, 0, 0 },
        cracklab = { 2348.2871, -1146.8298, 27.3183, 0, 0 },
        countygen = { 2000.05, -1409.36, 16.99, 0, 0 },

        -- Prisons
        demorgan = { 112.67, 1917.55, 18.72, 0, 0 },
        doc = { -2029.2322, -78.3302, 35.3203, 0, 0 },
        icprison = { -2069.76, -200.05, 991.53, 10, 0 },
        oocprison = { -298.13, 1881.85, 29.89, 1, 0 },

        -- Stadiums (interiors)
        stadium1 = { -1424.93, -664.59, 1059.86, 4, 0 },
        stadium2 = { -1395.96, -208.20, 1051.28, 7, 0 },
        stadium3 = { -1410.72, 1591.16, 1052.53, 14, 0 },
        stadium4 = { -1394.20, 987.62, 1023.96, 15, 0 },

        -- Interior test
        int1 = { 1416.107000, 0.268620, 1000.926000, 1, 0 },

        -- Garages (high altitude)
        garagesm = { 1198.1407, 1589.2153, 5290.2871, 0, 0 },
        garagemed = { 1069.1473, 1582.1029, 5290.2529, 0, 0 },
        garagelg = { 1192.8501, 1540.0295, 5290.2871, 0, 0 },
        garagexlg = { 1111.0139, 1546.9510, 5290.2793, 0, 0 },

        -- Special (MHC needs custom streaming)
        mhc = { 1649.7531, 1463.1614, 1151.9687, 0, 0 }
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

-- server/fly_server.lua

local flyPlayers = {} -- lưu trạng thái fly mỗi player
-- Toggle fly mode
addCommandHandler("fly", function(player)
    if not isPlayerAdmin(player, 2) then -- MODERATOR trở lên
        outputChatBox("Bạn không có quyền!", player, 255, 0, 0)
        return
    end

    local enabled = not flyPlayers[player]
    flyPlayers[player] = enabled

    -- gửi trạng thái xuống client
    triggerClientEvent(player, "flyMode:set", player, enabled)

    if enabled then
        outputChatBox("✈️ Fly mode ON", player, 0, 255, 0)
    else
        outputChatBox("✈️ Fly mode OFF", player, 255, 0, 0)
    end
end)

-- Cleanup khi player quit
addEventHandler("onPlayerQuit", root, function()
    flyPlayers[source] = nil
end)

outputDebugString("[AMB] Admin Commands loaded successfully!")
