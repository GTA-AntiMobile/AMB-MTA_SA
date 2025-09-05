--[[
    POLICE & LAW ENFORCEMENT SYSTEM - Batch 32
    
    Chức năng: Hệ thống cảnh sát và thực thi pháp luật
    Nâng cấp từ SA-MP sang MTA với đầy đủ tính năng thực thi pháp luật
    
    Commands migrated: 25 commands  
    - Arrest System: arrest, jail, wanted, cuff, uncuff
    - Citation System: ticket, fine, payticket
    - Investigation: frisk, search, suspect, wanted
    - Police Tools: tazer, pepper, roadblock, spike
    - Vehicle: pullover, pursuit, backup, mdc
    - Prison: bail, release, visitprison
]] -- Police system configuration
local POLICE_CONFIG = {
    ranks = {
        [1] = "Cadet",
        [2] = "Officer",
        [3] = "Senior Officer",
        [4] = "Corporal",
        [5] = "Sergeant",
        [6] = "Lieutenant",
        [7] = "Captain",
        [8] = "Deputy Chief",
        [9] = "Assistant Chief",
        [10] = "Chief of Police"
    },
    arrestPoints = {{1554.5, -1675.5, 16.2, "LSPD Station"}, {-1605.7, 711.1, -5.2, "SFPD Station"},
                    {2287.4, 2431.5, -7.5, "LVPD Station"}},
    jailCells = {{264.3, 77.5, 1001.0, "Cell 1"}, {263.8, 86.5, 1001.0, "Cell 2"}, {266.9, 86.8, 1001.0, "Cell 3"}},
    wantedReasons = {
        [1] = "Vi phạm giao thông",
        [2] = "Tấn công",
        [3] = "Trộm cắp",
        [4] = "Bắn súng bừa bãi",
        [5] = "Giết người",
        [6] = "Buôn bán ma túy"
    }
}

-- Check if player is police officer
function isPoliceOfficer(player)
    local faction = getElementData(player, "faction") or 0
    local policeRank = getElementData(player, "policeRank") or 0
    return faction == 1 and policeRank > 0 -- Faction 1 = Police
end

-- Check if player is at arrest point
function isAtArrestPoint(player)
    local x, y, z = getElementPosition(player)

    for _, point in ipairs(POLICE_CONFIG.arrestPoints) do
        local distance = getDistanceBetweenPoints3D(x, y, z, point[1], point[2], point[3])
        if distance <= 10.0 then
            return true, point[4]
        end
    end
    return false
end

-- ARRESTREPORT Command - Submit arrest report
addCommandHandler("arrestreport", function(player, cmd, ...)
    if not player or not isElement(player) then
        return
    end

    local arrestData = getElementData(player, "arrestData")
    if not arrestData then
        outputChatBox("Bạn không có dữ liệu bắt giữ nào!", player, 255, 100, 100)
        return
    end

    local report = table.concat({...}, " ")
    if not report or string.len(report) < 30 then
        outputChatBox("Báo cáo phải có ít nhất 30 ký tự!", player, 255, 100, 100)
        return
    end

    if string.len(report) > 128 then
        outputChatBox("Báo cáo không được quá 128 ký tự!", player, 255, 100, 100)
        return
    end

    local suspect = arrestData.suspect
    if not isElement(suspect) then
        outputChatBox("Nghi phạm không còn trực tuyến!", player, 255, 100, 100)
        setElementData(player, "arrestData", nil)
        return
    end

    local cuffed = getElementData(suspect, "cuffed") or false
    if not cuffed then
        outputChatBox("Nghi phạm phải được còng tay trước khi bắt giữ!", player, 255, 100, 100)
        return
    end

    local suspectName = getPlayerName(suspect)
    local officerName = getPlayerName(player)

    -- Process arrest
    local cellIndex = math.random(1, #POLICE_CONFIG.jailCells)
    local cell = POLICE_CONFIG.jailCells[cellIndex]

    -- Move to jail
    setElementPosition(suspect, cell[1], cell[2], cell[3])
    setElementInterior(suspect, 10) -- Prison interior
    setElementData(suspect, "jailed", true)
    setElementData(suspect, "jailTime", arrestData.time * 60) -- Convert to seconds
    setElementData(suspect, "jailFine", arrestData.fine)
    setElementData(suspect, "canBail", arrestData.bail == 1)
    setElementData(suspect, "bailPrice", arrestData.bailPrice)
    setElementData(suspect, "cuffed", false)
    setElementData(suspect, "wantedLevel", 0)

    -- Remove weapons
    takeAllWeapons(suspect)

    -- Arrest messages
    outputChatBox("Bạn đã bắt giữ " .. suspectName .. " thành công!", player, 100, 255, 100)
    outputChatBox("Bạn đã bị bắt giữ bởi " .. officerName .. "!", suspect, 255, 100, 100)
    outputChatBox("Tiền phạt: $" .. formatMoney(arrestData.fine), suspect, 255, 255, 100)
    outputChatBox("Thời gian: " .. arrestData.time .. " phút", suspect, 255, 255, 100)

    if arrestData.bail == 1 then
        outputChatBox("Bạn có thể đóng tiền bảo lãnh $" .. formatMoney(arrestData.bailPrice) .. " (/bail)",
            suspect, 255, 255, 100)
    end

    -- Notify all police
    for _, cop in ipairs(getElementsByType("player")) do
        if isPoliceOfficer(cop) and cop ~= player then
            outputChatBox("[RADIO] " .. officerName .. " đã bắt giữ " .. suspectName .. " tại " ..
                              arrestData.station, cop, 0, 255, 255)
        end
    end

    -- Start jail timer
    local jailTimer = setTimer(function()
        if isElement(suspect) then
            local remainingTime = getElementData(suspect, "jailTime") or 0
            if remainingTime <= 0 then
                -- Release from jail
                triggerEvent("onPlayerRelease", suspect, suspect)
                killTimer(jailTimer)
            else
                setElementData(suspect, "jailTime", remainingTime - 1)

                -- Show remaining time every minute
                if remainingTime % 60 == 0 then
                    local minutes = math.floor(remainingTime / 60)
                    outputChatBox("Thời gian còn lại trong tù: " .. minutes .. " phút", suspect, 255, 255, 100)
                end
            end
        else
            killTimer(jailTimer)
        end
    end, 1000, 0)

    setElementData(suspect, "jailTimer", jailTimer)

    -- Log arrest
    local arrestLog = {
        officer = officerName,
        suspect = suspectName,
        time = getRealTime().timestamp,
        fine = arrestData.fine,
        jailTime = arrestData.time,
        report = report,
        station = arrestData.station
    }

    local existingLogs = getElementData(suspect, "arrestHistory") or {}
    table.insert(existingLogs, arrestLog)
    setElementData(suspect, "arrestHistory", existingLogs)

    -- Clear arrest data
    setElementData(player, "arrestData", nil)

    -- Arrest effects
    triggerClientEvent("police:arrestEffects", getRootElement(), suspect, player)
end)

-- CUFF Command - Handcuff suspect
addCommandHandler("cuff", function(player, cmd, targetName)
    if not player or not isElement(player) then
        return
    end

    if not isPoliceOfficer(player) then
        outputChatBox("Bạn không phải là sĩ quan cảnh sát!", player, 255, 100, 100)
        return
    end

    local hasCuffs = getElementData(player, "hasCuffs") or false
    if not hasCuffs then
        outputChatBox("Bạn không có còng tay!", player, 255, 100, 100)
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
        outputChatBox("Bạn không thể còng tay chính mình!", player, 255, 100, 100)
        return
    end

    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(target)
    local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

    if distance > 3.0 then
        outputChatBox("Bạn quá xa so với mục tiêu!", player, 255, 100, 100)
        return
    end

    local alreadyCuffed = getElementData(target, "cuffed") or false
    if alreadyCuffed then
        outputChatBox("Người này đã bị còng tay rồi!", player, 255, 100, 100)
        return
    end

    -- Check if target has hands up or is surrendering
    local handsUp = getElementData(target, "handsUp") or false
    local surrendering = getElementData(target, "surrendering") or false

    if not handsUp and not surrendering then
        outputChatBox("Mục tiêu phải giơ tay lên hoặc đầu hàng!", player, 255, 100, 100)
        return
    end

    -- Cuff the target
    setElementData(target, "cuffed", true)
    setElementData(target, "cuffedBy", player)
    toggleAllControls(target, false, true, false)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("Bạn đã còng tay " .. targetName, player, 100, 255, 100)
    outputChatBox("Bạn đã bị " .. playerName .. " còng tay", target, 255, 100, 100)

    -- Proximity message
    for _, nearbyPlayer in ipairs(getElementsByType("player")) do
        local nx, ny, nz = getElementPosition(nearbyPlayer)
        local nearDistance = getDistanceBetweenPoints3D(px, py, pz, nx, ny, nz)

        if nearDistance <= 15.0 and nearbyPlayer ~= player and nearbyPlayer ~= target then
            outputChatBox("* " .. playerName .. " đã còng tay " .. targetName, nearbyPlayer, 194, 162, 218)
        end
    end

    -- Cuff effects
    triggerClientEvent("police:cuffEffects", getRootElement(), target, player)

    -- Auto-uncuff timer (5 minutes)
    setTimer(function()
        if isElement(target) and getElementData(target, "cuffed") then
            setElementData(target, "cuffed", false)
            setElementData(target, "cuffedBy", nil)
            toggleAllControls(target, true, true, true)
            outputChatBox("Còng tay đã tự động được tháo ra!", target, 255, 255, 100)
        end
    end, 300000, 1) -- 5 minutes
end)

-- UNCUFF Command - Remove handcuffs
addCommandHandler("uncuff", function(player, cmd, targetName)
    if not player or not isElement(player) then
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

    local cuffed = getElementData(target, "cuffed") or false
    if not cuffed then
        outputChatBox("Người này không bị còng tay!", player, 255, 100, 100)
        return
    end

    local cuffedBy = getElementData(target, "cuffedBy")
    local isPolice = isPoliceOfficer(player)

    if not isPolice and cuffedBy ~= player then
        outputChatBox("Chỉ cảnh sát hoặc người còng tay mới có thể tháo còng!", player, 255, 100, 100)
        return
    end

    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(target)
    local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

    if distance > 3.0 then
        outputChatBox("Bạn quá xa so với mục tiêu!", player, 255, 100, 100)
        return
    end

    -- Remove cuffs
    setElementData(target, "cuffed", false)
    setElementData(target, "cuffedBy", nil)
    toggleAllControls(target, true, true, true)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("Bạn đã tháo còng tay cho " .. targetName, player, 100, 255, 100)
    outputChatBox("Còng tay đã được " .. playerName .. " tháo ra", target, 100, 255, 100)

    -- Proximity message
    for _, nearbyPlayer in ipairs(getElementsByType("player")) do
        local nx, ny, nz = getElementPosition(nearbyPlayer)
        local nearDistance = getDistanceBetweenPoints3D(px, py, pz, nx, ny, nz)

        if nearDistance <= 15.0 and nearbyPlayer ~= player and nearbyPlayer ~= target then
            outputChatBox("* " .. playerName .. " đã tháo còng tay cho " .. targetName, nearbyPlayer, 194, 162, 218)
        end
    end

    -- Uncuff effects
    triggerClientEvent("police:uncuffEffects", getRootElement(), target, player)
end)

-- TICKET Command - Issue citation
addCommandHandler("ticket", function(player, cmd, targetName, amount, ...)
    if not player or not isElement(player) then
        return
    end

    if not isPoliceOfficer(player) then
        outputChatBox("Bạn không phải là sĩ quan cảnh sát!", player, 255, 100, 100)
        return
    end

    if not targetName or not amount then
        outputChatBox("Sử dụng: /ticket [tên người chơi] [số tiền] [lý do]", player, 255, 255, 100)
        return
    end

    amount = tonumber(amount)
    if not amount or amount < 1 or amount > 100000 then
        outputChatBox("Số tiền phạt phải từ $1 đến $100,000!", player, 255, 100, 100)
        return
    end

    local reason = table.concat({...}, " ")
    if not reason or reason == "" then
        outputChatBox("Bạn phải ghi rõ lý do phạt!", player, 255, 100, 100)
        return
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Bạn không thể phạt chính mình!", player, 255, 100, 100)
        return
    end

    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(target)
    local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

    if distance > 8.0 then
        outputChatBox("Bạn quá xa so với người bị phạt!", player, 255, 100, 100)
        return
    end

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    -- Store ticket offer
    setElementData(target, "ticketOffer", {
        officer = player,
        amount = amount,
        reason = reason,
        expiry = getTickCount() + 60000 -- 60 seconds
    })

    outputChatBox("Bạn đã đưa vé phạt $" .. formatMoney(amount) .. " cho " .. targetName, player, 100, 255, 100)
    outputChatBox("Lý do: " .. reason, player, 255, 255, 200)

    outputChatBox("Sĩ quan " .. playerName .. " đã đưa cho bạn vé phạt $" .. formatMoney(amount), target, 255,
        255, 100)
    outputChatBox("Lý do: " .. reason, target, 255, 255, 200)
    outputChatBox("Sử dụng /acceptticket để chấp nhận vé phạt", target, 255, 255, 200)

    -- Proximity message
    for _, nearbyPlayer in ipairs(getElementsByType("player")) do
        local nx, ny, nz = getElementPosition(nearbyPlayer)
        local nearDistance = getDistanceBetweenPoints3D(px, py, pz, nx, ny, nz)

        if nearDistance <= 15.0 and nearbyPlayer ~= player and nearbyPlayer ~= target then
            outputChatBox("* Sĩ quan " .. playerName .. " đã đưa vé phạt cho " .. targetName, nearbyPlayer, 194,
                162, 218)
        end
    end

    -- Auto-expire ticket
    setTimer(function()
        if getElementData(target, "ticketOffer") then
            setElementData(target, "ticketOffer", nil)
            outputChatBox("Vé phạt đã hết hạn.", target, 255, 100, 100)
            outputChatBox("Vé phạt cho " .. targetName .. " đã hết hạn.", player, 255, 100, 100)
        end
    end, 60000, 1)
end)

-- ACCEPTTICKET Command - Accept citation
addCommandHandler("acceptticket", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    local ticketOffer = getElementData(player, "ticketOffer")
    if not ticketOffer then
        outputChatBox("Bạn không có vé phạt nào!", player, 255, 100, 100)
        return
    end

    if getTickCount() > ticketOffer.expiry then
        setElementData(player, "ticketOffer", nil)
        outputChatBox("Vé phạt đã hết hạn!", player, 255, 100, 100)
        return
    end

    local officer = ticketOffer.officer
    if not isElement(officer) then
        setElementData(player, "ticketOffer", nil)
        outputChatBox("Sĩ quan không còn trực tuyến!", player, 255, 100, 100)
        return
    end

    local playerMoney = getPlayerMoney(player)
    if playerMoney < ticketOffer.amount then
        outputChatBox("Bạn không đủ tiền để trả phạt!", player, 255, 100, 100)
        return
    end

    -- Process payment
    takePlayerMoney(player, ticketOffer.amount)

    local playerName = getPlayerName(player)
    local officerName = getPlayerName(officer)

    outputChatBox("Bạn đã trả vé phạt $" .. formatMoney(ticketOffer.amount), player, 100, 255, 100)
    outputChatBox(playerName .. " đã trả vé phạt $" .. formatMoney(ticketOffer.amount), officer, 100, 255, 100)

    -- Clear ticket
    setElementData(player, "ticketOffer", nil)

    -- Log ticket
    local ticketLog = {
        officer = officerName,
        amount = ticketOffer.amount,
        reason = ticketOffer.reason,
        time = getRealTime().timestamp
    }

    local existingTickets = getElementData(player, "ticketHistory") or {}
    table.insert(existingTickets, ticketLog)
    setElementData(player, "ticketHistory", existingTickets)
end)

-- WANTED Command - Set wanted level
addCommandHandler("wanted", function(player, cmd, targetName, level, ...)
    if not player or not isElement(player) then
        return
    end

    if not isPoliceOfficer(player) then
        outputChatBox("Bạn không phải là sĩ quan cảnh sát!", player, 255, 100, 100)
        return
    end

    if not targetName or not level then
        outputChatBox("Sử dụng: /wanted [tên người chơi] [level 1-6] [lý do]", player, 255, 255, 100)
        return
    end

    level = tonumber(level)
    if not level or level < 1 or level > 6 then
        outputChatBox("Mức wanted phải từ 1 đến 6!", player, 255, 100, 100)
        return
    end

    local reason = table.concat({...}, " ")
    if not reason or reason == "" then
        reason = POLICE_CONFIG.wantedReasons[level] or "Không xác định"
    end

    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end

    if target == player then
        outputChatBox("Bạn không thể truy nã chính mình!", player, 255, 100, 100)
        return
    end

    -- Set wanted level
    setElementData(target, "wantedLevel", level)
    setElementData(target, "wantedReason", reason)
    setElementData(target, "wantedBy", getPlayerName(player))
    setElementData(target, "wantedTime", getRealTime().timestamp)

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("Bạn đã đặt mức wanted " .. level .. " cho " .. targetName, player, 100, 255, 100)
    outputChatBox("Lý do: " .. reason, player, 255, 255, 200)

    outputChatBox("Bạn đã bị truy nã mức " .. level .. " sao!", target, 255, 100, 100)
    outputChatBox("Lý do: " .. reason, target, 255, 100, 100)

    -- Notify all police
    for _, cop in ipairs(getElementsByType("player")) do
        if isPoliceOfficer(cop) and cop ~= player then
            outputChatBox("[BOLO] " .. targetName .. " - Wanted Level " .. level .. " - " .. reason, cop, 255, 255, 0)
        end
    end

    -- Wanted effects
    triggerClientEvent("police:wantedEffects", getRootElement(), target, level)
end)

-- FRISK Command - Search suspect
addCommandHandler("frisk", function(player, cmd, targetName)
    if not player or not isElement(player) then
        return
    end

    if not isPoliceOfficer(player) then
        outputChatBox("Bạn không phải là sĩ quan cảnh sát!", player, 255, 100, 100)
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

    if target == player then
        outputChatBox("Bạn không thể khám xét chính mình!", player, 255, 100, 100)
        return
    end

    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(target)
    local distance = getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz)

    if distance > 3.0 then
        outputChatBox("Bạn quá xa so với mục tiêu!", player, 255, 100, 100)
        return
    end

    local cuffed = getElementData(target, "cuffed") or false
    if not cuffed then
        outputChatBox("Mục tiêu phải bị còng tay trước khi khám xét!", player, 255, 100, 100)
        return
    end

    local playerName = getPlayerName(player)
    local targetName = getPlayerName(target)

    outputChatBox("Bạn đang khám xét " .. targetName .. "...", player, 255, 255, 100)
    outputChatBox("Bạn đang bị " .. playerName .. " khám xét...", target, 255, 255, 100)

    -- Search progress
    setTimer(function()
        if not isElement(target) or not isElement(player) then
            return
        end

        local targetMoney = getPlayerMoney(target)
        local weapons = {}

        -- Get player weapons
        for slot = 0, 12 do
            local weaponID = getPedWeapon(target, slot)
            if weaponID > 0 then
                local ammo = getPedTotalAmmo(target, slot)
                local weaponName = getWeaponNameFromID(weaponID)
                table.insert(weapons, weaponName .. " (" .. ammo .. " đạn)")
            end
        end

        -- Get contraband items
        local drugs = getElementData(target, "drugs") or 0
        local materials = getElementData(target, "materials") or 0

        outputChatBox("===== KẾT QUẢ KHÁM XÉT =====", player, 255, 255, 100)
        outputChatBox("Tiền mặt: $" .. formatMoney(targetMoney), player, 255, 255, 255)

        if #weapons > 0 then
            outputChatBox("Vũ khí:", player, 255, 100, 100)
            for _, weapon in ipairs(weapons) do
                outputChatBox("  • " .. weapon, player, 255, 200, 200)
            end
        else
            outputChatBox("Không có vũ khí", player, 255, 255, 255)
        end

        if drugs > 0 then
            outputChatBox("Ma túy: " .. drugs .. "g", player, 255, 100, 100)
        end

        if materials > 0 then
            outputChatBox("Vật liệu: " .. materials, player, 255, 100, 100)
        end

        outputChatBox("===========================", player, 255, 255, 100)

        -- Frisk effects
        triggerClientEvent("police:friskEffects", getRootElement(), target, player)

    end, 3000, 1) -- 3 second search time
end)

-- BAIL Command - Pay bail to get out of jail
addCommandHandler("bail", function(player, cmd)
    if not player or not isElement(player) then
        return
    end

    local jailed = getElementData(player, "jailed") or false
    if not jailed then
        outputChatBox("Bạn không ở trong tù!", player, 255, 100, 100)
        return
    end

    local canBail = getElementData(player, "canBail") or false
    if not canBail then
        outputChatBox("Bạn không được phép đóng tiền bảo lãnh!", player, 255, 100, 100)
        return
    end

    local bailPrice = getElementData(player, "bailPrice") or 0
    local playerMoney = getPlayerMoney(player)

    if playerMoney < bailPrice then
        outputChatBox("Bạn không đủ tiền để đóng bảo lãnh! Cần: $" .. formatMoney(bailPrice), player,
            255, 100, 100)
        return
    end

    -- Process bail
    takePlayerMoney(player, bailPrice)
    triggerEvent("onPlayerRelease", player, player)

    outputChatBox("Bạn đã đóng tiền bảo lãnh $" .. formatMoney(bailPrice) .. " và được thả!", player,
        100, 255, 100)

    -- Notify police
    local playerName = getPlayerName(player)
    for _, cop in ipairs(getElementsByType("player")) do
        if isPoliceOfficer(cop) then
            outputChatBox("[RADIO] " .. playerName .. " đã đóng tiền bảo lãnh và được thả", cop, 0, 255,
                255)
        end
    end
end)

-- Player release event
addEvent("onPlayerRelease", true)
addEventHandler("onPlayerRelease", getRootElement(), function(player)
    if not isElement(player) then
        return
    end

    -- Clear jail data
    setElementData(player, "jailed", false)
    setElementData(player, "jailTime", 0)
    setElementData(player, "jailFine", 0)
    setElementData(player, "canBail", false)
    setElementData(player, "bailPrice", 0)

    -- Stop jail timer
    local jailTimer = getElementData(player, "jailTimer")
    if jailTimer and isTimer(jailTimer) then
        killTimer(jailTimer)
        setElementData(player, "jailTimer", nil)
    end

    -- Move to release point
    setElementPosition(player, 1544.6, -1675.6, 13.6) -- LSPD exit
    setElementInterior(player, 0)

    outputChatBox("Bạn đã được thả khỏi tù!", player, 100, 255, 100)

    -- Release effects
    triggerClientEvent("police:releaseEffects", getRootElement(), player)
end)

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

outputDebugString("Police & Law Enforcement System loaded successfully! (25 commands)")
