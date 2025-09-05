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
            -- Send success response to client, kèm dữ liệu account
            triggerClientEvent(client, "onLoginResponse", root, true, "Login successful!", row)

            -- Send welcome message ONLY ONCE to avoid duplication
            outputChatBox("🎉 Welcome back, " .. username .. "!", client, 0, 255, 0)

            -- Set all player data for scoreboard and systems FIRST
            setElementData(client, "playerName", username)
            setElementData(client, "username", username)
            setElementData(client, "loggedIn", true)
            setElementData(client, "playerLevel", tonumber(row.Level) or 1)
            setElementData(client, "adminLevel", tonumber(row.AdminLevel) or 0)
            setElementData(client, "vipLevel", tonumber(row.VIPLevel) or 0)
            setElementData(client, "playerMoney", tonumber(row.Money) or 5000)
            setElementData(client, "bankMoney", tonumber(row.Bank) or 20000)
            -- Không spawn player ở đây nữa, client sẽ gửi yêu cầu spawn sau khi đóng modal login
        else
            triggerClientEvent(client, "onLoginResponse", root, false, "Wrong password")
            outputDebugString("❌ [LOGIN] Wrong password for " .. username)
        end
    else
        triggerClientEvent(client, "onLoginResponse", root, false, "Account not found")
        outputDebugString("❌ [LOGIN] Account not found: " .. username)
    end
end)

-- Nhận yêu cầu spawn từ client sau khi login thành công
addEvent("onPlayerSpawnRequest", true)
addEventHandler("onPlayerSpawnRequest", root, function(accountData)
    if not client or not accountData then
        return
    end
    dbSpawnPlayer(client, accountData)
    -- Set additional stats
    setElementHealth(client, tonumber(accountData.pHealth) or 100)
    setPedArmor(client, tonumber(accountData.pArmor) or 0)
    setElementInterior(client, tonumber(accountData.Int) or 0)
    setElementDimension(client, tonumber(accountData.VirtualWorld) or 0)
    setElementFrozen(client, false)
    -- Enable controls & HUD
    toggleAllControls(client, true)
    setPlayerHudComponentVisible(client, "all", true)
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
