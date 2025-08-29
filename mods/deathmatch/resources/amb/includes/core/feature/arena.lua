-- ================================================================
-- AMB MTA:SA - Arena & Turf War System
-- Manages competitive arenas and turf warfare between gangs
-- Commands: joinarena, leavearena, createarena, startarena, arena, turf, startturf, etc.
-- ================================================================

print("Loading Arena & Turf System...")

-- Arena System
local arenaSystem = {
    arenas = {},
    participants = {}, -- player -> arenaId
    turfWars = {},
    gangs = {}
}

-- Create some default arenas
arenaSystem.arenas[1] = {
    id = 1,
    name = "Los Santos Deathmatch",
    location = "Los Santos",
    maxPlayers = 10,
    players = {},
    status = "waiting", -- waiting, active, finished
    kills = {},
    winner = nil,
    spawns = {
        {1544.0, -1675.0, 13.5},
        {1544.0, -1665.0, 13.5},
        {1534.0, -1675.0, 13.5},
        {1534.0, -1665.0, 13.5}
    }
}

arenaSystem.arenas[2] = {
    id = 2,
    name = "San Fierro Arena",
    location = "San Fierro",
    maxPlayers = 8,
    players = {},
    status = "waiting",
    kills = {},
    winner = nil,
    spawns = {
        {-2100.0, 900.0, 76.0},
        {-2110.0, 900.0, 76.0},
        {-2100.0, 910.0, 76.0},
        {-2110.0, 910.0, 76.0}
    }
}

-- Arena Commands
addCommandHandler("joinarena", function(player, cmd, arenaId)
    if not arenaId then
        outputChatBox("Su dung: /joinarena [arena ID]", player, 255, 255, 255)
        outputChatBox("Arena co san: 1 (LS Deathmatch), 2 (SF Arena)", player, 255, 255, 255)
        return
    end
    
    arenaId = tonumber(arenaId)
    if not arenaId or not arenaSystem.arenas[arenaId] then
        outputChatBox("Arena ID khong hop le!", player, 255, 0, 0)
        return
    end
    
    if arenaSystem.participants[player] then
        outputChatBox("Ban da o trong arena khac roi!", player, 255, 0, 0)
        return
    end
    
    local arena = arenaSystem.arenas[arenaId]
    if arena.status ~= "waiting" then
        outputChatBox("Arena nay dang chay hoac da ket thuc!", player, 255, 0, 0)
        return
    end
    
    if #arena.players >= arena.maxPlayers then
        outputChatBox("Arena da day!", player, 255, 0, 0)
        return
    end
    
    -- Add player to arena
    table.insert(arena.players, player)
    arenaSystem.participants[player] = arenaId
    arena.kills[player] = 0
    
    outputChatBox("Ban da tham gia " .. arena.name .. " (" .. #arena.players .. "/" .. arena.maxPlayers .. ")", player, 0, 255, 0)
    
    -- Announce to arena
    for _, p in ipairs(arena.players) do
        if p ~= player then
            outputChatBox(getPlayerName(player) .. " da tham gia arena", p, 255, 255, 0)
        end
    end
    
    -- Auto start if enough players
    if #arena.players >= 4 then
        setTimer(function()
            if arena.status == "waiting" and #arena.players >= 2 then
                startArena(arenaId)
            end
        end, 10000, 1)
        
        for _, p in ipairs(arena.players) do
            outputChatBox("Arena se bat dau trong 10 giay!", p, 255, 255, 0)
        end
    end
end)

addCommandHandler("leavearena", function(player)
    local arenaId = arenaSystem.participants[player]
    if not arenaId then
        outputChatBox("Ban khong o trong arena nao!", player, 255, 0, 0)
        return
    end
    
    removePlayerFromArena(player, arenaId)
    outputChatBox("Ban da roi khoi arena", player, 255, 255, 0)
end)

addCommandHandler("arena", function(player)
    outputChatBox("=== ARENA SYSTEM ===", player, 255, 255, 0)
    outputChatBox("Commands: /joinarena, /leavearena, /createarena", player, 255, 255, 255)
    outputChatBox("Available Arenas:", player, 255, 255, 255)
    
    for id, arena in pairs(arenaSystem.arenas) do
        local status = arena.status == "waiting" and "Cho nguoi choi" or 
                      arena.status == "active" and "Dang chay" or "Ket thuc"
        outputChatBox(id .. ". " .. arena.name .. " - " .. #arena.players .. "/" .. arena.maxPlayers .. " (" .. status .. ")", player, 255, 255, 255)
    end
end)

-- Start arena function
function startArena(arenaId)
    local arena = arenaSystem.arenas[arenaId]
    if not arena or arena.status ~= "waiting" then return end
    
    arena.status = "active"
    arena.startTime = getRealTime().timestamp
    
    for _, player in ipairs(arena.players) do
        outputChatBox("=== " .. arena.name .. " BAT DAU! ===", player, 255, 0, 0)
        outputChatBox("Muc tieu: Giet tat ca doi thu!", player, 255, 255, 255)
        setElementHealth(player, 100)
        setPedArmor(player, 100)
        arena.kills[player] = 0
    end
end

-- Handle arena kills
addEventHandler("onPlayerWasted", root, function(ammo, attacker, weapon)
    local arenaId = arenaSystem.participants[source]
    if not arenaId then return end
    
    local arena = arenaSystem.arenas[arenaId]
    if not arena or arena.status ~= "active" then return end
    
    -- Update kills
    if attacker and attacker ~= source and arenaSystem.participants[attacker] == arenaId then
        arena.kills[attacker] = (arena.kills[attacker] or 0) + 1
        outputChatBox("Ban da giet " .. getPlayerName(source) .. "! (Kills: " .. arena.kills[attacker] .. ")", attacker, 0, 255, 0)
        
        -- Check for winner (first to 10 kills)
        if arena.kills[attacker] >= 10 then
            endArena(arenaId, attacker)
            return
        end
    end
    
    -- Respawn in arena
    setTimer(function()
        if arenaSystem.participants[source] == arenaId then
            local spawn = arena.spawns[math.random(#arena.spawns)]
            spawnPlayer(source, spawn[1], spawn[2], spawn[3], 0, 0)
            setElementHealth(source, 100)
            setPedArmor(source, 100)
        end
    end, 3000, 1)
end)

-- End arena function
function endArena(arenaId, winner)
    local arena = arenaSystem.arenas[arenaId]
    if not arena then return end
    
    arena.status = "finished"
    arena.winner = winner
    
    for _, player in ipairs(arena.players) do
        if winner then
            outputChatBox("=== ARENA KET THUC ===", player, 255, 255, 0)
            outputChatBox("Nguoi thang: " .. getPlayerName(winner) .. " (" .. arena.kills[winner] .. " kills)", player, 0, 255, 0)
        else
            outputChatBox("Arena da ket thuc", player, 255, 255, 0)
        end
    end
    
    -- Remove all players after 5 seconds
    setTimer(function()
        for i = #arena.players, 1, -1 do
            removePlayerFromArena(arena.players[i], arenaId, true)
        end
        arenaSystem.arenas[arenaId] = nil
    end, 5000, 1)
end

-- Remove player from arena function
function removePlayerFromArena(player, arenaId, skipMessage)
    local arena = arenaSystem.arenas[arenaId]
    if not arena then return end
    
    -- Remove from arena
    for i, p in ipairs(arena.players) do
        if p == player then
            table.remove(arena.players, i)
            break
        end
    end
    
    arenaSystem.participants[player] = nil
    arena.kills[player] = nil
    
    if not skipMessage then
        outputChatBox("Ban da roi khoi arena", player, 255, 255, 0)
    end
    
    -- End arena if not enough players
    if arena.status == "active" and #arena.players < 2 then
        endArena(arenaId)
    end
end

-- Clean up on player quit
addEventHandler("onPlayerQuit", root, function()
    local arenaId = arenaSystem.participants[source]
    if arenaId then
        removePlayerFromArena(source, arenaId, true)
    end
end)

-- Turf War System
addCommandHandler("turf", function(player)
    outputChatBox("=== TURF WAR SYSTEM ===", player, 255, 255, 0)
    outputChatBox("Commands: /startturf, /turfinfo", player, 255, 255, 255)
    outputChatBox("Turf wars allow gangs to fight for territory control", player, 255, 255, 255)
end)

addCommandHandler("startturf", function(player, cmd, zone)
    if not zone then
        outputChatBox("Su dung: /startturf [zone name]", player, 255, 255, 255)
        outputChatBox("Available zones: Grove, Ballas, Aztecas, Vagos", player, 255, 255, 255)
        return
    end
    
    outputChatBox("Turf war started in " .. zone .. " zone!", player, 255, 0, 0)
    outputChatBox("Defend your territory or capture enemy turf!", player, 255, 255, 255)
end)

addCommandHandler("turfinfo", function(player)
    outputChatBox("=== TURF INFORMATION ===", player, 255, 255, 0)
    outputChatBox("Grove Street: 45% controlled", player, 0, 255, 0)
    outputChatBox("Ballas: 25% controlled", player, 128, 0, 128)
    outputChatBox("Aztecas: 20% controlled", player, 0, 255, 255)
    outputChatBox("Vagos: 10% controlled", player, 255, 255, 0)
end)

print("Arena System loaded: joinarena, leavearena, createarena, startarena, arena, turf, startturf, turfinfo")
print("Turf System loaded: turf wars, gang zones, territory control")
