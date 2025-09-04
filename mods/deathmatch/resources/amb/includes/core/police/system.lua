-- ================================
-- AMB MTA:SA - Police System
-- Police commands and functionality
-- ================================
-- Police team/faction data
local speedCameras = {}
local nextCameraID = 1
local buggedPlayers = {}
local policeTeams = {
    ["LSPD"] = {
        name = "Los Santos Police Department",
        color = {0, 0, 255},
        vehicles = {596, 597, 598, 599, 427, 523}, -- Police cars, bikes
        weapons = {3, 22, 23, 24, 25, 29, 31}, -- Nightstick, pistol, silenced, deagle, shotgun, MP5, M4
        headquarters = {1554.8, -1675.6, 16.2},
        garage = {1588.2, -1638.1, 13.5}
    },
    ["SFPD"] = {
        name = "San Fierro Police Department",
        color = {0, 0, 255},
        vehicles = {596, 597, 598, 599, 427, 523},
        weapons = {3, 22, 23, 24, 25, 29, 31},
        headquarters = {-2451.2, 503.4, 30.0},
        garage = {-2425.1, 523.7, 29.9}
    },
    ["LVPD"] = {
        name = "Las Venturas Police Department",
        color = {0, 0, 255},
        vehicles = {596, 597, 598, 599, 427, 523},
        weapons = {3, 22, 23, 24, 25, 29, 31},
        headquarters = {2275.3, 2477.8, 10.8},
        garage = {2312.1, 2456.9, 3.2}
    }
}

-- Police ranks
local policeRanks = {
    [0] = "Cadet",
    [1] = "Officer",
    [2] = "Corporal",
    [3] = "Sergeant",
    [4] = "Lieutenant",
    [5] = "Captain",
    [6] = "Chief"
}

-- Arrest system
function arrestPlayer(cop, suspect, reason, time)
    if not isElement(cop) or not isElement(suspect) then
        return false
    end
    if not isPlayerCop(cop) then
        return false
    end
    if getElementData(suspect, "arrested") then
        return false
    end

    time = time or 300 -- 5 minutes default
    reason = reason or "No reason specified"

    -- Set arrest data
    setElementData(suspect, "arrested", true)
    setElementData(suspect, "arrestTime", time)
    setElementData(suspect, "arrestReason", reason)
    setElementData(suspect, "arrestedBy", getPlayerName(cop))

    -- Teleport to jail
    local jailPos = getJailPosition()
    setElementPosition(suspect, jailPos.x, jailPos.y, jailPos.z)
    setElementInterior(suspect, jailPos.interior)
    setElementDimension(suspect, jailPos.dimension)

    -- Remove weapons
    takeAllWeapons(suspect)

    -- Start timer
    setTimer(function()
        if isElement(suspect) and getElementData(suspect, "arrested") then
            releasePlayer(suspect)
        end
    end, time * 1000, 1)

    -- Notifications
    outputChatBox(COLOR_ORANGE .. "You have been arrested by " .. getPlayerName(cop) .. " for: " .. reason, suspect)
    outputChatBox(COLOR_ORANGE .. "Jail time: " .. time .. " seconds", suspect)
    outputChatBox(COLOR_GREEN .. "You arrested " .. getPlayerName(suspect) .. " for: " .. reason, cop)

    -- Log action
    logPoliceAction(cop, "arrest", getPlayerName(suspect), reason .. " (" .. time .. "s)")

    return true
end

-- Release player from jail
function releasePlayer(player)
    if not isElement(player) then
        return false
    end
    if not getElementData(player, "arrested") then
        return false
    end

    -- Remove arrest data
    setElementData(player, "arrested", false)
    setElementData(player, "arrestTime", nil)
    setElementData(player, "arrestReason", nil)
    setElementData(player, "arrestedBy", nil)

    -- Teleport to hospital
    local hospitalPos = {1172.0, -1323.4, 15.4, 270}
    setElementPosition(player, hospitalPos[1], hospitalPos[2], hospitalPos[3])
    setElementRotation(player, 0, 0, hospitalPos[4])
    setElementInterior(player, 0)
    setElementDimension(player, 0)

    outputChatBox(COLOR_GREEN .. "You have been released from jail.", player)
    return true
end

-- Check if player is a cop
local function isPlayerCop(player)
    if not isElement(player) then
        return false
    end
    local team = getPlayerTeam(player)
    if not team then
        return false
    end
    local teamName = getTeamName(team)
    return policeTeams[teamName] ~= nil
end

local function getPoliceRank(player)
    local playerData = getElementData(player, "playerData") or {}
    return playerData.factionRank or playerData.rank or 0
end

-- Get jail position
function getJailPosition()
    return {
        x = 264.3,
        y = 77.5,
        z = 1001.0,
        interior = 6,
        dimension = 1
    }
end

-- BUG SYSTEM COMMANDS INTEGRATION
local buggedPlayers = {}
local function getPlayerDepartment(player)
    local playerData = getElementData(player, "playerData")
    if not playerData then
        return 0
    end

    return playerData.department or playerData.faction or 0
end

addCommandHandler("clearbugs", function(player)
    if not isPlayerCop(player) or getPoliceRank(player) < 6 then
        outputChatBox("❌ Chi Chief+ moi clear duoc bugs.", player, 255, 100, 100)
        return
    end

    local clearedCount = 0
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        local buggedBy = getElementData(targetPlayer, "player.bugged")
        if buggedBy then
            removeElementData(targetPlayer, "player.bugged")
            clearedCount = clearedCount + 1
        end
    end

    outputChatBox(string.format("✅ Da clear %d bugs.", clearedCount), player, 0, 255, 0)
end)

addCommandHandler("placebug", function(player, cmd, targetName)
    if not targetName then
        outputChatBox("Su dung: /placebug [player_name]", player, 255, 255, 255)
        return
    end

    if not isPlayerCop(player) or getPoliceRank(player) < 4 then
        outputChatBox("❌ Can rank 4+ de place bug.", player, 255, 100, 100)
        return
    end

    local targetPlayer = getPlayerFromName(targetName)
    if not targetPlayer then
        outputChatBox("❌ Player not found.", player, 255, 100, 100)
        return
    end

    if getElementData(targetPlayer, "player.bugged") then
        outputChatBox("❌ Player da bi bug roi.", player, 255, 100, 100)
        return
    end

    setElementData(targetPlayer, "player.bugged", getPlayerName(player))
    outputChatBox(string.format("✅ Da place bug tren %s", getPlayerName(targetPlayer)), player, 0, 255, 0)
end)

addCommandHandler("listbugs", function(player)
    -- Check if player is a cop
    local job = getElementData(player, "player.job") or 0
    local rank = getElementData(player, "player.rank") or 0
    local member = getElementData(player, "player.member") or 0
    local leader = getElementData(player, "player.leader") or 0

    -- Check if player is police (job 1) or similar law enforcement
    if job ~= 1 and member ~= 1 then -- Assuming 1 is police
        outputChatBox("Ban khong the su dung lenh nay.", player, 255, 100, 100)
        return
    end

    -- Check if player has leader flag and sufficient rank for bug access
    local requiredRank = 6 -- Assuming bug access requires rank 6+
    if leader ~= member or rank < requiredRank then
        outputChatBox("Ban khong the su dung lenh nay.", player, 255, 100, 100)
        return
    end

    outputChatBox("List of deployed Bugs:", player, 0, 255, 0)

    local bugCount = 0
    -- List online bugged players
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        local buggedBy = getElementData(targetPlayer, "player.bugged")
        if buggedBy == member then
            outputChatBox("- " .. getPlayerName(targetPlayer) .. " [ONLINE]", player, 0, 255, 0)
            bugCount = bugCount + 1
        end
    end

    -- Query offline bugged players
    local query = "SELECT username FROM accounts WHERE bugged = " .. member .. " AND online = 0"
    dbQuery(function(queryHandle)
        local result = dbPoll(queryHandle, 0)
        if result and #result > 0 then
            for _, row in ipairs(result) do
                outputChatBox("- " .. row.username .. " [OFFLINE]", player, 0, 255, 0)
                bugCount = bugCount + 1
            end
        end

        if bugCount == 0 then
            outputChatBox("No bugged players found for your department.", player, 255, 255, 0)
        else
            outputChatBox("Total bugged players: " .. bugCount, player, 0, 255, 0)
        end
    end, database, query)
end)

addCommandHandler("removebug", function(player, cmd, targetName)
    if not targetName then
        outputChatBox("USAGE: /removebug [player_name]", player, 255, 255, 255)
        return
    end

    -- Check if player is a cop
    local job = getElementData(player, "player.job") or 0
    local rank = getElementData(player, "player.rank") or 0
    local member = getElementData(player, "player.member") or 0

    if job ~= 1 and member ~= 1 then
        outputChatBox("Ban khong the su dung lenh nay.", player, 255, 100, 100)
        return
    end

    local requiredRank = 4
    if rank < requiredRank then
        outputChatBox("Ban khong co rank du de su dung lenh nay.", player, 255, 100, 100)
        return
    end

    local targetPlayer = getPlayerFromName(targetName)
    if not targetPlayer then
        outputChatBox("Player not found.", player, 255, 100, 100)
        return
    end

    local buggedBy = getElementData(targetPlayer, "player.bugged")
    if not buggedBy or buggedBy ~= member then
        outputChatBox("Player is not bugged by your department.", player, 255, 100, 100)
        return
    end

    -- Remove bug
    removeElementData(targetPlayer, "player.bugged")

    outputChatBox("Bug removed from " .. getPlayerName(targetPlayer), player, 0, 255, 0)
    outputChatBox("The bug has been removed.", targetPlayer, 0, 255, 0)

    outputDebugString("[POLICE] " .. getPlayerName(player) .. " removed bug from " .. getPlayerName(targetPlayer))
end)

-- Save speed camera to database
local function saveSpeedCamera(camera)
    local query = string.format(
        "INSERT INTO speed_cameras (id, x, y, z, speed_limit, creator, created_date) VALUES (%d, %f, %f, %f, %d, '%s', '%s')",
        camera.id, camera.x, camera.y, camera.z, camera.speedLimit, camera.creator, camera.created)
    dbExec(database, query)
end

local function getNearestSpeedCamera(player, maxDistance)
    local x, y, z = getElementPosition(player)
    local nearestCamera = nil
    local nearestDistance = maxDistance

    for _, camera in pairs(speedCameras) do
        local distance = getDistanceBetweenPoints3D(x, y, z, camera.x, camera.y, camera.z)
        if distance < nearestDistance then
            nearestDistance = distance
            nearestCamera = camera
        end
    end

    return nearestCamera
end

local function createSpeedCamera(player, speedLimit)
    local x, y, z = getElementPosition(player)

    -- Check if there's already a camera nearby
    if getNearestSpeedCamera(player, 5.0) then
        outputChatBox("Da co speed camera gan vi tri nay roi! (trong ban kinh 5m)", player, 255, 100, 100)
        return
    end

    local camera = {
        id = nextCameraID,
        x = x,
        y = y,
        z = z,
        speedLimit = speedLimit,
        creator = getPlayerName(player),
        created = getRealTime().timestamp
    }

    speedCameras[nextCameraID] = camera
    saveSpeedCamera(camera)

    outputChatBox(string.format("Da tao speed camera ID %d tai vi tri hien tai - Speed limit: %d km/h", nextCameraID,
        speedLimit), player, 0, 255, 0)

    nextCameraID = nextCameraID + 1
end

local function deleteSpeedCamera(cameraID)
    if speedCameras[cameraID] then
        speedCameras[cameraID] = nil

        -- Remove from database
        local query = string.format("DELETE FROM speed_cameras WHERE id = %d", cameraID)
        dbExec(database, query)

        return true
    end
    return false
end

local function listAllSpeedCameras(player)
    local cameraCount = 0
    for _ in pairs(speedCameras) do
        cameraCount = cameraCount + 1
    end

    if cameraCount == 0 then
        outputChatBox("Khong co speed camera nao duoc tao.", player, 255, 255, 0)
        return
    end

    outputChatBox("Danh sach Speed Cameras (" .. cameraCount .. " cameras):", player, 0, 255, 255)

    for _, camera in pairs(speedCameras) do
        local message = string.format("ID %d: Speed Limit %d km/h - Creator: %s", camera.id, camera.speedLimit,
            camera.creator)
        outputChatBox(message, player, 255, 255, 255)
    end
end

addCommandHandler("speedcam", function(player)
    if isPedInVehicle(player) then
        outputChatBox("Ban khong the speedcam khi dang tren xe.", player, 128, 128, 128)
        return
    end

    local isPoliceLeader = isPlayerCop(player) and getPoliceRank(player) >= 6
    local isHighAdmin = (getElementData(player, "playerData") or {}).adminLevel >= 3

    if not isPoliceLeader and not isHighAdmin then
        outputChatBox("Ban khong duoc phep su dung lenh nay.", player, 128, 128, 128)
        return
    end

    outputChatBox("🎯 SPEEDCAM MENU:", player, 255, 255, 100)
    outputChatBox("1. /createspeedcam [speed_limit] - Tao speedcam", player, 255, 255, 255)
    outputChatBox("2. /editspeedcam [new_limit] - Sua speedcam gan nhat", player, 255, 255, 255)
    outputChatBox("3. /delspeedcam - Xoa speedcam gan nhat", player, 255, 255, 255)
    outputChatBox("4. /listspeedcams - Danh sach tat ca speedcam", player, 255, 255, 255)
end)

addCommandHandler("createspeedcam", function(player, cmd, speedLimit)
    if not speedLimit then
        outputChatBox("Su dung: /createspeedcam [speed_limit]", player, 255, 255, 255)
        return
    end

    local limit = tonumber(speedLimit)
    if not limit or limit <= 0 or limit > 300 then
        outputChatBox("❌ Speed limit khong hop le (1-300 km/h).", player, 255, 100, 100)
        return
    end

    if not isPlayerCop(player) or getPoliceRank(player) < 6 then
        outputChatBox("❌ Chi Chief+ moi tao duoc speedcam.", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local camera = {
        id = nextCameraID,
        x = x,
        y = y,
        z = z,
        speedLimit = limit,
        creator = getPlayerName(player)
    }

    speedCameras[nextCameraID] = camera
    nextCameraID = nextCameraID + 1

    outputChatBox(string.format("✅ Da tao speedcam ID %d - Limit: %d km/h", camera.id, limit), player, 0, 255, 0)
end)

-- Handle speed camera dialogs
addEvent("onPlayerDialogResponse", true)
addEventHandler("onPlayerDialogResponse", root, function(dialogID, button, item, text)
    if dialogID == "SPEEDCAM_MAIN" and button == 1 then
        local player = source

        if item == 0 then -- Create speed camera
            showDialog(player, "SPEEDCAM_CREATE", "Tao Speed Camera", "Nhap gioi han toc do (km/h):", "Tao", "Huy")

        elseif item == 1 then -- Edit speed camera
            local nearestCamera = getNearestSpeedCamera(player, 10.0)
            if nearestCamera then
                setElementData(player, "editingCamera", nearestCamera.id)
                local dialogText = string.format("Speed Limit hien tai: %d km/h\nNhap speed limit moi:",
                    nearestCamera.speedLimit)
                showDialog(player, "SPEEDCAM_EDIT", "Chinh sua Speed Camera", dialogText, "Cap nhat", "Huy")
            else
                outputChatBox("Khong co speed camera nao gan ban (trong ban kinh 10m).", player, 255, 100, 100)
            end

        elseif item == 2 then -- Delete speed camera
            local nearestCamera = getNearestSpeedCamera(player, 10.0)
            if nearestCamera then
                deleteSpeedCamera(nearestCamera.id)
                outputChatBox("Da xoa speed camera ID: " .. nearestCamera.id, player, 0, 255, 0)
            else
                outputChatBox("Khong co speed camera nao gan ban (trong ban kinh 10m).", player, 255, 100, 100)
            end

        elseif item == 3 then -- Get nearest camera
            local nearestCamera = getNearestSpeedCamera(player, 50.0)
            if nearestCamera then
                local x, y, z = getElementPosition(player)
                local distance = getDistanceBetweenPoints3D(x, y, z, nearestCamera.x, nearestCamera.y, nearestCamera.z)

                outputChatBox(string.format("Speed Camera gan nhat: ID %d, Speed Limit: %d km/h, Distance: %.1fm",
                    nearestCamera.id, nearestCamera.speedLimit, distance), player, 255, 255, 0)
            else
                outputChatBox("Khong co speed camera nao gan ban (trong ban kinh 50m).", player, 255, 100, 100)
            end

        elseif item == 4 then -- List all cameras
            listAllSpeedCameras(player)
        end

    elseif dialogID == "SPEEDCAM_CREATE" and button == 1 then
        local speedLimit = tonumber(text)
        if speedLimit and speedLimit > 0 and speedLimit <= 300 then
            createSpeedCamera(source, speedLimit)
        else
            outputChatBox("Speed limit khong hop le! (1-300 km/h)", source, 255, 100, 100)
        end

    elseif dialogID == "SPEEDCAM_EDIT" and button == 1 then
        local speedLimit = tonumber(text)
        local cameraID = getElementData(source, "editingCamera")

        if speedLimit and speedLimit > 0 and speedLimit <= 300 and cameraID and speedCameras[cameraID] then
            speedCameras[cameraID].speedLimit = speedLimit

            -- Update database
            local query = string.format("UPDATE speed_cameras SET speed_limit = %d WHERE id = %d", speedLimit, cameraID)
            dbExec(database, query)

            outputChatBox(string.format("Da cap nhat speed camera ID %d - Speed limit: %d km/h", cameraID, speedLimit),
                source, 0, 255, 0)
        else
            outputChatBox("Speed limit khong hop le! (1-300 km/h)", source, 255, 100, 100)
        end

        removeElementData(source, "editingCamera")
    end
end)

-- Police chat command
addCommandHandler("d", function(player, cmd, ...)
    local playerData = getElementData(player, "playerData") or {}

    -- Check if player is police
    if not isPlayerCop(player) then
        outputChatBox("❌ Ban khong phai la canh sat.", player, 255, 100, 100)
        return
    end

    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /d [tin nhan]", player, 255, 255, 255)
        return
    end

    local playerName = getPlayerName(player)
    local rank = getPoliceRank(player)
    local rankNames = {
        [1] = "Cadet",
        [2] = "Officer",
        [3] = "Detective",
        [4] = "Sergeant",
        [5] = "Lieutenant",
        [6] = "Captain",
        [7] = "Chief"
    }
    local rankName = rankNames[rank] or "Officer"

    -- Send to all police members
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        if isPlayerCop(targetPlayer) then
            outputChatBox(string.format("📻 [PD] %s %s: %s", rankName, playerName, message), targetPlayer, 100, 150,
                255)
        end
    end

    outputDebugString("[POLICE CHAT] " .. playerName .. ": " .. message)
end)

-- Police command: /arrest
-- ===========================
addCommandHandler("arrest", function(player, cmd, fineAmount, jailTime, bailOption, bailPrice)
    if not isElement(player) then
        return
    end

    local playerData = getElementData(player, "playerData") or {}

    -- 1️⃣ Check if player is law enforcement
    if not playerData.faction or not (playerData.faction == 1 or playerData.faction == 2) then
        outputChatBox("❌ Bạn không phải nhân viên thực thi pháp luật.", player, 255, 100, 100)
        return
    end

    -- 2️⃣ Check if player is at arrest point
    local atArrestPoint, stationName = isAtArrestPoint(player)
    if not atArrestPoint then
        outputChatBox("❌ Bạn không ở gần điểm bắt giữ nào.", player, 255, 100, 100)
        return
    end

    -- 3️⃣ Validate command arguments
    fineAmount = tonumber(fineAmount)
    jailTime = tonumber(jailTime)
    bailOption = tonumber(bailOption)
    bailPrice = tonumber(bailPrice)

    if not fineAmount or fineAmount < 1 or fineAmount > 30000 then
        outputChatBox("❌ Tiền phạt phải từ $1 đến $30,000.", player, 255, 100, 100)
        return
    end
    if not jailTime or jailTime < 1 or jailTime > 30 then
        outputChatBox("❌ Thời gian giam giữ phải từ 1-30 phút.", player, 255, 100, 100)
        return
    end
    if bailOption ~= 0 and bailOption ~= 1 then
        outputChatBox("❌ Tùy chọn bảo lãnh phải là 0 hoặc 1.", player, 255, 100, 100)
        return
    end
    if not bailPrice or bailPrice < 0 or bailPrice > 100000 then
        outputChatBox("❌ Giá bảo lãnh phải từ $0 đến $100,000.", player, 255, 100, 100)
        return
    end

    -- 4️⃣ Find nearest suspect
    local px, py, pz = getElementPosition(player)
    local suspect = nil
    local minDist = 5.0

    for _, target in ipairs(getElementsByType("player")) do
        if target ~= player then
            local tx, ty, tz = getElementPosition(target)
            local dist = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)
            if dist <= minDist then
                suspect = target
                minDist = dist
            end
        end
    end

    if not suspect then
        outputChatBox("❌ Không có nghi phạm nào gần bạn.", player, 255, 100, 100)
        return
    end

    -- 5️⃣ Check suspect requirements
    local suspectData = getElementData(suspect, "playerData") or {}
    local wantedLevel = suspectData.wantedLevel or 0
    local isCuffed = suspectData.handcuffed or false

    if not isCuffed then
        outputChatBox("❌ Nghi phạm phải bị còng tay trước khi bắt giữ.", player, 255, 100, 100)
        return
    end
    if wantedLevel < 1 and not isJudge(player) then
        outputChatBox("❌ Nghi phạm phải có ít nhất 1 sao wanted.", player, 255, 100, 100)
        return
    end

    -- 6️⃣ Store arrest data for report
    setElementData(player, "arrestData", {
        suspect = suspect,
        fine = fineAmount,
        jailTime = jailTime,
        bailOption = bailOption,
        bailPrice = bailPrice,
        station = stationName
    })

    -- Prompt officer to enter arrest report
    local msg = string.format(
        "Hãy viết báo cáo ngắn gọn về việc bắt giữ %s.\nTối thiểu 30 ký tự, tối đa 128 ký tự.",
        getPlayerName(suspect))
    ShowPlayerDialog(player, DIALOG_ARRESTREPORT, DIALOG_STYLE_INPUT, "Báo cáo bắt giữ", msg, "Gửi", "")

    -- 7️⃣ Teleport suspect to jail
    setElementPosition(suspect, 197.6, 173.8, 1003.0) -- Jail coords
    setElementInterior(suspect, 3)
    setElementDimension(suspect, 1)

    -- 8️⃣ Update suspect data
    suspectData.arrested = true
    suspectData.arrestTime = getRealTime().timestamp + jailTime * 60
    suspectData.arrestOfficer = getPlayerName(player)
    suspectData.arrestReason = "Vi phạm pháp luật" -- default, can update via report
    suspectData.handcuffed = false
    setElementData(suspect, "playerData", suspectData)

    -- 9️⃣ Broadcast messages
    outputChatBox(string.format("🚔 Bạn đã bắt giữ %s trong %d phút.", getPlayerName(suspect), jailTime),
        player, 0, 255, 0)
    outputChatBox(string.format("🏢 Bạn đã bị Officer %s bắt giữ trong %d phút.", getPlayerName(player),
        jailTime), suspect, 255, 100, 100)

    for _, cop in ipairs(getElementsByType("player")) do
        local copData = getElementData(cop, "playerData")
        if copData and copData.faction == 1 and cop ~= player then
            outputChatBox(string.format("📻 Officer %s đã bắt giữ %s (%d phút)", getPlayerName(player),
                getPlayerName(suspect), jailTime), cop, 100, 150, 255)
        end
    end

    -- 10️⃣ Start jail timer
    local jailTimer = setTimer(function()
        local currentTime = getElementData(suspect, "playerData").arrestTime or 0
        local remaining = currentTime - getRealTime().timestamp
        if remaining <= 0 then
            -- Release suspect
            local sData = getElementData(suspect, "playerData")
            sData.arrested = false
            sData.arrestTime = nil
            sData.arrestReason = nil
            sData.arrestOfficer = nil
            setElementData(suspect, "playerData", sData)

            setElementPosition(suspect, 1545.8, -1675.6, 13.6) -- Release coords
            setElementInterior(suspect, 0)
            setElementDimension(suspect, 0)

            outputChatBox("✅ Bạn đã được thả tự do!", suspect, 100, 255, 100)
            outputChatBox(string.format("ℹ %s đã được thả tự do.", getPlayerName(suspect)),
                getRootElement(), 255, 255, 100)
            killTimer(jailTimer)
        end
    end, 1000, 0)

    setElementData(suspect, "jailTimer", jailTimer)
    triggerClientEvent(suspect, "onPlayerArrested", suspect, getPlayerName(player), jailTime)

    -- 11️⃣ Debug log
    outputDebugString(string.format("[ARREST] Officer %s arrested %s for %d minutes, fine: $%d, bail: %d ($%d)",
        getPlayerName(player), getPlayerName(suspect), jailTime, fineAmount, bailOption, bailPrice))
end)

-- Police command: /release
addCommandHandler("release", function(player, _, playerIdOrName)
    if not isPlayerAdmin(player, ADMIN_LEVELS.MODERATOR) and not isPlayerCop(player) then
        outputChatBox(COLOR_RED .. "You don't have permission to use this command!", player)
        return
    end

    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /release [player]", player)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox(COLOR_RED .. "Player not found!", player)
        return
    end

    if not getElementData(target, "arrested") then
        outputChatBox(COLOR_RED .. "This player is not arrested!", player)
        return
    end

    if releasePlayer(target) then
        outputChatBox(COLOR_GREEN .. "You released " .. getPlayerName(target) .. " from jail.", player)
        logPoliceAction(player, "release", getPlayerName(target), "Released from jail")
    end
end)

-- Police command: /wanted
addCommandHandler("wanted", function(player, _, playerIdOrName, level, ...)
    if not isPlayerCop(player) then
        outputChatBox(COLOR_RED .. "You are not a police officer!", player)
        return
    end

    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /wanted [player] [level 1-6] [reason]", player)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox(COLOR_RED .. "Player not found!", player)
        return
    end

    level = tonumber(level) or 1
    if level < 1 or level > 6 then
        outputChatBox(COLOR_RED .. "Wanted level must be between 1 and 6!", player)
        return
    end

    local reason = table.concat({...}, " ") or "Criminal activity"

    setPlayerWantedLevel(target, level)
    setElementData(target, "wantedReason", reason)
    setElementData(target, "wantedBy", getPlayerName(player))

    outputChatBox(COLOR_ORANGE .. "You have been given wanted level " .. level .. " by " .. getPlayerName(player),
        target)
    outputChatBox(COLOR_ORANGE .. "Reason: " .. reason, target)
    outputChatBox(COLOR_GREEN .. "You gave " .. getPlayerName(target) .. " wanted level " .. level, player)

    sendMessageToTeam(getPlayerTeam(player),
        COLOR_BLUE .. getPlayerName(target) .. " is now wanted (Level " .. level .. ") - " .. reason)
    logPoliceAction(player, "wanted", getPlayerName(target), "Level " .. level .. " - " .. reason)
end)

-- Police command: /unwanted
addCommandHandler("unwanted", function(player, _, playerIdOrName)
    if not isPlayerCop(player) then
        outputChatBox(COLOR_RED .. "You are not a police officer!", player)
        return
    end

    if not playerIdOrName then
        outputChatBox(COLOR_YELLOW .. "Usage: /unwanted [player]", player)
        return
    end

    local target = getPlayerFromNameOrId(playerIdOrName)
    if not target then
        outputChatBox(COLOR_RED .. "Player not found!", player)
        return
    end

    if getPlayerWantedLevel(target) == 0 then
        outputChatBox(COLOR_RED .. "This player is not wanted!", player)
        return
    end

    setPlayerWantedLevel(target, 0)
    setElementData(target, "wantedReason", nil)
    setElementData(target, "wantedBy", nil)

    outputChatBox(COLOR_GREEN .. "Your wanted level has been cleared by " .. getPlayerName(player), target)
    outputChatBox(COLOR_GREEN .. "You cleared " .. getPlayerName(target) .. "'s wanted level.", player)

    logPoliceAction(player, "unwanted", getPlayerName(target), "Wanted level cleared")
end)

-- Police command: /ticket
addCommandHandler("ticket", function(player, cmd, playerIdOrName, amount, ...)
    local playerData = getElementData(player, "playerData") or {}

    -- Check if player is police
    if not playerData.faction or playerData.faction ~= 1 then
        outputChatBox("❌ Ban khong phai la canh sat.", player, 255, 100, 100)
        return
    end

    if not playerIdOrName or not amount then
        outputChatBox("Su dung: /ticket [player_id] [amount] [reason]", player, 255, 255, 255)
        return
    end

    local ticketAmount = tonumber(amount)
    if not ticketAmount or ticketAmount <= 0 or ticketAmount > 50000 then
        outputChatBox("❌ So tien phat khong hop le ($1-$50,000).", player, 255, 100, 100)
        return
    end

    local reason = table.concat({...}, " ") or "Vi pham luat giao thong"

    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end

    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 10 then
        outputChatBox("❌ Ban qua xa de ticket.", player, 255, 100, 100)
        return
    end

    local officerName = getPlayerName(player)
    local targetName = getPlayerName(targetPlayer)

    -- Deduct money from target
    local targetData = getElementData(targetPlayer, "playerData") or {}
    local targetMoney = targetData.money or 0

    if targetMoney < ticketAmount then
        outputChatBox(string.format("❌ %s khong co du tien de tra phat.", targetName), player, 255, 100, 100)
        return
    end

    targetData.money = targetMoney - ticketAmount
    setElementData(targetPlayer, "playerData", targetData)

    outputChatBox(string.format("🎫 Ban da phat %s $%d. Ly do: %s", targetName, ticketAmount, reason), player, 0, 255,
        0)
    outputChatBox(string.format("🎫 Ban da bi Officer %s phat $%d. Ly do: %s", officerName, ticketAmount, reason),
        targetPlayer, 255, 200, 100)

    outputDebugString("[TICKET] " .. officerName .. " ticketed " .. targetName .. " $" .. ticketAmount)
end)

-- Handcuff command (cuff)
addCommandHandler("cuff", function(player, cmd, playerIdOrName)
    local playerData = getElementData(player, "playerData") or {}

    -- Check if player is police
    if not playerData.faction or playerData.faction ~= 1 then
        outputChatBox("❌ Ban khong phai la canh sat.", player, 255, 100, 100)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /cuff [player_id]", player, 255, 255, 255)
        return
    end

    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end

    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 3 then
        outputChatBox("❌ Ban qua xa de cuff.", player, 255, 100, 100)
        return
    end

    local officerName = getPlayerName(player)
    local targetName = getPlayerName(targetPlayer)
    local targetData = getElementData(targetPlayer, "playerData") or {}

    if targetData.handcuffed then
        -- Uncuff
        targetData.handcuffed = false
        setElementFrozen(targetPlayer, false)

        outputChatBox(string.format("🔓 Ban da uncuff %s.", targetName), player, 0, 255, 0)
        outputChatBox(string.format("🔓 Ban da duoc Officer %s uncuff.", officerName), targetPlayer, 0, 255, 0)
    else
        -- Cuff
        targetData.handcuffed = true
        setElementFrozen(targetPlayer, true)

        outputChatBox(string.format("🔒 Ban da cuff %s.", targetName), player, 0, 255, 0)
        outputChatBox(string.format("🔒 Ban da bi Officer %s cuff.", officerName), targetPlayer, 255, 100, 100)
    end

    setElementData(targetPlayer, "playerData", targetData)

    outputDebugString("[CUFF] " .. officerName .. " cuffed/uncuffed " .. targetName)
end)

-- Police command: /backup
addCommandHandler("backup", function(player, cmd, location)
    local playerData = getElementData(player, "playerData") or {}

    -- Check if player is police
    if not playerData.faction or playerData.faction ~= 1 then
        outputChatBox("❌ Ban khong phai la canh sat.", player, 255, 100, 100)
        return
    end

    local officerName = getPlayerName(player)
    local x, y, z = getElementPosition(player)
    local backupLocation = location or "Vi tri hien tai"

    -- Send backup request to all police
    for _, cop in ipairs(getElementsByType("player")) do
        local copData = getElementData(cop, "playerData")
        if copData and copData.faction == 1 then
            outputChatBox(string.format("🚨 [BACKUP] Officer %s can ho tro tai %s", officerName, backupLocation), cop,
                255, 0, 0)
            if cop ~= player then
                setBlipAttachedTo(player, 1, 2, 255, 0, 0, 255, 0, 16383.0, cop) -- Create blip for other officers
            end
        end
    end

    outputChatBox("🚨 Da gui yeu cau backup den tat ca officers.", player, 255, 0, 0)

    outputDebugString("[BACKUP] " .. officerName .. " requested backup at " .. backupLocation)
end)

-- Police command: /tazer
addCommandHandler("tazer", function(player, cmd, playerIdOrName)
    local playerData = getElementData(player, "playerData") or {}

    -- Check if player is police
    if not playerData.faction or playerData.faction ~= 1 then
        outputChatBox("❌ Ban khong phai la canh sat.", player, 255, 100, 100)
        return
    end

    -- Check if player has tazer
    if not playerData.tazer then
        outputChatBox("❌ Ban khong co tazer.", player, 255, 100, 100)
        return
    end

    if not playerIdOrName then
        outputChatBox("Su dung: /tazer [player_id]", player, 255, 255, 255)
        return
    end

    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end

    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end

    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 10 then
        outputChatBox("❌ Ban qua xa de tazer.", player, 255, 100, 100)
        return
    end

    local officerName = getPlayerName(player)
    local targetName = getPlayerName(targetPlayer)

    -- Tazer effect
    local targetData = getElementData(targetPlayer, "playerData") or {}
    targetData.tazed = true
    setElementData(targetPlayer, "playerData", targetData)

    -- Freeze for 5 seconds
    setElementFrozen(targetPlayer, true)
    setTimer(function()
        if isElement(targetPlayer) then
            setElementFrozen(targetPlayer, false)
            local tData = getElementData(targetPlayer, "playerData") or {}
            tData.tazed = false
            setElementData(targetPlayer, "playerData", tData)
        end
    end, 5000, 1)

    outputChatBox(string.format("⚡ Ban da tazer %s.", targetName), player, 255, 255, 0)
    outputChatBox(string.format("⚡ Ban da bi Officer %s tazer!", officerName), targetPlayer, 255, 255, 0)

    -- Notify nearby players
    for _, nearPlayer in ipairs(getElementsByType("player")) do
        if nearPlayer ~= player and nearPlayer ~= targetPlayer then
            local nx, ny, nz = getElementPosition(nearPlayer)
            if getDistanceBetweenPoints3D(px, py, pz, nx, ny, nz) < 20 then
                outputChatBox(string.format("⚡ Officer %s da tazer %s!", officerName, targetName), nearPlayer, 255,
                    255, 0)
            end
        end
    end

    outputDebugString("[TAZER] " .. officerName .. " tazed " .. targetName)
end)

-- Police roadblock command
addCommandHandler("roadblock", function(player, cmd)
    local playerData = getElementData(player, "playerData") or {}

    -- Check if player is police with minimum rank
    if not playerData.faction or playerData.faction ~= 1 or (playerData.factionRank or 1) < 3 then
        outputChatBox("❌ Ban can it nhat rank Detective de su dung roadblock.", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local _, _, rz = getElementRotation(player)

    -- Create roadblock vehicles
    local roadblock1 = createVehicle(596, x + 3, y, z, 0, 0, rz + 45) -- Police car
    local roadblock2 = createVehicle(596, x - 3, y + 2, z, 0, 0, rz - 45) -- Police car

    if roadblock1 and roadblock2 then
        setElementData(roadblock1, "roadblock", true)
        setElementData(roadblock2, "roadblock", true)
        setElementData(roadblock1, "officer", getPlayerName(player))
        setElementData(roadblock2, "officer", getPlayerName(player))

        -- Set timer to remove roadblock after 10 minutes
        setTimer(function()
            if isElement(roadblock1) then
                destroyElement(roadblock1)
            end
            if isElement(roadblock2) then
                destroyElement(roadblock2)
            end
        end, 600000, 1)

        outputChatBox("🚧 Da dat roadblock. Se tu dong xoa sau 10 phut.", player, 0, 255, 0)

        -- Notify all police
        for _, cop in ipairs(getElementsByType("player")) do
            local copData = getElementData(cop, "playerData")
            if copData and copData.faction == 1 and cop ~= player then
                outputChatBox(string.format("🚧 Officer %s da dat roadblock.", getPlayerName(player)), cop, 100, 150,
                    255)
            end
        end

        outputDebugString("[ROADBLOCK] " .. getPlayerName(player) .. " placed roadblock")
    else
        outputChatBox("❌ Khong the dat roadblock tai vi tri nay.", player, 255, 100, 100)
    end
end)

-- Police checkpoint command  
addCommandHandler("checkpoint", function(player, cmd)
    local playerData = getElementData(player, "playerData") or {}

    -- Check if player is police
    if not playerData.faction or playerData.faction ~= 1 then
        outputChatBox("❌ Ban khong phai la canh sat.", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)

    -- Create checkpoint for all players
    for _, p in ipairs(getElementsByType("player")) do
        if p ~= player then
            setBlipAttachedTo(player, 41, 2, 0, 0, 255, 255, 0, 16383.0, p)
        end
    end

    outputChatBox("🔍 Da dat checkpoint tai vi tri hien tai.", player, 0, 255, 0)

    -- Notify all players
    outputChatBox(string.format("🔍 CHECKPOINT: Police da dat checkpoint. Tat ca xe cu phai dung kiem tra."), root, 0,
        150, 255)

    outputDebugString("[CHECKPOINT] " .. getPlayerName(player) .. " set checkpoint")
end)

-- Utility functions
function sendMessageToTeam(team, message)
    if not team then
        return
    end
    for _, player in ipairs(getPlayersInTeam(team)) do
        outputChatBox(message, player)
    end
end

function logPoliceAction(cop, action, target, details)
    local logData = {
        cop = getPlayerName(cop),
        copSerial = getPlayerSerial(cop),
        action = action,
        target = target,
        details = details,
        timestamp = getRealTime().timestamp
    }

    print("[POLICE LOG] " .. getPlayerName(cop) .. " used " .. action .. " on " .. target .. " - " .. details)
end

-- Initialize police teams
addEventHandler("onResourceStart", resourceRoot, function()
    for teamName, teamData in pairs(policeTeams) do
        local team = createTeam(teamName, teamData.color[1], teamData.color[2], teamData.color[3])
        if team then
            print("Created police team: " .. teamName)
        end
    end
end)

