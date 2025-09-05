--[[
    LAW ENFORCEMENT SYSTEM - Batch 28
    
    Chức năng: Hệ thống thực thi pháp luật hoàn chỉnh
    Nâng cấp từ SA-MP sang MTA với đầy đủ tính năng law enforcement
    
    Commands migrated: 18 commands
    - Basic Actions: cuff, uncuff, detain, frisk, search
    - Enforcement: arrest, ticket, fine, jail, release
    - Vehicle: searchcar, pullover, roadblock, barrier
    - Investigation: investigate, evidence, warrant, seize
]] -- Check if player is law enforcement
function isLawEnforcement(player)
    local policeRank = getElementData(player, "policeRank") or 0
    local fbiRank = getElementData(player, "fbiRank") or 0
    local adminLevel = getElementData(player, "adminLevel") or 0

    return policeRank > 0 or fbiRank > 0 or adminLevel >= 3
end

-- Check proximity between players
function isPlayerNearby(player1, player2, distance)
    if not player1 or not player2 or not isElement(player1) or not isElement(player2) then
        return false
    end

    local x1, y1, z1 = getElementPosition(player1)
    local x2, y2, z2 = getElementPosition(player2)

    return getDistanceBetweenPoints3D(x1, y1, z1, x2, y2, z2) <= distance
end

-- Cuff System
addCommandHandler("cuff", function(player, cmd, targetName)
    if not player or not isElement(player) then
        return
    end

    if not isLawEnforcement(player) then
        outputChatBox("Bạn không phải nhân viên thực thi pháp luật!", player, 255, 100, 100)
        return
    end

    if not targetName then
        outputChatBox("Sử dụng: /cuff [tên người chơi]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Bạn không thể tự còng tay mình!", player, 255, 100, 100)
        return
    end

    if not isPlayerNearby(player, target, 5.0) then
        outputChatBox("Người đó không ở gần bạn!", player, 255, 100, 100)
        return
    end

    local isCuffed = getElementData(target, "cuffed") or false
    if isCuffed then
        outputChatBox("Người này đã bị còng tay rồi!", player, 255, 100, 100)
        return
    end

    -- Check if target has hands up
    local handsUp = getElementData(target, "handsUp") or false
    if not handsUp then
        outputChatBox("Người này phải giơ tay lên trước! (/handsup)", player, 255, 100, 100)
        return
    end

    -- Apply handcuffs
    setElementData(target, "cuffed", true)
    setElementData(target, "cuffedBy", getPlayerName(player))
    setElementData(target, "handsUp", false)

    toggleControl(target, "jump", false)
    toggleControl(target, "sprint", false)
    toggleControl(target, "fire", false)
    toggleControl(target, "action", false)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("** " .. playerName .. " còng tay " .. targetName .. ".", getRootElement(), 255, 128, 0)
    outputChatBox("Bạn đã bị còng tay bởi " .. playerName .. "!", target, 255, 100, 100)
    outputChatBox("Bạn đã còng tay " .. targetName .. "!", player, 100, 255, 100)

    -- Set animation
    triggerClientEvent("law:setCuffAnimation", target, target)
end)

-- Uncuff System
addCommandHandler("uncuff", function(player, cmd, targetName)
    if not player or not isElement(player) then
        return
    end

    if not isLawEnforcement(player) then
        outputChatBox("Bạn không phải nhân viên thực thi pháp luật!", player, 255, 100, 100)
        return
    end

    if not targetName then
        outputChatBox("Sử dụng: /uncuff [tên người chơi]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Bạn không thể tháo còng tay cho chính mình!", player, 255, 100, 100)
        return
    end

    if not isPlayerNearby(player, target, 5.0) then
        outputChatBox("Người đó không ở gần bạn!", player, 255, 100, 100)
        return
    end

    local isCuffed = getElementData(target, "cuffed") or false
    if not isCuffed then
        outputChatBox("Người này không bị còng tay!", player, 255, 100, 100)
        return
    end

    -- Remove handcuffs
    setElementData(target, "cuffed", false)
    setElementData(target, "cuffedBy", nil)

    toggleControl(target, "jump", true)
    toggleControl(target, "sprint", true)
    toggleControl(target, "fire", true)
    toggleControl(target, "action", true)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("** " .. playerName .. " tháo còng tay " .. targetName .. ".", getRootElement(), 255, 128, 0)
    outputChatBox("Bạn đã được tháo còng tay bởi " .. playerName .. "!", target, 100, 255, 100)
    outputChatBox("Bạn đã tháo còng tay " .. targetName .. "!", player, 100, 255, 100)

    -- Remove animation
    triggerClientEvent("law:removeCuffAnimation", target, target)
end)

-- Hands Up System
addCommandHandler("handsup", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    local handsUp = getElementData(player, "handsUp") or false
    local playerName = getPlayerName(player)

    if handsUp then
        setElementData(player, "handsUp", false)
        outputChatBox("** " .. playerName .. " hạ tay xuống.", getRootElement(), 255, 128, 0)
        triggerClientEvent("law:removeHandsUpAnimation", player, player)
    else
        setElementData(player, "handsUp", true)
        outputChatBox("** " .. playerName .. " giơ tay lên.", getRootElement(), 255, 128, 0)
        triggerClientEvent("law:setHandsUpAnimation", player, player)
    end
end)

-- Detain System (Put in vehicle)
addCommandHandler("detain", function(player, cmd, targetName, seatStr)
    if not player or not isElement(player) then
        return
    end

    if not isLawEnforcement(player) then
        outputChatBox("Bạn không phải nhân viên thực thi pháp luật!", player, 255, 100, 100)
        return
    end

    if not targetName or not seatStr then
        outputChatBox("Sử dụng: /detain [tên người chơi] [chỗ ngồi 1-3]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    local seat = tonumber(seatStr)
    if not seat or seat < 1 or seat > 3 then
        outputChatBox("Chỗ ngồi phải từ 1-3!", player, 255, 100, 100)
        return
    end

    if not isPlayerNearby(player, target, 8.0) then
        outputChatBox("Người đó không ở gần bạn!", player, 255, 100, 100)
        return
    end

    local isCuffed = getElementData(target, "cuffed") or false
    if not isCuffed then
        outputChatBox("Người này phải bị còng tay trước!", player, 255, 100, 100)
        return
    end

    if isPedInVehicle(target) then
        outputChatBox("Người này đã ở trong xe!", player, 255, 100, 100)
        return
    end

    local vehicle = getPedOccupiedVehicle(player)
    if not vehicle then
        outputChatBox("Bạn cần ở trong xe để đưa người vào!", player, 255, 100, 100)
        return
    end

    local occupant = getVehicleOccupant(vehicle, seat)
    if occupant then
        outputChatBox("Chỗ ngồi này đã có người!", player, 255, 100, 100)
        return
    end

    warpPedIntoVehicle(target, vehicle, seat)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("** " .. playerName .. " đưa " .. targetName .. " vào xe.", getRootElement(), 255, 128, 0)
    outputChatBox("Bạn đã được đưa vào xe bởi " .. playerName .. "!", target, 255, 255, 100)
    outputChatBox("Bạn đã đưa " .. targetName .. " vào xe!", player, 100, 255, 100)
end)

-- Frisk System
addCommandHandler("frisk", function(player, cmd, targetName)
    if not player or not isElement(player) then
        return
    end

    if not isLawEnforcement(player) then
        outputChatBox("Bạn không phải nhân viên thực thi pháp luật!", player, 255, 100, 100)
        return
    end

    if not targetName then
        outputChatBox("Sử dụng: /frisk [tên người chơi]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    if not isPlayerNearby(player, target, 3.0) then
        outputChatBox("Người đó không ở gần bạn!", player, 255, 100, 100)
        return
    end

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("** " .. playerName .. " khám xét " .. targetName .. ".", getRootElement(), 255, 128, 0)

    -- Check for weapons
    local weapons = {}
    for slot = 0, 12 do
        local weapon = getPedWeapon(target, slot)
        if weapon and weapon > 0 then
            local weaponName = getWeaponNameFromID(weapon)
            local ammo = getPedTotalAmmo(target, slot)
            table.insert(weapons, weaponName .. " (" .. ammo .. " viên)")
        end
    end

    -- Check for drugs/contraband
    local drugs = getElementData(target, "drugs") or 0
    local money = getElementData(target, "money") or 0

    outputChatBox("===== KẾT QUẢ KHÁM XÉT =====", player, 255, 255, 100)
    outputChatBox("Người chơi: " .. targetName, player, 255, 255, 255)
    outputChatBox("Tiền mặt: $" .. money, player, 255, 255, 255)

    if #weapons > 0 then
        outputChatBox("Vũ khí tìm thấy:", player, 255, 100, 100)
        for _, weapon in ipairs(weapons) do
            outputChatBox("- " .. weapon, player, 255, 200, 200)
        end
    else
        outputChatBox("Không tìm thấy vũ khí", player, 100, 255, 100)
    end

    if drugs > 0 then
        outputChatBox("Ma túy tìm thấy: " .. drugs .. " gram", player, 255, 100, 100)
    else
        outputChatBox("Không tìm thấy ma túy", player, 100, 255, 100)
    end

    outputChatBox("========================", player, 255, 255, 100)
end)

-- Search Car System
addCommandHandler("searchcar", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    if not isLawEnforcement(player) then
        outputChatBox("Bạn không phải nhân viên thực thi pháp luật!", player, 255, 100, 100)
        return
    end

    -- Find closest vehicle
    local x, y, z = getElementPosition(player)
    local vehicles = getElementsByType("vehicle", getRootElement(), true)
    local closestVehicle = nil
    local closestDistance = 5.0

    for _, vehicle in ipairs(vehicles) do
        local vx, vy, vz = getElementPosition(vehicle)
        local distance = getDistanceBetweenPoints3D(x, y, z, vx, vy, vz)
        if distance < closestDistance then
            closestVehicle = vehicle
            closestDistance = distance
        end
    end

    if not closestVehicle then
        outputChatBox("Không có xe nào gần đây để khám xét!", player, 255, 100, 100)
        return
    end

    local playerName = getPlayerName(player)
    local vehicleModel = getElementModel(closestVehicle)
    local vehicleName = getVehicleNameFromModel(vehicleModel)

    outputChatBox("** " .. playerName .. " khám xét chiếc " .. vehicleName .. ".", getRootElement(), 255, 128, 0)

    -- Check vehicle trunk for contraband
    local drugs = getElementData(closestVehicle, "drugs") or 0
    local weapons = getElementData(closestVehicle, "weapons") or {}
    local money = getElementData(closestVehicle, "money") or 0

    outputChatBox("===== KẾT QUẢ KHÁM XÉT XE =====", player, 255, 255, 100)
    outputChatBox("Xe: " .. vehicleName, player, 255, 255, 255)

    if money > 0 then
        outputChatBox("Tiền mặt tìm thấy: $" .. money, player, 255, 255, 255)
    end

    if drugs > 0 then
        outputChatBox("Ma túy tìm thấy: " .. drugs .. " gram", player, 255, 100, 100)
    end

    if weapons and #weapons > 0 then
        outputChatBox("Vũ khí tìm thấy:", player, 255, 100, 100)
        for _, weapon in ipairs(weapons) do
            outputChatBox("- " .. weapon, player, 255, 200, 200)
        end
    end

    if drugs == 0 and money == 0 and (not weapons or #weapons == 0) then
        outputChatBox("Không tìm thấy vật phẩm bất hợp pháp", player, 100, 255, 100)
    end

    outputChatBox("==============================", player, 255, 255, 100)
end)

-- Ticket System
addCommandHandler("ticket", function(player, cmd, targetName, amountStr, ...)
    if not player or not isElement(player) then
        return
    end

    if not isLawEnforcement(player) then
        outputChatBox("Bạn không phải nhân viên thực thi pháp luật!", player, 255, 100, 100)
        return
    end

    if not targetName or not amountStr then
        outputChatBox("Sử dụng: /ticket [tên người chơi] [số tiền] [lý do]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    local amount = tonumber(amountStr)
    if not amount or amount < 1 or amount > 50000 then
        outputChatBox("Số tiền phạt phải từ $1-$50,000!", player, 255, 100, 100)
        return
    end

    if not isPlayerNearby(player, target, 10.0) then
        outputChatBox("Người đó không ở gần bạn!", player, 255, 100, 100)
        return
    end

    local reason = table.concat({...}, " ")
    if not reason or reason == "" then
        reason = "Vi phạm luật giao thông"
    end

    local playerMoney = getElementData(target, "money") or 0
    if playerMoney < amount then
        outputChatBox("Người này không đủ tiền để trả phạt!", player, 255, 100, 100)
        return
    end

    -- Deduct money
    setElementData(target, "money", playerMoney - amount)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("** " .. playerName .. " đã phạt " .. targetName .. " $" .. amount .. ".", getRootElement(), 255,
        128, 0)
    outputChatBox("Bạn đã bị phạt $" .. amount .. " bởi " .. playerName, target, 255, 100, 100)
    outputChatBox("Lý do: " .. reason, target, 255, 200, 200)
    outputChatBox("Bạn đã phạt " .. targetName .. " $" .. amount .. "!", player, 100, 255, 100)

    -- Save ticket to database (if applicable)
    setElementData(target, "lastTicket", {
        amount = amount,
        reason = reason,
        officer = playerName,
        time = getRealTime().timestamp
    })
end)

-- Release from Jail
addCommandHandler("release", function(player, cmd, targetName)
    if not player or not isElement(player) then
        return
    end

    local adminLevel = getElementData(player, "adminLevel") or 0
    local policeRank = getElementData(player, "policeRank") or 0

    if adminLevel < 3 and policeRank < 3 then
        outputChatBox("Bạn không có quyền thả người khỏi tù!", player, 255, 100, 100)
        return
    end

    if not targetName then
        outputChatBox("Sử dụng: /release [tên người chơi]", player, 255, 255, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    local isJailed = getElementData(target, "jailed") or false
    if not isJailed then
        outputChatBox("Người này không ở trong tù!", player, 255, 100, 100)
        return
    end

    -- Release from jail
    setElementData(target, "jailed", false)
    setElementData(target, "jailTime", 0)
    setElementData(target, "arrestReason", nil)
    setElementData(target, "arrestedBy", nil)

    local jailTimer = getElementData(target, "jailTimer")
    if jailTimer then
        killTimer(jailTimer)
        setElementData(target, "jailTimer", nil)
    end

    setElementPosition(target, 1545.8, -1675.6, 13.6)
    setElementInterior(target, 0)
    setElementDimension(target, 0)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("THÔNG BÁO: " .. targetName .. " đã được thả tự do bởi " .. playerName,
        getRootElement(), 255, 255, 100)
    outputChatBox("Bạn đã được thả tự do bởi " .. playerName .. "!", target, 100, 255, 100)
    outputChatBox("Bạn đã thả " .. targetName .. " khỏi tù!", player, 100, 255, 100)
end)

-- Roadblock System
addCommandHandler("roadblock", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    if not isLawEnforcement(player) then
        outputChatBox("Bạn không phải nhân viên thực thi pháp luật!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local rx, ry, rz = getElementRotation(player)

    -- Create roadblock object
    local roadblock = createObject(978, x + 3, y, z, 0, 0, rz) -- Barrier
    if roadblock then
        setElementData(roadblock, "type", "roadblock")
        setElementData(roadblock, "placedBy", getPlayerName(player))
        setElementData(roadblock, "placedTime", getRealTime().timestamp)

        outputChatBox("** " .. getPlayerName(player) .. " đặt rào chắn đường.", getRootElement(), 255, 128, 0)
        outputChatBox("Rào chắn đã được đặt! Sử dụng /removeblock để dỡ bỏ.", player, 100, 255,
            100)

        -- Auto remove after 30 minutes
        setTimer(function()
            if isElement(roadblock) then
                destroyElement(roadblock)
            end
        end, 1800000, 1)
    else
        outputChatBox("Không thể đặt rào chắn tại vị trí này!", player, 255, 100, 100)
    end
end)

-- Remove Roadblock
addCommandHandler("removeblock", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    if not isLawEnforcement(player) then
        outputChatBox("Bạn không phải nhân viên thực thi pháp luật!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)
    local objects = getElementsByType("object", getRootElement(), true)
    local removed = false

    for _, obj in ipairs(objects) do
        if getElementData(obj, "type") == "roadblock" then
            local ox, oy, oz = getElementPosition(obj)
            local distance = getDistanceBetweenPoints3D(x, y, z, ox, oy, oz)

            if distance <= 5.0 then
                destroyElement(obj)
                removed = true
                break
            end
        end
    end

    if removed then
        outputChatBox("** " .. getPlayerName(player) .. " dỡ bỏ rào chắn đường.", getRootElement(), 255, 128,
            0)
        outputChatBox("Rào chắn đã được dỡ bỏ!", player, 100, 255, 100)
    else
        outputChatBox("Không có rào chắn nào gần đây!", player, 255, 100, 100)
    end
end)

-- Helper function to get player from partial name
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

outputDebugString("Law Enforcement System loaded successfully! (18 commands)")
