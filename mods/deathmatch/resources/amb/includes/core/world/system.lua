-- ================================
-- AMB MTA:SA - World & Environment Commands
-- Mass migration of world and environment management commands
-- ================================
-- Time control
addCommandHandler("time", function(player, cmd, hour, minute)
    local playerData = getElementData(player, "playerData") or {}

    if isPlayerAdmin(player, 3) then
        outputChatBox("❌ Ban can admin level 3 de thay doi gio.", player, 255, 100, 100)
        return
    end

    if not hour then
        local h, m = getTime()
        outputChatBox(string.format("🕐 Current time: %02d:%02d", h, m), player, 255, 255, 255)
        outputChatBox("Su dung: /time [hour] [minute]", player, 255, 255, 255)
        return
    end

    local h = tonumber(hour)
    local m = tonumber(minute) or 0

    if not h or h < 0 or h > 23 or m < 0 or m > 59 then
        outputChatBox("❌ Gio phai tu 0-23, phut tu 0-59.", player, 255, 100, 100)
        return
    end

    setTime(h, m)
    outputChatBox(string.format("🕐 Da thay doi gio thanh %02d:%02d", h, m), root, 0, 255, 0)
    outputDebugString(string.format("[ADMIN] %s changed time to %02d:%02d", getPlayerName(player), h, m))
end)

-- Gravity control
addCommandHandler("gravity", function(player, cmd, gravityLevel)
    local playerData = getElementData(player, "playerData") or {}

    if isPlayerAdmin(player, 4) then
        outputChatBox("❌ Ban can admin level 4 de thay doi gravity.", player, 255, 100, 100)
        return
    end

    if not gravityLevel then
        outputChatBox(string.format("🌍 Current gravity: %.2f", getGravity()), player, 255, 255, 255)
        outputChatBox("Su dung: /gravity [level] (0.001-0.1, default: 0.008)", player, 255, 255, 255)
        return
    end

    local gravity = tonumber(gravityLevel)
    if not gravity or gravity < 0.001 or gravity > 0.1 then
        outputChatBox("❌ Gravity phai tu 0.001 den 0.1.", player, 255, 100, 100)
        return
    end

    setGravity(gravity)
    outputChatBox(string.format("🌍 Da thay doi gravity thanh %.3f", gravity), root, 0, 255, 0)
    outputDebugString(string.format("[ADMIN] %s changed gravity to %.3f", getPlayerName(player), gravity))
end)

-- Game speed control
addCommandHandler("gamespeed", function(player, cmd, speed)
    local playerData = getElementData(player, "playerData") or {}

    if isPlayerAdmin(player, 4) then
        outputChatBox("❌ Ban can admin level 4 de thay doi game speed.", player, 255, 100, 100)
        return
    end

    if not speed then
        outputChatBox(string.format("⚡ Current game speed: %.2f", getGameSpeed()), player, 255, 255, 255)
        outputChatBox("Su dung: /gamespeed [speed] (0.1-3.0, default: 1.0)", player, 255, 255, 255)
        return
    end

    local gameSpeed = tonumber(speed)
    if not gameSpeed or gameSpeed < 0.1 or gameSpeed > 3.0 then
        outputChatBox("❌ Game speed phai tu 0.1 den 3.0.", player, 255, 100, 100)
        return
    end

    setGameSpeed(gameSpeed)
    outputChatBox(string.format("⚡ Da thay doi game speed thanh %.2f", gameSpeed), root, 0, 255, 0)
    outputDebugString(string.format("[ADMIN] %s changed game speed to %.2f", getPlayerName(player), gameSpeed))
end)

-- Wave height control
addCommandHandler("waveheight", function(player, cmd, height)
    local playerData = getElementData(player, "playerData") or {}

    if isPlayerAdmin(player, 3) then
        outputChatBox("❌ Ban can admin level 3 de thay doi wave height.", player, 255, 100, 100)
        return
    end

    if not height then
        outputChatBox(string.format("🌊 Current wave height: %.2f", getWaveHeight()), player, 255, 255, 255)
        outputChatBox("Su dung: /waveheight [height] (0-100)", player, 255, 255, 255)
        return
    end

    local waveHeight = tonumber(height)
    if not waveHeight or waveHeight < 0 or waveHeight > 100 then
        outputChatBox("❌ Wave height phai tu 0 den 100.", player, 255, 100, 100)
        return
    end

    setWaveHeight(waveHeight)
    outputChatBox(string.format("🌊 Da thay doi wave height thanh %.2f", waveHeight), root, 0, 255, 0)
    outputDebugString(string.format("[ADMIN] %s changed wave height to %.2f", getPlayerName(player), waveHeight))
end)

-- World special property control
addCommandHandler("worldproperty", function(player, cmd, property, state)
    local playerData = getElementData(player, "playerData") or {}

    if isPlayerAdmin(player, 5) then
        outputChatBox("❌ Ban can admin level 5 de thay doi world properties.", player, 255, 100, 100)
        return
    end

    if not property then
        outputChatBox("🌍 ===== WORLD PROPERTIES =====", player, 255, 255, 0)
        outputChatBox("• hovercars - Xe bay", player, 255, 255, 255)
        outputChatBox("• aircars - Xe co the bay", player, 255, 255, 255)
        outputChatBox("• extrabunny - Tang cuong nhay", player, 255, 255, 255)
        outputChatBox("• extrajump - Nhay cao", player, 255, 255, 255)
        outputChatBox("Su dung: /worldproperty [property] [true/false]", player, 255, 255, 255)
        return
    end

    if not state then
        outputChatBox("Su dung: /worldproperty [property] [true/false]", player, 255, 255, 255)
        return
    end

    local properties = {
        ["hovercars"] = "hovercars",
        ["aircars"] = "aircars",
        ["extrabunny"] = "extrabunny",
        ["extrajump"] = "extrajump"
    }

    if not properties[property] then
        outputChatBox("❌ Property khong hop le.", player, 255, 100, 100)
        return
    end

    local enabled = (state == "true" or state == "1")

    setWorldSpecialPropertyEnabled(properties[property], enabled)

    local statusText = enabled and "enabled" or "disabled"
    outputChatBox(string.format("🌍 World property '%s' da duoc %s", property, statusText), root, 0, 255, 0)
    outputDebugString(string.format("[ADMIN] %s %s world property: %s", getPlayerName(player), statusText, property))
end)

-- Explosion creation
addCommandHandler("explode", function(player, cmd, x, y, z, type)
    local playerData = getElementData(player, "playerData") or {}

    if isPlayerAdmin(player, 4) then
        outputChatBox("❌ Ban can admin level 4 de tao explosion.", player, 255, 100, 100)
        return
    end

    local ex, ey, ez

    if not x or not y or not z then
        -- Use player position
        ex, ey, ez = getElementPosition(player)
    else
        ex, ey, ez = tonumber(x), tonumber(y), tonumber(z)
        if not ex or not ey or not ez then
            outputChatBox("❌ Toa do khong hop le.", player, 255, 100, 100)
            return
        end
    end

    local explosionType = tonumber(type) or 0
    if explosionType < 0 or explosionType > 12 then
        outputChatBox("❌ Explosion type phai tu 0-12.", player, 255, 100, 100)
        return
    end

    createExplosion(ex, ey, ez, explosionType)

    outputChatBox(string.format("💥 Da tao explosion tai %.1f, %.1f, %.1f (Type: %d)", ex, ey, ez, explosionType),
        player, 255, 255, 0)
    outputDebugString(string.format("[ADMIN] %s created explosion at %.1f,%.1f,%.1f type %d", getPlayerName(player), ex,
        ey, ez, explosionType))
end)

-- Clear world effects
addCommandHandler("clearworld", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if isPlayerAdmin(player, 4) then
        outputChatBox("❌ Ban can admin level 4 de clear world effects.", player, 255, 100, 100)
        return
    end

    -- Reset to defaults
    setWeather(10) -- Sunny
    setTime(12, 0) -- Noon
    setGravity(0.008) -- Default
    setGameSpeed(1.0) -- Normal
    setWaveHeight(0) -- Calm

    -- Disable special properties
    setWorldSpecialPropertyEnabled("hovercars", false)
    setWorldSpecialPropertyEnabled("aircars", false)
    setWorldSpecialPropertyEnabled("extrabunny", false)
    setWorldSpecialPropertyEnabled("extrajump", false)

    outputChatBox("🌍 Da reset tat ca world effects ve default.", root, 0, 255, 0)
    outputDebugString(string.format("[ADMIN] %s reset all world effects", getPlayerName(player)))
end)

-- Object creation for world decoration
addCommandHandler("createobj", function(player, cmd, modelID, ...)
    local playerData = getElementData(player, "playerData") or {}

    if isPlayerAdmin(player, 3) then
        outputChatBox("❌ Ban can admin level 3 de tao object.", player, 255, 100, 100)
        return
    end

    if not modelID then
        outputChatBox("Su dung: /createobj [model] [x] [y] [z] [rx] [ry] [rz]", player, 255, 255, 255)
        outputChatBox("Neu khong co toa do, object se duoc tao tai vi tri cua ban.", player, 255, 255, 255)
        return
    end

    local model = tonumber(modelID)
    if not model or model < 300 or model > 20000 then
        outputChatBox("❌ Model ID khong hop le (300-20000).", player, 255, 100, 100)
        return
    end

    local args = {...}
    local x, y, z, rx, ry, rz

    if #args >= 3 then
        x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        rx, ry, rz = tonumber(args[4]) or 0, tonumber(args[5]) or 0, tonumber(args[6]) or 0

        if not x or not y or not z then
            outputChatBox("❌ Toa do khong hop le.", player, 255, 100, 100)
            return
        end
    else
        -- Use player position and get position in front
        local px, py, pz = getElementPosition(player)
        local rot = getPedRotation(player)
        x = px + math.sin(math.rad(-rot)) * 5
        y = py + math.cos(math.rad(-rot)) * 5
        z = pz
        rx, ry, rz = 0, 0, 0
    end

    local object = createObject(model, x, y, z, rx, ry, rz)
    if object then
        -- Store object data for management
        local objectData = {
            creator = getPlayerName(player),
            created = getRealTime().timestamp,
            model = model
        }
        setElementData(object, "objectData", objectData)

        outputChatBox(string.format("🏗️ Da tao object model %d tai %.1f, %.1f, %.1f", model, x, y, z), player, 0,
            255, 0)
        outputDebugString(string.format("[ADMIN] %s created object %d at %.1f,%.1f,%.1f", getPlayerName(player), model,
            x, y, z))
    else
        outputChatBox("❌ Khong the tao object.", player, 255, 100, 100)
    end
end)

-- Nearest object info
addCommandHandler("nearobj", function(player, cmd, radius)
    local playerData = getElementData(player, "playerData") or {}

    if isPlayerAdmin(player, 2) then
        outputChatBox("❌ Ban can admin level 2 de xem object gan ban.", player, 255, 100, 100)
        return
    end

    local searchRadius = tonumber(radius) or 20
    if searchRadius > 100 then
        searchRadius = 100
    end

    local px, py, pz = getElementPosition(player)
    local nearObjects = {}

    for _, obj in ipairs(getElementsByType("object")) do
        local ox, oy, oz = getElementPosition(obj)
        local distance = getDistanceBetweenPoints3D(px, py, pz, ox, oy, oz)

        if distance <= searchRadius then
            table.insert(nearObjects, {
                element = obj,
                distance = distance,
                model = getElementModel(obj)
            })
        end
    end

    if #nearObjects == 0 then
        outputChatBox(string.format("❌ Khong co object nao trong ban kinh %dm.", searchRadius), player, 255, 255, 100)
        return
    end

    -- Sort by distance
    table.sort(nearObjects, function(a, b)
        return a.distance < b.distance
    end)

    outputChatBox(string.format("🏗️ ===== OBJECTS GAN BAN (%dm) =====", searchRadius), player, 255, 255, 0)

    for i, obj in ipairs(nearObjects) do
        if i > 10 then
            break
        end -- Limit to 10 objects

        local objData = getElementData(obj.element, "objectData")
        local creator = objData and objData.creator or "Unknown"

        outputChatBox(string.format("• Model %d - %.1fm - Creator: %s", obj.model, obj.distance, creator), player,
            255, 255, 255)
    end

    if #nearObjects > 10 then
        outputChatBox(string.format("... va %d objects khac", #nearObjects - 10), player, 255, 255, 100)
    end
end)

-- Delete nearest object
addCommandHandler("delobj", function(player, cmd, radius)
    local playerData = getElementData(player, "playerData") or {}

    if isPlayerAdmin(player, 4) then
        outputChatBox("❌ Ban can admin level 4 de xoa object.", player, 255, 100, 100)
        return
    end

    local searchRadius = tonumber(radius) or 5
    if searchRadius > 50 then
        searchRadius = 50
    end

    local px, py, pz = getElementPosition(player)
    local nearestObject = nil
    local nearestDistance = searchRadius

    for _, obj in ipairs(getElementsByType("object")) do
        local ox, oy, oz = getElementPosition(obj)
        local distance = getDistanceBetweenPoints3D(px, py, pz, ox, oy, oz)

        if distance < nearestDistance then
            nearestObject = obj
            nearestDistance = distance
        end
    end

    if not nearestObject then
        outputChatBox(string.format("❌ Khong co object nao trong ban kinh %dm.", searchRadius), player, 255, 255, 100)
        return
    end

    local objData = getElementData(nearestObject, "objectData")
    local model = getElementModel(nearestObject)
    local creator = objData and objData.creator or "Unknown"

    destroyElement(nearestObject)

    outputChatBox(string.format("🗑️ Da xoa object model %d (%.1fm, creator: %s)", model, nearestDistance, creator),
        player, 0, 255, 0)
    outputDebugString(string.format("[ADMIN] %s deleted object model %d", getPlayerName(player), model))
end)

outputDebugString("[AMB] World & Environment system loaded - 11 commands")
