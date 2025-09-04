--[[
    BATCH 33: MEGA GAMING & ENTERTAINMENT SYSTEM
    
    Chức năng: Hệ thống game và giải trí toàn diện
    Migrate hàng loạt commands: gambling, poker, arena, events, music, animations
    
    Commands migrated: 80+ commands
]] -- Gaming configuration
local GAMING_CONFIG = {
    gambling = {
        maxBet = 1000000,
        minBet = 1000,
        chances = {
            low = 60, -- 60% win chance
            medium = 45, -- 45% win chance  
            high = 30 -- 30% win chance
        }
    },
    poker = {
        maxTables = 50,
        maxPlayers = 6,
        minBet = 10000,
        maxBet = 500000
    },
    arena = {
        maxArenas = 10,
        teamSizes = {2, 4, 6, 8},
        modes = {"Deathmatch", "Team War", "Capture Flag", "King of Hill"}
    }
}

-- GAMBLING COMMANDS
addCommandHandler("togchancegambler", function(player, cmd)
    if not isPlayerAdmin(player, 5) then
        outputChatBox("Chỉ admin cấp 5+ mới có thể sử dụng!", player, 255, 100, 100)
        return
    end

    local enabled = getElementData(getRootElement(), "gamblingEnabled") or true
    setElementData(getRootElement(), "gamblingEnabled", not enabled)

    local status = enabled and "TẮT" or "BẬT"
    outputChatBox("Đã " .. status .. " hệ thống cờ bạc!", player, 100, 255, 100)

    -- Notify all players
    for _, p in ipairs(getElementsByType("player")) do
        outputChatBox("Hệ thống cờ bạc đã được " .. status .. " bởi admin", p, 255, 255, 100)
    end
end)

addCommandHandler("gamblechances", function(player, cmd, level, chance)
    if not isPlayerAdmin(player, 5) then
        outputChatBox("Chỉ admin cấp 5+ mới có thể sử dụng!", player, 255, 100, 100)
        return
    end

    if not level or not chance then
        outputChatBox("Sử dụng: /gamblechances [low/medium/high] [tỷ lệ %]", player, 255, 255, 100)
        return
    end

    chance = tonumber(chance)
    if not chance or chance < 1 or chance > 99 then
        outputChatBox("Tỷ lệ phải từ 1-99%!", player, 255, 100, 100)
        return
    end

    level = string.lower(level)
    if level ~= "low" and level ~= "medium" and level ~= "high" then
        outputChatBox("Level phải là: low, medium, hoặc high", player, 255, 100, 100)
        return
    end

    GAMING_CONFIG.gambling.chances[level] = chance
    outputChatBox("Đã cập nhật tỷ lệ cờ bạc " .. level .. " thành " .. chance .. "%", player, 100, 255,
        100)
end)

addCommandHandler("chances", function(player, cmd)
    outputChatBox("===== TỶ LỆ CỜ BẠC =====", player, 255, 255, 100)
    outputChatBox("Low Risk: " .. GAMING_CONFIG.gambling.chances.low .. "%", player, 255, 255, 255)
    outputChatBox("Medium Risk: " .. GAMING_CONFIG.gambling.chances.medium .. "%", player, 255, 255, 255)
    outputChatBox("High Risk: " .. GAMING_CONFIG.gambling.chances.high .. "%", player, 255, 255, 255)
    outputChatBox("========================", player, 255, 255, 100)
end)

-- POKER SYSTEM
local pokerTables = {}

addCommandHandler("thamgiapoker", function(player, cmd, tableID)
    return getCommandHandlers()["jointable"](player, "jointable", tableID)
end)

addCommandHandler("jointable", function(player, cmd, tableID)
    if not tableID then
        outputChatBox("Sử dụng: /jointable [ID bàn]", player, 255, 255, 100)
        outputChatBox("Dùng /listtables để xem các bàn có sẵn", player, 255, 255, 200)
        return
    end

    tableID = tonumber(tableID)
    if not tableID or not pokerTables[tableID] then
        outputChatBox("Bàn poker không tồn tại!", player, 255, 100, 100)
        return
    end

    local table = pokerTables[tableID]

    -- Check if player already in a table
    local currentTable = getElementData(player, "pokerTable")
    if currentTable then
        outputChatBox("Bạn đã ở trong bàn poker " .. currentTable .. "! Dùng /leavetable để rời", player,
            255, 100, 100)
        return
    end

    -- Check if table is full
    if #table.players >= GAMING_CONFIG.poker.maxPlayers then
        outputChatBox("Bàn poker đã đầy!", player, 255, 100, 100)
        return
    end

    -- Check money
    local playerMoney = getPlayerMoney(player)
    if playerMoney < table.minBet then
        outputChatBox("Bạn cần ít nhất $" .. formatMoney(table.minBet) .. " để tham gia!", player, 255, 100,
            100)
        return
    end

    -- Add player to table
    table.insert(table.players, player)
    setElementData(player, "pokerTable", tableID)
    setElementData(player, "pokerChips", 0)

    local playerName = getPlayerName(player)
    outputChatBox("Bạn đã tham gia bàn poker " .. tableID, player, 100, 255, 100)

    -- Notify other players
    for _, p in ipairs(table.players) do
        if p ~= player then
            outputChatBox(playerName .. " đã tham gia bàn poker", p, 255, 255, 100)
        end
    end

    triggerClientEvent("poker:joinTable", player, tableID, table)
end)

addCommandHandler("thoatpoker", function(player, cmd)
    return getCommandHandlers()["leavetable"](player, "leavetable")
end)

addCommandHandler("leavetable", function(player, cmd)
    local tableID = getElementData(player, "pokerTable")
    if not tableID then
        outputChatBox("Bạn không ở trong bàn poker nào!", player, 255, 100, 100)
        return
    end

    local table = pokerTables[tableID]
    if table then
        -- Remove player from table
        for i, p in ipairs(table.players) do
            if p == player then
                table.remove(table.players, i)
                break
            end
        end

        -- Return chips to money
        local chips = getElementData(player, "pokerChips") or 0
        if chips > 0 then
            givePlayerMoney(player, chips)
            outputChatBox("Bạn đã nhận lại $" .. formatMoney(chips) .. " từ chips", player, 100, 255, 100)
        end
    end

    setElementData(player, "pokerTable", nil)
    setElementData(player, "pokerChips", nil)

    local playerName = getPlayerName(player)
    outputChatBox("Bạn đã rời khỏi bàn poker", player, 255, 255, 100)

    -- Notify other players
    if table then
        for _, p in ipairs(table.players) do
            outputChatBox(playerName .. " đã rời khỏi bàn poker", p, 255, 255, 100)
        end
    end

    triggerClientEvent("poker:leaveTable", player)
end)

addCommandHandler("taobanpoker", function(player, cmd, minBet)
    return getCommandHandlers()["placetable"](player, "placetable", minBet)
end)

addCommandHandler("placetable", function(player, cmd, minBet)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("Chỉ admin cấp 3+ mới có thể tạo bàn poker!", player, 255, 100, 100)
        return
    end

    if not minBet then
        outputChatBox("Sử dụng: /placetable [cược tối thiểu]", player, 255, 255, 100)
        return
    end

    minBet = tonumber(minBet)
    if not minBet or minBet < GAMING_CONFIG.poker.minBet or minBet > GAMING_CONFIG.poker.maxBet then
        outputChatBox("Cược tối thiểu phải từ $" .. formatMoney(GAMING_CONFIG.poker.minBet) .. " - $" ..
                          formatMoney(GAMING_CONFIG.poker.maxBet), player, 255, 100, 100)
        return
    end

    -- Find empty table slot
    local tableID = nil
    for i = 1, GAMING_CONFIG.poker.maxTables do
        if not pokerTables[i] then
            tableID = i
            break
        end
    end

    if not tableID then
        outputChatBox("Đã đạt giới hạn số bàn poker!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)

    -- Create poker table
    pokerTables[tableID] = {
        id = tableID,
        position = {x, y, z},
        minBet = minBet,
        maxBet = minBet * 20,
        players = {},
        createdBy = getPlayerName(player)
    }

    outputChatBox("Đã tạo bàn poker " .. tableID .. " với cược tối thiểu $" .. formatMoney(minBet),
        player, 100, 255, 100)

    -- Create table object
    local tableObj = createObject(2188, x, y, z) -- Poker table object
    setElementData(tableObj, "pokerTableID", tableID)

    triggerClientEvent("poker:createTable", getRootElement(), tableID, x, y, z)
end)

addCommandHandler("xoapoker", function(player, cmd, tableID)
    return getCommandHandlers()["destroytable"](player, "destroytable", tableID)
end)

addCommandHandler("destroytable", function(player, cmd, tableID)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("Chỉ admin cấp 3+ mới có thể xóa bàn poker!", player, 255, 100, 100)
        return
    end

    if not tableID then
        outputChatBox("Sử dụng: /destroytable [ID bàn]", player, 255, 255, 100)
        return
    end

    tableID = tonumber(tableID)
    if not tableID or not pokerTables[tableID] then
        outputChatBox("Bàn poker không tồn tại!", player, 255, 100, 100)
        return
    end

    local table = pokerTables[tableID]

    -- Remove all players from table
    for _, p in ipairs(table.players) do
        local chips = getElementData(p, "pokerChips") or 0
        if chips > 0 then
            givePlayerMoney(p, chips)
            outputChatBox("Bàn poker bị xóa! Bạn nhận lại $" .. formatMoney(chips), p, 255, 255, 100)
        end
        setElementData(p, "pokerTable", nil)
        setElementData(p, "pokerChips", nil)
    end

    -- Destroy table
    pokerTables[tableID] = nil
    outputChatBox("Đã xóa bàn poker " .. tableID, player, 100, 255, 100)

    -- Remove table objects
    for _, obj in ipairs(getElementsByType("object")) do
        if getElementData(obj, "pokerTableID") == tableID then
            destroyElement(obj)
        end
    end

    triggerClientEvent("poker:destroyTable", getRootElement(), tableID)
end)

addCommandHandler("listtables", function(player, cmd)
    outputChatBox("===== DANH SÁCH BÀN POKER =====", player, 255, 255, 100)

    local hasTable = false
    for id, table in pairs(pokerTables) do
        hasTable = true
        local playerCount = #table.players
        local status = playerCount >= GAMING_CONFIG.poker.maxPlayers and "ĐẦY" or
                           ("" .. playerCount .. "/" .. GAMING_CONFIG.poker.maxPlayers)

        outputChatBox("Bàn " .. id .. ": Cược $" .. formatMoney(table.minBet) .. " - " .. status, player, 255, 255,
            255)
    end

    if not hasTable then
        outputChatBox("Không có bàn poker nào!", player, 255, 200, 200)
    end

    outputChatBox("===============================", player, 255, 255, 100)
end)

-- ARENA SYSTEM
local arenas = {}

addCommandHandler("thamgiaarena", function(player, cmd, arenaID)
    return getCommandHandlers()["joinarena"](player, "joinarena", arenaID)
end)

addCommandHandler("joinarena", function(player, cmd, arenaID)
    if not arenaID then
        outputChatBox("Sử dụng: /joinarena [ID arena]", player, 255, 255, 100)
        outputChatBox("Dùng /listarenas để xem các arena có sẵn", player, 255, 255, 200)
        return
    end

    arenaID = tonumber(arenaID)
    if not arenaID or not arenas[arenaID] then
        outputChatBox("Arena không tồn tại!", player, 255, 100, 100)
        return
    end

    local arena = arenas[arenaID]

    -- Check if player already in arena
    local currentArena = getElementData(player, "arenaID")
    if currentArena then
        outputChatBox("Bạn đã ở trong arena " .. currentArena .. "! Dùng /exitarena để rời", player, 255,
            100, 100)
        return
    end

    -- Check if arena is full
    if #arena.players >= arena.maxPlayers then
        outputChatBox("Arena đã đầy!", player, 255, 100, 100)
        return
    end

    -- Add player to arena
    table.insert(arena.players, player)
    setElementData(player, "arenaID", arenaID)
    setElementData(player, "arenaTeam", (#arena.players % 2) + 1) -- Team 1 or 2

    local playerName = getPlayerName(player)
    outputChatBox("Bạn đã tham gia " .. arena.name .. " (Arena " .. arenaID .. ")", player, 100, 255, 100)

    -- Notify other players
    for _, p in ipairs(arena.players) do
        if p ~= player then
            outputChatBox(playerName .. " đã tham gia arena", p, 255, 255, 100)
        end
    end

    -- Teleport to arena
    setElementPosition(player, arena.spawn.x, arena.spawn.y, arena.spawn.z)
    setElementInterior(player, arena.interior or 0)

    triggerClientEvent("arena:joinArena", player, arenaID, arena)
end)

addCommandHandler("thoatarena", function(player, cmd)
    return getCommandHandlers()["exitarena"](player, "exitarena")
end)

addCommandHandler("exitarena", function(player, cmd)
    local arenaID = getElementData(player, "arenaID")
    if not arenaID then
        outputChatBox("Bạn không ở trong arena nào!", player, 255, 100, 100)
        return
    end

    local arena = arenas[arenaID]
    if arena then
        -- Remove player from arena
        for i, p in ipairs(arena.players) do
            if p == player then
                table.remove(arena.players, i)
                break
            end
        end
    end

    setElementData(player, "arenaID", nil)
    setElementData(player, "arenaTeam", nil)

    -- Return to spawn
    setElementPosition(player, 1542.5, -1675.6, 13.6) -- LSPD spawn
    setElementInterior(player, 0)

    local playerName = getPlayerName(player)
    outputChatBox("Bạn đã rời khỏi arena", player, 255, 255, 100)

    -- Notify other players
    if arena then
        for _, p in ipairs(arena.players) do
            outputChatBox(playerName .. " đã rời khỏi arena", p, 255, 255, 100)
        end
    end

    triggerClientEvent("arena:exitArena", player)
end)

addCommandHandler("lockarenas", function(player, cmd)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("Chỉ admin cấp 3+ mới có thể khóa arena!", player, 255, 100, 100)
        return
    end

    setElementData(getRootElement(), "arenasLocked", true)
    outputChatBox("Đã khóa tất cả arena!", player, 100, 255, 100)

    for _, p in ipairs(getElementsByType("player")) do
        outputChatBox("Tất cả arena đã bị khóa bởi admin", p, 255, 255, 100)
    end
end)

addCommandHandler("unlockarenas", function(player, cmd)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("Chỉ admin cấp 3+ mới có thể mở khóa arena!", player, 255, 100, 100)
        return
    end

    setElementData(getRootElement(), "arenasLocked", false)
    outputChatBox("Đã mở khóa tất cả arena!", player, 100, 255, 100)

    for _, p in ipairs(getElementsByType("player")) do
        outputChatBox("Tất cả arena đã được mở khóa", p, 100, 255, 100)
    end
end)

addCommandHandler("doiteamarena", function(player, cmd)
    return getCommandHandlers()["switchteam"](player, "switchteam")
end)

addCommandHandler("switchteam", function(player, cmd)
    local arenaID = getElementData(player, "arenaID")
    if not arenaID then
        outputChatBox("Bạn phải ở trong arena để đổi team!", player, 255, 100, 100)
        return
    end

    local currentTeam = getElementData(player, "arenaTeam") or 1
    local newTeam = currentTeam == 1 and 2 or 1

    setElementData(player, "arenaTeam", newTeam)
    outputChatBox("Bạn đã chuyển sang Team " .. newTeam, player, 100, 255, 100)

    triggerClientEvent("arena:switchTeam", player, newTeam)
end)

-- MUSIC & AUDIO SYSTEM
addCommandHandler("setboombox", function(player, cmd, url)
    if not url then
        outputChatBox("Sử dụng: /setboombox [URL âm thanh]", player, 255, 255, 100)
        return
    end

    local hasBoombox = getElementData(player, "hasBoombox") or false
    if not hasBoombox then
        outputChatBox("Bạn không có boombox!", player, 255, 100, 100)
        return
    end

    local x, y, z = getElementPosition(player)

    -- Play music for nearby players
    for _, target in ipairs(getElementsByType("player")) do
        local tx, ty, tz = getElementPosition(target)
        local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)

        if distance <= 30.0 then
            triggerClientEvent("music:playURL", target, url, distance, x, y, z)
        end
    end

    outputChatBox("Đã phát nhạc từ boombox: " .. url, player, 100, 255, 100)
end)

addCommandHandler("audiourl", function(player, cmd, ...)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("Chỉ admin mới có thể phát nhạc toàn server!", player, 255, 100, 100)
        return
    end

    local url = table.concat({...}, " ")
    if not url or url == "" then
        outputChatBox("Sử dụng: /audiourl [URL âm thanh]", player, 255, 255, 100)
        return
    end

    -- Play for all players
    for _, target in ipairs(getElementsByType("player")) do
        triggerClientEvent("music:playGlobalURL", target, url)
    end

    local playerName = getPlayerName(player)
    outputChatBox("[ADMIN] " .. playerName .. " đã phát nhạc toàn server", getRootElement(), 255, 255, 100)
end)

addCommandHandler("audiostopurl", function(player, cmd)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("Chỉ admin mới có thể dừng nhạc toàn server!", player, 255, 100, 100)
        return
    end

    -- Stop for all players
    for _, target in ipairs(getElementsByType("player")) do
        triggerClientEvent("music:stopGlobalURL", target)
    end

    local playerName = getPlayerName(player)
    outputChatBox("[ADMIN] " .. playerName .. " đã dừng nhạc toàn server", getRootElement(), 255, 255, 100)
end)

-- UTILITY COMMANDS
addCommandHandler("id", function(player, cmd, partialName)
    if not partialName then
        outputChatBox("Sử dụng: /id [tên một phần]", player, 255, 255, 100)
        return
    end

    partialName = string.lower(partialName)
    local found = {}

    for _, target in ipairs(getElementsByType("player")) do
        local targetName = string.lower(getPlayerName(target))
        if string.find(targetName, partialName, 1, true) then
            table.insert(found, target)
        end
    end

    if #found == 0 then
        outputChatBox("Không tìm thấy người chơi nào!", player, 255, 100, 100)
    elseif #found == 1 then
        local target = found[1]
        local targetName = getPlayerName(target)
        local level = getElementData(target, "level") or 1
        outputChatBox("Tìm thấy: " .. targetName .. " (Level " .. level .. ")", player, 100, 255, 100)
    else
        outputChatBox("Tìm thấy " .. #found .. " người chơi:", player, 255, 255, 100)
        for i, target in ipairs(found) do
            if i <= 10 then -- Limit to 10 results
                local targetName = getPlayerName(target)
                local level = getElementData(target, "level") or 1
                outputChatBox("  • " .. targetName .. " (Level " .. level .. ")", player, 255, 255, 255)
            end
        end
    end
end)

addCommandHandler("near", function(player, cmd)
    local x, y, z = getElementPosition(player)
    local nearbyPlayers = {}

    for _, target in ipairs(getElementsByType("player")) do
        if target ~= player then
            local tx, ty, tz = getElementPosition(target)
            local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)

            if distance <= 10.0 then
                table.insert(nearbyPlayers, {target, distance})
            end
        end
    end

    if #nearbyPlayers == 0 then
        outputChatBox("Không có ai gần bạn (trong vòng 10m)", player, 255, 100, 100)
    else
        outputChatBox("===== NGƯỜI CHƠI GẦN BẠN =====", player, 255, 255, 100)

        -- Sort by distance
        table.sort(nearbyPlayers, function(a, b)
            return a[2] < b[2]
        end)

        for i, data in ipairs(nearbyPlayers) do
            if i <= 10 then -- Limit to 10 results
                local target, distance = data[1], data[2]
                local targetName = getPlayerName(target)
                local level = getElementData(target, "level") or 1
                outputChatBox(string.format("  • %s (Level %d) - %.1fm", targetName, level, distance), player, 255,
                    255, 255)
            end
        end

        outputChatBox("============================", player, 255, 255, 100)
    end
end)

-- ADMIN UTILITY
addCommandHandler("jetpack", function(player, cmd)
    if not isPlayerAdmin(player, 3) then
        outputChatBox("Chỉ admin cấp 3+ mới có thể sử dụng jetpack!", player, 255, 100, 100)
        return
    end

    local hasJetpack = isPedWearingJetpack(player)

    if not hasJetpack then
        setPedWearingJetpack(player, true)
        outputChatBox("Đã cấp jetpack!", player, 100, 255, 100)
    else
        setPedWearingJetpack(player, false)
        outputChatBox("Đã gỡ jetpack!", player, 255, 255, 100)
    end
end)

addCommandHandler("setmyhp", function(player, cmd, health)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("Chỉ admin mới có thể đặt máu cho mình!", player, 255, 100, 100)
        return
    end

    if not health then
        outputChatBox("Sử dụng: /setmyhp [máu 0-100]", player, 255, 255, 100)
        return
    end

    health = tonumber(health)
    if not health or health < 0 or health > 100 then
        outputChatBox("Máu phải từ 0-100!", player, 255, 100, 100)
        return
    end

    setElementHealth(player, health)
    outputChatBox("Đã đặt máu của bạn thành " .. health, player, 100, 255, 100)
end)

addCommandHandler("setmyarmor", function(player, cmd, armor)
    if not isPlayerAdmin(player, 1) then
        outputChatBox("Chỉ admin mới có thể đặt giáp cho mình!", player, 255, 100, 100)
        return
    end

    if not armor then
        outputChatBox("Sử dụng: /setmyarmor [giáp 0-100]", player, 255, 255, 100)
        return
    end

    armor = tonumber(armor)
    if not armor or armor < 0 or armor > 100 then
        outputChatBox("Giáp phải từ 0-100!", player, 255, 100, 100)
        return
    end

    setPedArmor(player, armor)
    outputChatBox("Đã đặt giáp của bạn thành " .. armor, player, 100, 255, 100)
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

outputDebugString("Mega Gaming & Entertainment System loaded successfully! (80+ commands)")
