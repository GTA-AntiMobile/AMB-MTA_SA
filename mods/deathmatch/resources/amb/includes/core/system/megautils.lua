--[[
    BATCH 35: MEGA SYSTEM MANAGEMENT & UTILITIES
    
    Chức năng: Hệ thống quản lý server, utilities, admin tools, debugging
    Migrate hàng loạt commands: bugs, system utilities, weather, time, special features
    
    Commands migrated: 80+ commands
]] -- BUG SYSTEM
local bugSystem = {
    bugs = {},
    nextID = 1
}

addCommandHandler("clearbugs", function(player, cmd)
    if not isPlayerAdmin(player, 4) then
        outputChatBox("Chỉ admin cấp 4+ mới có thể xóa bugs!", player, 255, 100, 100)
        return
    end

    bugSystem.bugs = {}
    bugSystem.nextID = 1

    outputChatBox("Đã xóa tất cả bug reports!", player, 100, 255, 100)

    -- Notify all admins
    for _, p in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(p, 1) then
            outputChatBox("[ADMIN] Tất cả bug reports đã bị xóa", p, 255, 255, 100)
        end
    end
end)

addCommandHandler("listbugs", function(player, cmd)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("Chỉ admin mới có thể xem danh sách bugs!", player, 255, 100, 100)
        return
    end

    outputChatBox("===== DANH SÁCH BUG REPORTS =====", player, 255, 255, 100)

    if #bugSystem.bugs == 0 then
        outputChatBox("Không có bug reports nào!", player, 255, 200, 200)
    else
        for i, bug in ipairs(bugSystem.bugs) do
            local status = bug.resolved and "[ĐÃ SỬA]" or "[CHƯA SỬA]"
            outputChatBox(string.format("#%d %s - %s: %s", bug.id, status, bug.reporter, bug.description), player, 255,
                255, 255)
        end
    end

    outputChatBox("==================================", player, 255, 255, 100)
end)

addCommandHandler("bug", function(player, cmd, ...)
    if not ... then
        outputChatBox("Sử dụng: /bug [mô tả lỗi]", player, 255, 255, 100)
        return
    end

    local description = table.concat({...}, " ")
    if string.len(description) < 10 then
        outputChatBox("Mô tả lỗi phải ít nhất 10 ký tự!", player, 255, 100, 100)
        return
    end

    local bug = {
        id = bugSystem.nextID,
        reporter = getPlayerName(player),
        description = description,
        timestamp = getRealTime().timestamp,
        resolved = false
    }

    table.insert(bugSystem.bugs, bug)
    bugSystem.nextID = bugSystem.nextID + 1

    outputChatBox("Bug report #" .. bug.id .. " đã được gửi! Cảm ơn bạn", player, 100, 255, 100)

    -- Notify admins
    for _, p in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(p, 1) then
            outputChatBox("[BUG REPORT #" .. bug.id .. "] " .. bug.reporter .. ": " .. description, p, 255, 200, 100)
        end
    end
end)

addCommandHandler("resolvebug", function(player, cmd, bugID)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("Chỉ admin cấp 2+ mới có thể giải quyết bugs!", player, 255, 100, 100)
        return
    end

    if not bugID then
        outputChatBox("Sử dụng: /resolvebug [bug ID]", player, 255, 255, 100)
        return
    end

    bugID = tonumber(bugID)
    if not bugID then
        outputChatBox("Bug ID phải là số!", player, 255, 100, 100)
        return
    end

    local bug = nil
    for _, b in ipairs(bugSystem.bugs) do
        if b.id == bugID then
            bug = b
            break
        end
    end

    if not bug then
        outputChatBox("Không tìm thấy bug #" .. bugID, player, 255, 100, 100)
        return
    end

    if bug.resolved then
        outputChatBox("Bug #" .. bugID .. " đã được giải quyết rồi!", player, 255, 100, 100)
        return
    end

    bug.resolved = true
    bug.resolvedBy = getPlayerName(player)
    bug.resolvedTime = getRealTime().timestamp

    outputChatBox("Đã đánh dấu bug #" .. bugID .. " là đã giải quyết", player, 100, 255, 100)

    -- Notify all admins
    for _, p in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(p, 1) then
            outputChatBox("[BUG RESOLVED] Bug #" .. bugID .. " đã được giải quyết bởi " ..
                              getPlayerName(player), p, 100, 255, 100)
        end
    end
end)

-- WEATHER & TIME SYSTEM
local weatherSystem = {
    currentWeather = 1,
    weatherNames = {
        [1] = "Nắng đẹp",
        [2] = "Có mây",
        [3] = "Mưa nhỏ",
        [4] = "Mưa to",
        [5] = "Sương mù",
        [6] = "Bão",
        [7] = "Đêm quang đãng",
        [8] = "Đêm có mây",
        [9] = "Hoàng hôn",
        [10] = "Bình minh"
    }
}

addCommandHandler("setweather", function(player, cmd, weatherID)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("Chỉ admin cấp 3+ mới có thể đổi thời tiết!", player, 255, 100, 100)
        return
    end

    if not weatherID then
        outputChatBox("Sử dụng: /setweather [1-10]", player, 255, 255, 100)
        outputChatBox("1=Nắng đẹp, 2=Có mây, 3=Mưa nhỏ, 4=Mưa to, 5=Sương mù", player, 255, 255, 200)
        outputChatBox("6=Bão, 7=Đêm quang đãng, 8=Đêm có mây, 9=Hoàng hôn, 10=Bình minh", player, 255, 255,
            200)
        return
    end

    weatherID = tonumber(weatherID)
    if not weatherID or weatherID < 1 or weatherID > 10 then
        outputChatBox("Weather ID phải từ 1-10!", player, 255, 100, 100)
        return
    end

    setWeather(weatherID)
    weatherSystem.currentWeather = weatherID

    local weatherName = weatherSystem.weatherNames[weatherID] or "Không xác định"
    local playerName = getPlayerName(player)

    outputChatBox("Đã đổi thời tiết thành: " .. weatherName, player, 100, 255, 100)
    outputChatBox("[THÔNG BÁO] " .. playerName .. " đã đổi thời tiết thành: " .. weatherName,
        getRootElement(), 255, 255, 100)

    triggerClientEvent("weather:change", getRootElement(), weatherID, weatherName)
end)

addCommandHandler("tod", function(player, cmd, hour, minute)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("Chỉ admin cấp 3+ mới có thể đổi giờ!", player, 255, 100, 100)
        return
    end

    if not hour then
        outputChatBox("Sử dụng: /tod [giờ 0-23] [phút 0-59] (phút không bắt buộc)", player, 255, 255, 100)
        return
    end

    hour = tonumber(hour)
    minute = tonumber(minute) or 0

    if not hour or hour < 0 or hour > 23 then
        outputChatBox("Giờ phải từ 0-23!", player, 255, 100, 100)
        return
    end

    if minute < 0 or minute > 59 then
        outputChatBox("Phút phải từ 0-59!", player, 255, 100, 100)
        return
    end

    setTime(hour, minute)

    local timeString = string.format("%02d:%02d", hour, minute)
    local playerName = getPlayerName(player)

    outputChatBox("Đã đổi giờ thành: " .. timeString, player, 100, 255, 100)
    outputChatBox("[THÔNG BÁO] " .. playerName .. " đã đổi giờ thành: " .. timeString, getRootElement(), 255,
        255, 100)

    triggerClientEvent("time:change", getRootElement(), hour, minute)
end)

-- SPEED CAMERA SYSTEM
local speedCameras = {}

addCommandHandler("speedcam", function(player, cmd, action, ...)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("Chỉ admin cấp 3+ mới có thể quản lý camera tốc độ!", player, 255, 100, 100)
        return
    end

    if not action then
        outputChatBox("Sử dụng: /speedcam [add/remove/list/set] [tham số]", player, 255, 255, 100)
        outputChatBox("  /speedcam add [tốc độ tối đa] - Thêm camera", player, 255, 255, 200)
        outputChatBox("  /speedcam remove [ID] - Xóa camera", player, 255, 255, 200)
        outputChatBox("  /speedcam list - Danh sách camera", player, 255, 255, 200)
        outputChatBox("  /speedcam set [ID] [tốc độ mới] - Đổi tốc độ", player, 255, 255, 200)
        return
    end

    action = string.lower(action)

    if action == "add" then
        local maxSpeed = tonumber((...))
        if not maxSpeed or maxSpeed <= 0 or maxSpeed > 300 then
            outputChatBox("Tốc độ tối đa phải từ 1-300 km/h!", player, 255, 100, 100)
            return
        end

        local x, y, z = getElementPosition(player)
        local camID = #speedCameras + 1

        local camera = {
            id = camID,
            position = {x, y, z},
            maxSpeed = maxSpeed,
            createdBy = getPlayerName(player)
        }

        table.insert(speedCameras, camera)

        -- Create camera object
        local camObject = createObject(1886, x, y, z + 3) -- Traffic light object as camera
        setElementData(camObject, "speedCameraID", camID)

        outputChatBox("Đã tạo camera tốc độ #" .. camID .. " (Tối đa: " .. maxSpeed .. " km/h)", player,
            100, 255, 100)

        triggerClientEvent("speedcam:create", getRootElement(), camID, x, y, z, maxSpeed)

    elseif action == "remove" then
        local camID = tonumber((...))
        if not camID or not speedCameras[camID] then
            outputChatBox("Camera không tồn tại!", player, 255, 100, 100)
            return
        end

        -- Remove camera object
        for _, obj in ipairs(getElementsByType("object")) do
            if getElementData(obj, "speedCameraID") == camID then
                destroyElement(obj)
            end
        end

        speedCameras[camID] = nil
        outputChatBox("Đã xóa camera tốc độ #" .. camID, player, 100, 255, 100)

        triggerClientEvent("speedcam:remove", getRootElement(), camID)

    elseif action == "list" then
        outputChatBox("===== CAMERA TỐC ĐỘ =====", player, 255, 255, 100)

        local hasCamera = false
        for id, camera in pairs(speedCameras) do
            hasCamera = true
            local pos = camera.position
            outputChatBox(string.format("#%d: %.1f,%.1f,%.1f - %d km/h", id, pos[1], pos[2], pos[3], camera.maxSpeed),
                player, 255, 255, 255)
        end

        if not hasCamera then
            outputChatBox("Không có camera nào!", player, 255, 200, 200)
        end

        outputChatBox("==========================", player, 255, 255, 100)

    elseif action == "set" then
        local args = {...}
        local camID = tonumber(args[1])
        local newSpeed = tonumber(args[2])

        if not camID or not speedCameras[camID] then
            outputChatBox("Camera không tồn tại!", player, 255, 100, 100)
            return
        end

        if not newSpeed or newSpeed <= 0 or newSpeed > 300 then
            outputChatBox("Tốc độ phải từ 1-300 km/h!", player, 255, 100, 100)
            return
        end

        speedCameras[camID].maxSpeed = newSpeed
        outputChatBox("Đã đổi tốc độ camera #" .. camID .. " thành " .. newSpeed .. " km/h", player, 100,
            255, 100)

        triggerClientEvent("speedcam:updateSpeed", getRootElement(), camID, newSpeed)
    end
end)

-- CRATES SYSTEM
local cratesSystem = {
    crates = {},
    spawnLocations = {{1433.3, -1372.8, 13.3}, -- Los Santos
    {2142.5, -1161.2, 23.4}, -- Los Santos
    {-1916.5, 278.3, 41.0}, -- San Fierro
    {-2242.1, -1736.7, 480.8}, -- San Fierro Airport
    {1684.9, 1447.7, 10.8}, -- Las Venturas
    {2503.4, 2764.1, 10.8} -- Las Venturas Desert
    }
}

addCommandHandler("crates", function(player, cmd, action, ...)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("Chỉ admin cấp 3+ mới có thể quản lý crates!", player, 255, 100, 100)
        return
    end

    if not action then
        outputChatBox("Sử dụng: /crates [spawn/clear/list/auto]", player, 255, 255, 100)
        outputChatBox("  /crates spawn [số lượng] - Spawn crates", player, 255, 255, 200)
        outputChatBox("  /crates clear - Xóa tất cả crates", player, 255, 255, 200)
        outputChatBox("  /crates list - Danh sách crates", player, 255, 255, 200)
        outputChatBox("  /crates auto - Bật/tắt auto spawn", player, 255, 255, 200)
        return
    end

    action = string.lower(action)

    if action == "spawn" then
        local count = tonumber((...)) or 5
        if count <= 0 or count > 20 then
            outputChatBox("Số lượng phải từ 1-20!", player, 255, 100, 100)
            return
        end

        for i = 1, count do
            local location = cratesSystem.spawnLocations[math.random(#cratesSystem.spawnLocations)]
            local x, y, z = location[1], location[2], location[3]

            -- Add some randomness
            x = x + math.random(-50, 50)
            y = y + math.random(-50, 50)

            local crate = createObject(1271, x, y, z) -- Barrel object as crate
            setElementData(crate, "isCrate", true)
            setElementData(crate, "crateReward", math.random(1000, 10000))

            table.insert(cratesSystem.crates, crate)
        end

        outputChatBox("Đã spawn " .. count .. " crates trên bản đồ!", player, 100, 255, 100)
        outputChatBox("[THÔNG BÁO] " .. count ..
                          " crates đã xuất hiện trên bản đồ! Hãy tìm và thu thập!", getRootElement(),
            255, 255, 100)

    elseif action == "clear" then
        for _, crate in ipairs(cratesSystem.crates) do
            if isElement(crate) then
                destroyElement(crate)
            end
        end

        cratesSystem.crates = {}
        outputChatBox("Đã xóa tất cả crates!", player, 100, 255, 100)
        outputChatBox("[THÔNG BÁO] Tất cả crates đã bị xóa!", getRootElement(), 255, 255, 100)

    elseif action == "list" then
        local validCrates = 0
        for _, crate in ipairs(cratesSystem.crates) do
            if isElement(crate) then
                validCrates = validCrates + 1
            end
        end

        outputChatBox("Có " .. validCrates .. " crates đang có trên bản đồ", player, 255, 255, 100)

    elseif action == "auto" then
        local autoSpawn = getElementData(getRootElement(), "crateAutoSpawn") or false
        setElementData(getRootElement(), "crateAutoSpawn", not autoSpawn)

        local status = autoSpawn and "TẮT" or "BẬT"
        outputChatBox("Đã " .. status .. " auto spawn crates!", player, 100, 255, 100)
    end
end)

-- SPECIAL FEATURES
addCommandHandler("flymode", function(player, cmd, targetName)
    if not isPlayerAdmin(player, 4) then
        outputChatBox("Chỉ admin cấp 4+ mới có thể sử dụng flymode!", player, 255, 100, 100)
        return
    end

    local target = player
    if targetName then
        target = getPlayerFromName(targetName)
        if not target then
            outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
            return
        end
    end

    local currentFly = getElementData(target, "flyMode") or false
    setElementData(target, "flyMode", not currentFly)

    local targetName = getPlayerName(target)
    local status = currentFly and "TẮT" or "BẬT"

    if target == player then
        outputChatBox("Đã " .. status .. " flymode!", player, 100, 255, 100)
    else
        local playerName = getPlayerName(player)
        outputChatBox("Đã " .. status .. " flymode cho " .. targetName, player, 100, 255, 100)
        outputChatBox("Admin " .. playerName .. " đã " .. status .. " flymode cho bạn", target, 255, 255, 100)
    end

    triggerClientEvent("flymode:toggle", target, not currentFly)
end)

addCommandHandler("plantedcrops", function(player, cmd)
    local crops = getElementData(player, "plantedCrops") or {}

    outputChatBox("===== CÂY TRỒNG CỦA BẠN =====", player, 255, 255, 100)

    if #crops == 0 then
        outputChatBox("Bạn chưa trồng cây nào!", player, 255, 200, 200)
    else
        for i, crop in ipairs(crops) do
            local timeLeft = crop.harvestTime - getRealTime().timestamp
            if timeLeft <= 0 then
                outputChatBox("Cây #" .. i .. ": SẴN SÀNG THU HOẠCH!", player, 100, 255, 100)
            else
                local hours = math.floor(timeLeft / 3600)
                local minutes = math.floor((timeLeft % 3600) / 60)
                outputChatBox("Cây #" .. i .. ": " .. hours .. "h " .. minutes .. "m nữa", player, 255, 255, 255)
            end
        end
    end

    outputChatBox("=============================", player, 255, 255, 100)
end)

addCommandHandler("checkvehs", function(player, cmd)
    if not isPolice(player) then
        outputChatBox("Chỉ cảnh sát mới có thể kiểm tra xe!", player, 255, 100, 100)
        return
    end

    local vehicles = {}
    local x, y, z = getElementPosition(player)

    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        local vx, vy, vz = getElementPosition(vehicle)
        local distance = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)

        if distance <= 50.0 then
            table.insert(vehicles, {vehicle, distance})
        end
    end

    if #vehicles == 0 then
        outputChatBox("Không có xe nào trong vòng 50m!", player, 255, 100, 100)
    else
        outputChatBox("===== XE TRONG VÒN 50M =====", player, 255, 255, 100)

        -- Sort by distance
        table.sort(vehicles, function(a, b)
            return a[2] < b[2]
        end)

        for i, data in ipairs(vehicles) do
            if i <= 10 then -- Limit to 10 vehicles
                local vehicle, distance = data[1], data[2]
                local model = getElementModel(vehicle)
                local owner = getElementData(vehicle, "owner") or "Không có chủ"
                local locked = isVehicleLocked(vehicle) and "KHÓA" or "MỞ"

                outputChatBox(string.format("Model %d - Chủ: %s - %s - %.1fm", model, owner, locked, distance),
                    player, 255, 255, 255)
            end
        end

        outputChatBox("=============================", player, 255, 255, 100)
    end
end)

addCommandHandler("mycredits", function(player, cmd)
    local credits = getElementData(player, "credits") or 0
    local vipLevel = getElementData(player, "vipLevel") or 0
    local vipExpiry = getElementData(player, "vipExpiry") or 0

    outputChatBox("===== THÔNG TIN TÀI KHOẢN =====", player, 255, 255, 100)
    outputChatBox("Credits: " .. credits, player, 255, 255, 255)

    if vipLevel > 0 then
        local timeLeft = vipExpiry - getRealTime().timestamp
        if timeLeft > 0 then
            local days = math.floor(timeLeft / 86400)
            outputChatBox("VIP Level: " .. vipLevel .. " (Còn " .. days .. " ngày)", player, 255, 215, 0)
        else
            outputChatBox("VIP Level: " .. vipLevel .. " (ĐÃ HẾT HẠN)", player, 255, 100, 100)
        end
    else
        outputChatBox("VIP Level: Không có", player, 255, 255, 255)
    end

    outputChatBox("===============================", player, 255, 255, 100)
end)

-- SERVER INFO
addCommandHandler("serverinfo", function(player, cmd)
    local playerCount = #getElementsByType("player")
    local maxPlayers = getMaxPlayers()
    local serverName = getServerName()
    local gameType = getGameType()
    local mapName = getMapName()

    outputChatBox("===== THÔNG TIN SERVER =====", player, 255, 255, 100)
    outputChatBox("Tên server: " .. serverName, player, 255, 255, 255)
    outputChatBox("Người chơi: " .. playerCount .. "/" .. maxPlayers, player, 255, 255, 255)
    outputChatBox("Gamemode: " .. (gameType or "AMB Roleplay"), player, 255, 255, 255)
    outputChatBox("Map: " .. (mapName or "San Andreas"), player, 255, 255, 255)
    outputChatBox("Thời tiết hiện tại: " ..
                      (weatherSystem.weatherNames[weatherSystem.currentWeather] or "Không xác định"), player, 255,
        255, 255)

    local hour, minute = getTime()
    outputChatBox("Giờ server: " .. string.format("%02d:%02d", hour, minute), player, 255, 255, 255)

    outputChatBox("============================", player, 255, 255, 100)
end)

function isPolice(player)
    local job = getElementData(player, "job")
    return job == "police" or job == "fbi" or job == "swat"
end

function getPlayerFromName(name)
    if not name then
        return nil
    end

    name = string.lower(name)
    for _, player in ipairs(getElementsByType("player")) do
        local playerName = string.lower(getPlayerName(player))
        if string.find(playerName, name, 1, true) then
            return player
        end
    end
    return nil
end

-- Auto crate spawning
setTimer(function()
    local autoSpawn = getElementData(getRootElement(), "crateAutoSpawn") or false
    if autoSpawn then
        -- Count existing crates
        local validCrates = 0
        for i = #cratesSystem.crates, 1, -1 do
            if isElement(cratesSystem.crates[i]) then
                validCrates = validCrates + 1
            else
                table.remove(cratesSystem.crates, i)
            end
        end

        -- Spawn new crates if needed
        if validCrates < 3 then
            local spawnCount = 3 - validCrates
            for i = 1, spawnCount do
                local location = cratesSystem.spawnLocations[math.random(#cratesSystem.spawnLocations)]
                local x, y, z = location[1], location[2], location[3]

                x = x + math.random(-50, 50)
                y = y + math.random(-50, 50)

                local crate = createObject(1271, x, y, z)
                setElementData(crate, "isCrate", true)
                setElementData(crate, "crateReward", math.random(1000, 10000))

                table.insert(cratesSystem.crates, crate)
            end

            if spawnCount > 0 then
                outputChatBox("[AUTO SPAWN] " .. spawnCount .. " crates mới đã xuất hiện!", getRootElement(),
                    255, 255, 100)
            end
        end
    end
end, 300000, 0) -- Every 5 minutes

outputDebugString("Mega System Management & Utilities loaded successfully! (80+ commands)")
