-- ================================
-- AMB MTA:SA - Phone System Commands
-- Mass migration of phone-related commands
-- ================================
-- Call player command
addCommandHandler("call", function(player, cmd, phoneNumber)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.phone then
        outputChatBox("❌ Ban khong co dien thoai.", player, 255, 100, 100)
        return
    end

    if not phoneNumber then
        outputChatBox("Su dung: /call [so_dien_thoai]", player, 255, 255, 255)
        return
    end

    if playerData.inCall then
        outputChatBox("❌ Ban dang goi dien thoai roi.", player, 255, 100, 100)
        return
    end

    -- Find target player by phone number
    local targetPlayer = nil
    for _, p in ipairs(getElementsByType("player")) do
        local pData = getElementData(p, "playerData")
        if pData and pData.phoneNumber == phoneNumber then
            targetPlayer = p
            break
        end
    end

    if not targetPlayer then
        outputChatBox("📱 So dien thoai khong ton tai hoac khong online.", player, 255, 100, 100)
        return
    end

    if targetPlayer == player then
        outputChatBox("❌ Ban khong the goi cho chinh minh.", player, 255, 100, 100)
        return
    end

    local targetData = getElementData(targetPlayer, "playerData") or {}

    if not targetData.phone then
        outputChatBox("📱 Dien thoai cua nguoi do da tat.", player, 255, 100, 100)
        return
    end

    if targetData.inCall then
        outputChatBox("📱 Duong day ban.", player, 255, 100, 100)
        return
    end

    -- Start call
    playerData.inCall = {
        target = targetPlayer,
        caller = true,
        startTime = getRealTime().timestamp
    }
    targetData.inCall = {
        target = player,
        caller = false,
        startTime = getRealTime().timestamp
    }

    setElementData(player, "playerData", playerData)
    setElementData(targetPlayer, "playerData", targetData)

    outputChatBox(string.format("📱 Dang goi den %s...", getPlayerName(targetPlayer)), player, 255, 255, 100)
    outputChatBox(string.format("📱 INCOMING CALL tu %s. Su dung /pickup hoac /hangup", getPlayerName(player)),
        targetPlayer, 255, 255, 100)

    -- Auto hangup after 30 seconds if not answered
    setTimer(function()
        local currentPlayerData = getElementData(player, "playerData")
        local currentTargetData = getElementData(targetPlayer, "playerData")

        if currentPlayerData and currentPlayerData.inCall and currentTargetData and currentTargetData.inCall and
            not currentTargetData.callAnswered then

            currentPlayerData.inCall = nil
            currentTargetData.inCall = nil
            setElementData(player, "playerData", currentPlayerData)
            setElementData(targetPlayer, "playerData", currentTargetData)

            outputChatBox("📱 Khong co nguoi tra loi.", player, 255, 100, 100)
            outputChatBox("📱 Cuoc goi da bi tat.", targetPlayer, 255, 100, 100)
        end
    end, 30000, 1)
end)

-- Pickup call
addCommandHandler("pickup", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.inCall then
        outputChatBox("❌ Ban khong co cuoc goi nao.", player, 255, 100, 100)
        return
    end

    if playerData.inCall.caller then
        outputChatBox("❌ Ban la nguoi goi, khong phai nguoi nhan.", player, 255, 100, 100)
        return
    end

    local caller = playerData.inCall.target
    if not isElement(caller) then
        outputChatBox("❌ Cuoc goi da ket thuc.", player, 255, 100, 100)
        playerData.inCall = nil
        setElementData(player, "playerData", playerData)
        return
    end

    -- Answer call
    playerData.callAnswered = true
    local callerData = getElementData(caller, "playerData") or {}
    callerData.callAnswered = true

    setElementData(player, "playerData", playerData)
    setElementData(caller, "playerData", callerData)

    outputChatBox("📱 Da nhan cuoc goi. Su dung /t [tin nhan] de noi chuyen.", player, 0, 255, 0)
    outputChatBox("📱 Cuoc goi da duoc tra loi. Su dung /t [tin nhan] de noi chuyen.", caller, 0, 255, 0)
end)

-- Hangup call
addCommandHandler("hangup", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.inCall then
        outputChatBox("❌ Ban khong co cuoc goi nao.", player, 255, 100, 100)
        return
    end

    local otherPlayer = playerData.inCall.target
    if isElement(otherPlayer) then
        local otherData = getElementData(otherPlayer, "playerData") or {}
        otherData.inCall = nil
        otherData.callAnswered = nil
        setElementData(otherPlayer, "playerData", otherData)
        outputChatBox("📱 Cuoc goi da ket thuc.", otherPlayer, 255, 255, 100)
    end

    playerData.inCall = nil
    playerData.callAnswered = nil
    setElementData(player, "playerData", playerData)

    outputChatBox("📱 Da tat cuoc goi.", player, 255, 255, 100)
end)

-- Talk in call
addCommandHandler("t", function(player, cmd, ...)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.inCall then
        outputChatBox("❌ Ban khong co cuoc goi nao.", player, 255, 100, 100)
        return
    end

    if not playerData.callAnswered then
        outputChatBox("❌ Cuoc goi chua duoc tra loi.", player, 255, 100, 100)
        return
    end

    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /t [tin nhan]", player, 255, 255, 255)
        return
    end

    local otherPlayer = playerData.inCall.target
    if not isElement(otherPlayer) then
        outputChatBox("❌ Cuoc goi da ket thuc.", player, 255, 100, 100)
        playerData.inCall = nil
        setElementData(player, "playerData", playerData)
        return
    end

    local playerName = getPlayerName(player)
    outputChatBox(string.format("📱 [PHONE] %s: %s", playerName, message), player, 255, 255, 0)
    outputChatBox(string.format("📱 [PHONE] %s: %s", playerName, message), otherPlayer, 255, 255, 0)
end)

-- SMS system
addCommandHandler("sms", function(player, cmd, phoneNumber, ...)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.phone then
        outputChatBox("❌ Ban khong co dien thoai.", player, 255, 100, 100)
        return
    end

    if not phoneNumber then
        outputChatBox("Su dung: /sms [so_dien_thoai] [tin nhan]", player, 255, 255, 255)
        return
    end

    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /sms [so_dien_thoai] [tin nhan]", player, 255, 255, 255)
        return
    end

    -- Find target player
    local targetPlayer = nil
    for _, p in ipairs(getElementsByType("player")) do
        local pData = getElementData(p, "playerData")
        if pData and pData.phoneNumber == phoneNumber then
            targetPlayer = p
            break
        end
    end

    if not targetPlayer then
        outputChatBox("📱 So dien thoai khong ton tai hoac khong online.", player, 255, 100, 100)
        return
    end

    local targetData = getElementData(targetPlayer, "playerData") or {}
    if not targetData.phone then
        outputChatBox("📱 Dien thoai cua nguoi do da tat.", player, 255, 100, 100)
        return
    end

    local playerName = getPlayerName(player)
    local senderNumber = playerData.phoneNumber or "Unknown"

    outputChatBox(string.format("📱 SMS gui den %s: %s", phoneNumber, message), player, 0, 255, 0)
    outputChatBox(string.format("📱 SMS tu %s (%s): %s", playerName, senderNumber, message), targetPlayer, 255, 255, 0)

    -- Save SMS to target's inbox
    targetData.smsInbox = targetData.smsInbox or {}
    table.insert(targetData.smsInbox, {
        from = senderNumber,
        fromName = playerName,
        message = message,
        time = getRealTime().timestamp
    })

    -- Keep only last 20 SMS
    if #targetData.smsInbox > 20 then
        table.remove(targetData.smsInbox, 1)
    end

    setElementData(targetPlayer, "playerData", targetData)
end)

-- Check SMS inbox
addCommandHandler("inbox", function(player)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.phone then
        outputChatBox("❌ Ban khong co dien thoai.", player, 255, 100, 100)
        return
    end

    local inbox = playerData.smsInbox or {}

    if #inbox == 0 then
        outputChatBox("📱 Khong co SMS nao.", player, 255, 255, 100)
        return
    end

    outputChatBox("📱 ===== SMS INBOX =====", player, 255, 255, 0)
    for i = math.max(1, #inbox - 9), #inbox do -- Show last 10 SMS
        local sms = inbox[i]
        local timeStr = os.date("%H:%M", sms.time)
        outputChatBox(string.format("%d. %s (%s) [%s]: %s", i, sms.fromName, sms.from, timeStr, sms.message), player,
            255, 255, 255)
    end
end)

-- Phone contacts system
addCommandHandler("contacts", function(player, cmd, action, name, number)
    local playerData = getElementData(player, "playerData") or {}

    if not playerData.phone then
        outputChatBox("❌ Ban khong co dien thoai.", player, 255, 100, 100)
        return
    end

    playerData.contacts = playerData.contacts or {}

    if not action then
        outputChatBox("Su dung: /contacts [add/remove/list] [ten] [so]", player, 255, 255, 255)
        return
    end

    if action == "add" then
        if not name or not number then
            outputChatBox("Su dung: /contacts add [ten] [so_dien_thoai]", player, 255, 255, 255)
            return
        end

        playerData.contacts[name] = number
        setElementData(player, "playerData", playerData)
        outputChatBox(string.format("📱 Da them contact: %s (%s)", name, number), player, 0, 255, 0)

    elseif action == "remove" then
        if not name then
            outputChatBox("Su dung: /contacts remove [ten]", player, 255, 255, 255)
            return
        end

        if playerData.contacts[name] then
            playerData.contacts[name] = nil
            setElementData(player, "playerData", playerData)
            outputChatBox(string.format("📱 Da xoa contact: %s", name), player, 255, 255, 100)
        else
            outputChatBox("❌ Khong tim thay contact.", player, 255, 100, 100)
        end

    elseif action == "list" then
        local count = 0
        for contactName, contactNumber in pairs(playerData.contacts) do
            count = count + 1
        end

        if count == 0 then
            outputChatBox("📱 Khong co contact nao.", player, 255, 255, 100)
            return
        end

        outputChatBox("📱 ===== CONTACTS =====", player, 255, 255, 0)
        for contactName, contactNumber in pairs(playerData.contacts) do
            outputChatBox(string.format("• %s: %s", contactName, contactNumber), player, 255, 255, 255)
        end
    end
end)

-- Phone settings
addCommandHandler("phone", function(player, cmd, action)
    local playerData = getElementData(player, "playerData") or {}

    if not action then
        outputChatBox("Su dung: /phone [on/off/number/buy]", player, 255, 255, 255)
        return
    end

    if action == "buy" then
        if playerData.phone then
            outputChatBox("❌ Ban da co dien thoai roi.", player, 255, 100, 100)
            return
        end

        local cost = 500
        if (playerData.money or 0) < cost then
            outputChatBox(string.format("❌ Ban can $%d de mua dien thoai.", cost), player, 255, 100, 100)
            return
        end

        playerData.money = (playerData.money or 0) - cost
        playerData.phone = true
        playerData.phoneNumber = string.format("%04d", math.random(1000, 9999))
        setElementData(player, "playerData", playerData)

        outputChatBox(string.format("📱 Da mua dien thoai! So cua ban: %s", playerData.phoneNumber), player, 0, 255, 0)

    elseif action == "on" then
        if not playerData.phone then
            outputChatBox("❌ Ban khong co dien thoai.", player, 255, 100, 100)
            return
        end

        if playerData.phoneOn then
            outputChatBox("📱 Dien thoai da bat roi.", player, 255, 255, 100)
            return
        end

        playerData.phoneOn = true
        setElementData(player, "playerData", playerData)
        outputChatBox("📱 Da bat dien thoai.", player, 0, 255, 0)

    elseif action == "off" then
        if not playerData.phone then
            outputChatBox("❌ Ban khong co dien thoai.", player, 255, 100, 100)
            return
        end

        if not playerData.phoneOn then
            outputChatBox("📱 Dien thoai da tat roi.", player, 255, 255, 100)
            return
        end

        -- End any active calls
        if playerData.inCall then
            local otherPlayer = playerData.inCall.target
            if isElement(otherPlayer) then
                local otherData = getElementData(otherPlayer, "playerData") or {}
                otherData.inCall = nil
                setElementData(otherPlayer, "playerData", otherData)
                outputChatBox("📱 Cuoc goi da ket thuc.", otherPlayer, 255, 255, 100)
            end
            playerData.inCall = nil
        end

        playerData.phoneOn = false
        setElementData(player, "playerData", playerData)
        outputChatBox("📱 Da tat dien thoai.", player, 255, 255, 100)

    elseif action == "number" then
        if not playerData.phone then
            outputChatBox("❌ Ban khong co dien thoai.", player, 255, 100, 100)
            return
        end

        outputChatBox(string.format("📱 So dien thoai cua ban: %s", playerData.phoneNumber or "Unknown"), player, 255,
            255, 100)
    end
end)

outputDebugString("[AMB] Phone system loaded - 9 commands")
