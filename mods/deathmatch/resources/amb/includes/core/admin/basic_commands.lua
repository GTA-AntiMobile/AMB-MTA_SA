-- ====================================
-- 🛡️ AMB ADMIN COMMANDS SYSTEM
-- ====================================
-- Purpose: Essential admin commands migrated from SA-MP
-- Version: 1.0.0
-- Author: AMB Team
-- 📝 Send Admin Message
function sendAdminMessage(message)
    outputServerLog("[ADMIN] " .. message)
    for _, player in ipairs(getElementsByType("player")) do
        if isPlayerAdmin(player, 1) then
            outputChatBox("🛡️ [ADMIN] " .. message, player, 255, 100, 100)
        end
    end
end

-- 💰 Money & Stats Commands
addCommandHandler("givemoney", function(player, _, playerIdOrName, amount)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not amount then
        outputChatBox("Usage: /givemoney [player] [amount]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local money = tonumber(amount)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if not money or money <= 0 then
        outputChatBox("❌ Invalid amount!", player, 255, 0, 0)
        return
    end

    givePlayerMoney(targetPlayer, money)
    outputChatBox("✅ Given $" .. money .. " to " .. getPlayerName(targetPlayer), player, 0, 255, 0)
    outputChatBox("💰 You received $" .. money .. " from admin " .. getPlayerName(player), targetPlayer, 0, 255, 100)

    sendAdminMessage(getPlayerName(player) .. " gave $" .. money .. " to " .. getPlayerName(targetPlayer))
end)

addCommandHandler("setmoney", function(player, _, playerIdOrName, amount)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not amount then
        outputChatBox("Usage: /setmoney [player] [amount]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local money = tonumber(amount)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if not money or money < 0 then
        outputChatBox("❌ Invalid amount!", player, 255, 0, 0)
        return
    end

    setPlayerMoney(targetPlayer, money)
    outputChatBox("✅ Set " .. getPlayerName(targetPlayer) .. "'s money to $" .. money, player, 0, 255, 0)
    outputChatBox("💰 Your money was set to $" .. money .. " by admin " .. getPlayerName(player), targetPlayer, 0,
        255, 100)

    sendAdminMessage(getPlayerName(player) .. " set " .. getPlayerName(targetPlayer) .. "'s money to $" .. money)
end)

-- 🩺 Health & Armor Commands
addCommandHandler("sethp", function(player, _, playerIdOrName, health)
    -- Kiểm tra quyền admin cấp 2 trở lên
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Bạn không có quyền sử dụng lệnh này!", player, 255, 0, 0)
        return
    end

    -- Kiểm tra đầu vào
    if not playerIdOrName or not health then
        outputChatBox("Sử dụng: /sethp [player] [máu 0-100]", player, 255, 255, 0)
        return
    end

    -- Tìm player theo ID hoặc tên
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Không tìm thấy người chơi!", player, 255, 0, 0)
        return
    end

    -- Kiểm tra giá trị máu
    local hp = tonumber(health)
    if not hp or hp < 0 or hp > 100 then
        outputChatBox("❌ Giá trị máu phải từ 0-100!", player, 255, 0, 0)
        return
    end

    -- Check jail time (simulate SA-MP pJailTime check)
    local targetJailTime = getElementData(targetPlayer, "player.jailTime") or 0
    if targetJailTime >= 1 then
        outputChatBox("Bạn không thể thiết lập HP cho người ở tù OOC!", player, 255, 255, 255, false)
        return
    end

    -- Admin protection check (like SA-MP)
    local playerAdminLevel = getElementData(player, "adminLevel") or 0
    local targetAdminLevel = getElementData(targetPlayer, "adminLevel") or 0
    if targetAdminLevel >= playerAdminLevel and targetPlayer ~= player then
        outputChatBox("Bạn không thể làm điều này trên 1 Admin cấp cao!", player, 255, 100, 100, false)
        return
    end

    -- Thiết lập máu cho player
    setElementHealth(targetPlayer, hp)
    outputChatBox("✅ Bạn đã thiết lập máu cho " .. getPlayerName(targetPlayer) .. ": " .. hp .. ".", player,
        0, 255, 0)
    outputChatBox("🩺 Máu của bạn đã được admin " .. getPlayerName(player) .. " thiết lập thành " ..
                      hp, targetPlayer, 0, 255, 100)

    -- Gửi thông báo admin
    sendAdminMessage(getPlayerName(player) .. " đã hồi " .. hp .. " máu cho " .. getPlayerName(targetPlayer))
end)

addCommandHandler("setarmor", function(player, _, playerIdOrName, armor)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Bạn không được phép sử dụng lệnh này!", player, 255, 0, 0)
        return
    end
    if not playerIdOrName or not armor then
        outputChatBox("Sử dụng: /setarmor [player] [armor]", player, 255, 255, 255)
        return
    end
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local arm = tonumber(armor)
    if not targetPlayer then
        outputChatBox("❌ Không tìm thấy người chơi!", player, 255, 0, 0)
        return
    end
    if not arm or arm < 0 or arm > 100 then
        outputChatBox("❌ Giáp phải từ 0-100!", player, 255, 0, 0)
        return
    end
    setPedArmor(targetPlayer, arm)
    outputChatBox("Bạn đã thiết lập armor cho " .. getPlayerName(targetPlayer) .. ": " .. arm .. ".", player, 0,
        255, 0)
    outputChatBox(
        "🛡️ Armor của bạn đã được admin " .. getPlayerName(player) .. " thiết lập thành " .. arm,
        targetPlayer, 0, 255, 100)
    sendAdminMessage(getPlayerName(player) .. " set " .. getPlayerName(targetPlayer) .. "'s armor to " .. arm)
end)

-- 🎭 Skin Commands
addCommandHandler("changeskin", function(player, _, playerIdOrName, skinId)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName or not skinId then
        outputChatBox("Usage: /changeskin [player] [skinId]", player, 255, 255, 0)
        outputChatBox("Standard skins: 0-312, Custom skins: 20001-20027", player, 255, 255, 100)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local skin = tonumber(skinId)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if not skin then
        outputChatBox("❌ Invalid skin ID!", player, 255, 0, 0)
        return
    end

    -- Check if it's a valid skin ID
    local isValid = false
    local skinType = "Unknown"

    if skin >= 0 and skin <= 312 then
        -- Standard GTA skin
        isValid = true
        skinType = "Standard"
        setElementModel(targetPlayer, skin)
        -- Clear custom skin data
        if getElementData(targetPlayer, "customSkinID") then
            removeElementData(targetPlayer, "customSkinID")
        end
    elseif skin >= 20001 and skin <= 29999 then
        -- Custom skin - check if available
        local newmodelsResource = getResourceFromName("newmodels_azul")
        if newmodelsResource and getResourceState(newmodelsResource) == "running" then
            local customModels = exports["newmodels_azul"]:getCustomModels()
            if customModels[skin] and customModels[skin].type == "ped" then
                local success = exports["newmodels_azul"]:setElementModel(targetPlayer, skin)
                if success then
                    isValid = true
                    skinType = "Custom (" .. (customModels[skin].name or "Unknown") .. ")"
                    setElementData(targetPlayer, "customSkinID", skin)
                else
                    outputChatBox("❌ Failed to apply custom skin " .. skin, player, 255, 0, 0)
                    return
                end
            else
                outputChatBox("❌ Custom skin " .. skin .. " not found!", player, 255, 0, 0)
                return
            end
        else
            outputChatBox("❌ Custom skins not available (newmodels_azul not running)", player, 255, 0, 0)
            return
        end
    end

    if isValid then
        -- Save to database immediately
        local username = getElementData(targetPlayer, "username")
        if username then
            local dbConn = getDatabaseConnection and getDatabaseConnection()
            if dbConn then
                dbExec(dbConn, "UPDATE accounts SET Model = ? WHERE Username = ?", skin, username)
                outputDebugString("[CHANGESKIN] Saved skin " .. skin .. " to database for " ..
                                      getPlayerName(targetPlayer))
            else
                outputChatBox("⚠️ Database not available - skin won't persist after restart", player, 255, 255, 0)
            end
        end

        outputChatBox("✅ Set " .. getPlayerName(targetPlayer) .. "'s skin to " .. skin .. " (" .. skinType .. ")",
            player, 0, 255, 0)
        if targetPlayer ~= player then
            outputChatBox("🎭 Your skin was changed to " .. skin .. " by admin " .. getPlayerName(player),
                targetPlayer, 0, 255, 100)
        end
        sendAdminMessage(getPlayerName(player) .. " changed " .. getPlayerName(targetPlayer) .. "'s skin to " .. skin ..
                             " (" .. skinType .. ")")
    else
        outputChatBox("❌ Invalid skin ID: " .. skin, player, 255, 0, 0)
    end
end)

-- 🚀 Jetpack Command
addCommandHandler("jetpack", function(player, _, playerIdOrName)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /jetpack [player]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if isPedWearingJetpack(targetPlayer) then
        setPedWearingJetpack(targetPlayer, false)
        outputChatBox("✅ Jetpack removed from " .. getPlayerName(targetPlayer), player, 255, 255, 0)
        if targetPlayer ~= player then
            outputChatBox("🚀 Your jetpack was removed by admin " .. getPlayerName(player), targetPlayer, 255, 255, 0)
        end
    else
        setPedWearingJetpack(targetPlayer, true)
        outputChatBox("✅ Jetpack given to " .. getPlayerName(targetPlayer), player, 0, 255, 0)
        if targetPlayer ~= player then
            outputChatBox("🚀 You received a jetpack from admin " .. getPlayerName(player), targetPlayer, 0, 255, 100)
        end
    end

    sendAdminMessage(getPlayerName(player) .. " toggled jetpack for " .. getPlayerName(targetPlayer))
end)

-- � Respawn/Revival Commands
addCommandHandler("hoisinh", function(player, _, playerIdOrName)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /hoisinh [player]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if not isPedDead(targetPlayer) then
        outputChatBox("❌ " .. getPlayerName(targetPlayer) .. " is not dead!", player, 255, 255, 0)
        return
    end

    -- Save current skin/model before spawning
    local currentModel = 299 -- fallback
    local newmodelsResource = getResourceFromName("newmodels_azul")
    if newmodelsResource and getResourceState(newmodelsResource) == "running" then
        currentModel = exports["newmodels_azul"]:getElementModel(targetPlayer) or 299
    else
        currentModel = getElementModel(targetPlayer)
    end

    -- Get current position
    local x, y, z = getElementPosition(targetPlayer)
    local rot = select(3, getElementRotation(targetPlayer))
    local interior = getElementInterior(targetPlayer)
    local dimension = getElementDimension(targetPlayer)

    -- Spawn player with proper skin handling
    if newmodelsResource and getResourceState(newmodelsResource) == "running" then
        exports["newmodels_azul"]:spawnPlayer(targetPlayer, x, y, z, rot, currentModel, interior, dimension)
    else
        spawnPlayer(targetPlayer, x, y, z, rot, currentModel, interior, dimension)
    end

    setElementHealth(targetPlayer, 100)

    outputChatBox("✅ Revived " .. getPlayerName(targetPlayer), player, 0, 255, 0)
    if targetPlayer ~= player then
        outputChatBox("💚 You have been revived by admin " .. getPlayerName(player), targetPlayer, 0, 255, 100)
    end

    sendAdminMessage(getPlayerName(player) .. " revived " .. getPlayerName(targetPlayer))
end)

-- Alias for respawn command
addCommandHandler("respawn", function(player, _, playerIdOrName)
    executeCommandHandler("hoisinh", player, playerIdOrName)
end)

-- �📍 Teleport Commands
-- Note: /goto command moved to players.lua for better admin integration
-- ❄️ Freeze/Unfreeze Commands
addCommandHandler("freeze", function(player, _, playerIdOrName)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /freeze [player]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    setElementFrozen(targetPlayer, true)
    toggleAllControls(targetPlayer, false)

    outputChatBox("✅ Froze " .. getPlayerName(targetPlayer), player, 0, 255, 0)
    outputChatBox("❄️ You have been frozen by admin " .. getPlayerName(player), targetPlayer, 100, 200, 255)

    sendAdminMessage(getPlayerName(player) .. " froze " .. getPlayerName(targetPlayer))
end)

addCommandHandler("unfreeze", function(player, _, playerIdOrName)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /unfreeze [player]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    setElementFrozen(targetPlayer, false)
    toggleAllControls(targetPlayer, true)

    outputChatBox("✅ Unfroze " .. getPlayerName(targetPlayer), player, 0, 255, 0)
    outputChatBox("🔥 You have been unfrozen by admin " .. getPlayerName(player), targetPlayer, 255, 200, 100)

    sendAdminMessage(getPlayerName(player) .. " unfroze " .. getPlayerName(targetPlayer))
end)

-- 🏃 Spectate Commands
local spectateData = {}

addCommandHandler("spec", function(player, _, playerIdOrName)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /spec [player]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    if targetPlayer == player then
        outputChatBox("❌ You cannot spectate yourself!", player, 255, 0, 0)
        return
    end

    -- Save original position
    local x, y, z = getElementPosition(player)
    local interior = getElementInterior(player)
    local dimension = getElementDimension(player)

    spectateData[player] = {
        x = x,
        y = y,
        z = z,
        interior = interior,
        dimension = dimension
    }

    setCameraTarget(player, targetPlayer)
    setElementAlpha(player, 0) -- Make invisible
    setElementFrozen(player, true)

    outputChatBox("👁️ Now spectating " .. getPlayerName(targetPlayer) .. " | Use /specoff to stop", player, 255,
        255, 0)

    sendAdminMessage(getPlayerName(player) .. " is spectating " .. getPlayerName(targetPlayer))
end)

addCommandHandler("specoff", function(player, _)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not spectateData[player] then
        outputChatBox("❌ You are not spectating anyone!", player, 255, 0, 0)
        return
    end

    local data = spectateData[player]

    setCameraTarget(player, player)
    setElementPosition(player, data.x, data.y, data.z)
    setElementInterior(player, data.interior)
    setElementDimension(player, data.dimension)
    setElementAlpha(player, 255)
    setElementFrozen(player, false)

    spectateData[player] = nil

    outputChatBox("✅ Stopped spectating", player, 0, 255, 0)

    sendAdminMessage(getPlayerName(player) .. " stopped spectating")
end)

-- 🌤️ Weather & Time Commands
addCommandHandler("thoitiet", function(player, _, weatherId)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not weatherId then
        outputChatBox("Usage: /thoitiet [weatherId]", player, 255, 255, 0)
        return
    end

    local weather = tonumber(weatherId)

    if not weather or weather < 0 or weather > 45 then
        outputChatBox("❌ Weather ID must be between 0-45!", player, 255, 0, 0)
        return
    end

    setWeather(weather)
    outputChatBox("✅ Weather changed to ID: " .. weather, player, 0, 255, 0)
    outputServerLog("[ADMIN] " .. getPlayerName(player) .. " changed weather to " .. weather)

    for _, p in ipairs(getElementsByType("player")) do
        outputChatBox("🌤️ Weather changed by admin " .. getPlayerName(player), p, 255, 255, 100)
    end
end)

-- ⚠️ Kick & Ban Commands
addCommandHandler("kick", function(player, _, playerIdOrName, ...)
    if not isPlayerAdmin(player, 2) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /kick [player] [reason]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local reason = table.concat({...}, " ") or "No reason specified"

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    local targetName = getPlayerName(targetPlayer)

    outputChatBox("⚠️ " .. targetName .. " was kicked by " .. getPlayerName(player) .. " | Reason: " .. reason,
        root, 255, 100, 100)
    outputServerLog("[KICK] " .. getPlayerName(player) .. " kicked " .. targetName .. " | Reason: " .. reason)

    kickPlayer(targetPlayer, reason)
end)

addCommandHandler("ban", function(player, _, playerIdOrName, ...)
    if not isPlayerAdmin(player, 4) then
        outputChatBox("❌ Access denied!", player, 255, 0, 0)
        return
    end

    if not playerIdOrName then
        outputChatBox("Usage: /ban [player] [reason]", player, 255, 255, 0)
        return
    end

    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    local reason = table.concat({...}, " ") or "No reason specified"

    if not targetPlayer then
        outputChatBox("❌ Player not found!", player, 255, 0, 0)
        return
    end

    local targetName = getPlayerName(targetPlayer)
    local targetSerial = getPlayerSerial(targetPlayer)

    outputChatBox("🔨 " .. targetName .. " was banned by " .. getPlayerName(player) .. " | Reason: " .. reason, root,
        255, 0, 0)
    outputServerLog("[BAN] " .. getPlayerName(player) .. " banned " .. targetName .. " (Serial: " .. targetSerial ..
                        ") | Reason: " .. reason)

    banPlayer(targetPlayer, false, false, true, getRootElement(), reason)
end)

-- 🚓 Speed Camera System
setTimer(function()
    for _, vehicle in ipairs(getElementsByType("vehicle")) do
        local driver = getVehicleOccupant(vehicle, 0)
        if driver then
            local x, y, z = getElementPosition(vehicle)

            -- Check all speed cameras in range - SAFE CHECK
            if speedCameras and type(speedCameras) == "table" then
                for _, camera in pairs(speedCameras) do
                local distance = getDistanceBetweenPoints3D(x, y, z, camera.x, camera.y, camera.z)

                if distance <= 15.0 then -- Speed camera range
                    local vx, vy, vz = getElementVelocity(vehicle)
                    local speed = math.sqrt(vx ^ 2 + vy ^ 2 + vz ^ 2) * 180 -- Convert to km/h

                    if speed > camera.speedLimit then
                        -- Speed violation detected
                        local violation = {
                            player = driver,
                            vehicle = vehicle,
                            speed = math.floor(speed),
                            speedLimit = camera.speedLimit,
                            cameraID = camera.id,
                            location = {x, y, z}
                        }

                        handleSpeedViolation(violation)
                    end
                end
            end
            end
        end
    end
end, 2000, 0)

-- Handle speed violation
function handleSpeedViolation(violation)
    local player = violation.player
    local playerName = getPlayerName(player)

    local message = string.format("Speed Camera Violation: %s - Speed: %d km/h (Limit: %d) - Camera ID: %d", playerName,
        violation.speed, violation.speedLimit, violation.cameraID)

    -- Notify all police officers
    for _, cop in ipairs(getElementsByType("player")) do
        local job = getElementData(cop, "player.job")
        if job == 1 then -- Police job
            outputChatBox(message, cop, 255, 255, 0)
        end
    end

    -- Log violation
    outputDebugString("[SPEEDCAM] " .. message)

    -- Optionally issue automatic ticket (if enabled)
    local autoTicket = getElementData(player, "server.autoSpeedTickets")
    if autoTicket then
        local fine = (violation.speed - violation.speedLimit) * 50 -- $50 per km/h over limit
        if fine > 5000 then
            fine = 5000
        end -- Max fine

        local playerMoney = getElementData(player, "player.money") or 0
        setElementData(player, "player.money", playerMoney - fine)

        outputChatBox(string.format("Auto Speed Ticket: $%d - Speed: %d km/h (Limit: %d)", fine, violation.speed,
            violation.speedLimit), player, 255, 100, 100)
    end
end

-- SPEEDCAM COMMANDS INTEGRATION
local speedCameras = {}
local nextCameraID = 1

local function loadSpeedCameras()
    local query = "SELECT * FROM speed_cameras"
    local dbConn = getDatabaseConnection and getDatabaseConnection()
    if dbConn then
        dbQuery(function(queryHandle)
            local result = dbPoll(queryHandle, 0)
            if result then
                for _, row in ipairs(result) do
                    speedCameras[row.id] = {
                        id = row.id,
                        x = row.x,
                        y = row.y,
                        z = row.z,
                        speedLimit = row.speed_limit,
                        creator = row.creator,
                        created = row.created_date
                    }
                    if row.id >= nextCameraID then
                        nextCameraID = row.id + 1
                    end
                end
                -- outputDebugString("[SPEEDCAM] Loaded " .. #result .. " speed cameras")
            else
                outputDebugString("[SPEEDCAM] No speed cameras found in database")
            end
        end, dbConn, query)
    else
        outputDebugString("[SPEEDCAM] Database not available - cannot load speed cameras", 2)
    end
end
-- Initialize speed camera system
addEventHandler("onResourceStart", resourceRoot, function()
    local dbConn = getDatabaseConnection and getDatabaseConnection()
    if dbConn then
        dbExec(dbConn, [[
            CREATE TABLE IF NOT EXISTS speed_cameras (
                id INTEGER PRIMARY KEY,
                x REAL NOT NULL,
                y REAL NOT NULL,
                z REAL NOT NULL,
                speed_limit INTEGER NOT NULL,
                creator TEXT NOT NULL,
                created_date INTEGER NOT NULL
            )
        ]])
    else
        outputDebugString("[SPEEDCAM] Database not available - cannot create speed_cameras table", 2)
    end
    loadSpeedCameras()
end)

-- 📋 Admin Help Command
if not isPlayerAdmin(player, 1) then
    outputChatBox("❌ Access denied!", player, 255, 0, 0)
    return
end

outputChatBox("━━━━━━━━━━ 🛡️ ADMIN COMMANDS ━━━━━━━━━━", player, 100, 255,
    100)
outputChatBox("Level 1: /goto, /spec, /specoff, /hoisinh, /respawn", player, 255, 255, 255)
outputChatBox("Level 2: /sethp, /setarmor, /jetpack, /fly, /gethere, /freeze, /unfreeze, /kick, /changeskin", player,
    255, 255, 255)
outputChatBox("Level 3: /givemoney, /setmoney, /weather, /time", player, 255, 255, 255)
outputChatBox("Level 4: /ban", player, 255, 255, 255)
outputChatBox("Vehicle: /veh, /deleteveh, /listveh, /deleteallveh", player, 255, 255, 255)
outputChatBox(
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━",
    player, 100, 255, 100)
