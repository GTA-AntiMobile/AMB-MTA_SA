-- ================================================================
-- AMB MTA:SA - Login & Register Handler
-- ================================================================

-- Spawn player from DB data
function spawnPlayerFromDB(player, data)
    if not isElement(player) or not data then return end

    -- Tọa độ với fallback nếu DB null/0
    local x = tonumber(data.SPos_x) or 1642.9
    local y = tonumber(data.SPos_y) or -2237.6
    local z = tonumber(data.SPos_z) or 13.5
    if x == 0 and y == 0 and z == 0 then
        x, y, z = 1642.9, -2237.6, 13.5
    end

    local rot = tonumber(data.SPos_r) or 0
    local skin = tonumber(data.Model) or 0
    local health = tonumber(data.pHealth) or 100
    local armor = tonumber(data.pArmor) or 0
    local interior = tonumber(data.Int) or 0
    local dim = tonumber(data.VirtualWorld) or 0

    -- Data
    setElementData(player, "playerLevel", tonumber(data.Level) or 1)
    setElementData(player, "adminLevel", tonumber(data.AdminLevel) or 0)
    setElementData(player, "vipLevel", tonumber(data.VIPLevel) or 0)
    setElementData(player, "playerMoney", tonumber(data.Money) or 5000)
    setElementData(player, "bankMoney", tonumber(data.Bank) or 20000)
    setElementData(player, "loggedIn", true)

    -- Spawn
    spawnPlayer(player, x, y, z, rot, skin, interior, dim)
    setElementHealth(player, health)
    setPedArmor(player, armor)
    setElementInterior(player, interior)
    setElementDimension(player, dim)
    setElementFrozen(player, false) -- bật cho di chuyển

    -- Bật controls & HUD
    toggleAllControls(player, true)
    showChat(player, true)
    setPlayerHudComponentVisible(player, "radar", true)
    setPlayerHudComponentVisible(player, "area_name", true)
    setPlayerHudComponentVisible(player, "money", true)

    -- Camera + fade
    fadeCamera(player, true, 1.0)
    setCameraTarget(player, player)

    outputDebugString("✅ [SPAWN] Player " .. getPlayerName(player) ..
        " spawned at " .. x .. ", " .. y .. ", " .. z)
    outputDebugString("🎮 You have been spawned. Welcome to AMB Roleplay!")
end

-- Player login
addEvent("onPlayerLoginRequest", true)
addEventHandler("onPlayerLoginRequest", root, function(username, password)
    if not username or not password then
        triggerClientEvent(client, "onLoginResponse", root, false, "Missing username/password")
        return
    end

    local row = dbLoadPlayerData(username)
    if row then
        local hashed = WP_Hash(password)
        if row.Key == hashed then
            triggerClientEvent(client, "onLoginResponse", root, true, "Welcome back, " .. username .. "!")
            outputDebugString("✅ [LOGIN] Player " .. username .. " logged in successfully")
            -- Spawn player at saved position
            spawnPlayerFromDB(client, row)
            -- Set all player data for scoreboard and systems
            setElementData(client, "playerName", username)
            -- Use database ID if available, else fallback to serial
            if row.ID then
                setElementData(client, "ID", tonumber(row.ID))
            else
                setElementData(client, "ID", getPlayerSerial(client))
            end
        else
            triggerClientEvent(client, "onLoginResponse", root, false, "Wrong password")
            outputDebugString("❌ [LOGIN] Wrong password for " .. username)
        end
    else
        triggerClientEvent(client, "onLoginResponse", root, false, "Account not found")
        outputDebugString("❌ [LOGIN] Account not found: " .. username)
    end
end)

-- Player register
addEvent("onPlayerRegisterRequest", true)
addEventHandler("onPlayerRegisterRequest", root, function(username, password)
    if not username or not password then
        triggerClientEvent(client, "onRegisterResponse", root, false, "Missing username/password")
        return
    end

    -- Check if account exists
    local row = dbLoadPlayerData(username)
    if row then
        triggerClientEvent(client, "onRegisterResponse", root, false, "Username already taken")
        outputDebugString("❌ [REGISTER] Attempt with existing username: " .. username)
        return
    end

    -- Insert new account
    local success, msg = dbCreateAccount(username, password)
    if success then
        triggerClientEvent(client, "onRegisterResponse", root, true, "Account created successfully, you can now login")
        outputDebugString("✅ [REGISTER] New account created: " .. username)
    else
        triggerClientEvent(client, "onRegisterResponse", root, false, "Registration failed (DB error)")
        outputDebugString("❌ [REGISTER] DB insert failed for: " .. username .. " (" .. tostring(msg) .. ")")
    end
end)
