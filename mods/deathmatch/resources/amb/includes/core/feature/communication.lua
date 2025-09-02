-- ================================
-- AMB MTA:SA - Communication & Phone System
-- Migrated from SA-MP open.mp server
-- ================================

-- Phone and communication systems
local phoneSystem = {
    phones = {},
    calls = {},
    contacts = {},
    messages = {},
    settings = {},
    phoneNumbers = {},
    nextPhoneNumber = 1000000,
    callCost = 50, -- per minute
    phonePlans = {
        basic = {name = "Basic Plan", monthlyFee = 100, freeMinutes = 60},
        premium = {name = "Premium Plan", monthlyFee = 300, freeMinutes = 200},
        unlimited = {name = "Unlimited Plan", monthlyFee = 500, freeMinutes = 999999}
    }
}

-- Initialize phone system
addEventHandler("onPlayerJoin", root, function()
    -- Give new player a phone number
    if not getElementData(source, "player.phoneNumber") then
        local phoneNumber = phoneSystem.nextPhoneNumber
        phoneSystem.nextPhoneNumber = phoneSystem.nextPhoneNumber + 1
        
        setElementData(source, "player.phoneNumber", phoneNumber)
        phoneSystem.phones[phoneNumber] = source
        phoneSystem.contacts[phoneNumber] = {}
        phoneSystem.messages[phoneNumber] = {}
        phoneSystem.settings[phoneNumber] = {
            privacy = false,
            speakerphone = false,
            plan = "basic",
            minutesUsed = 0,
            lastBill = getRealTime().timestamp
        }
        
        outputChatBox("Ban da nhan duoc so dien thoai: " .. phoneNumber, source, 0, 255, 0)
        outputChatBox("Su dung /phone de xem cac lenh dien thoai", source, 255, 255, 255)
    end
end)

-- Phone main menu
addCommandHandler("phone", function(player)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then
        outputChatBox("Ban khong co dien thoai!", player, 255, 0, 0)
        return
    end
    
    local settings = phoneSystem.settings[phoneNumber]
    outputChatBox("=== DIEN THOAI ===", player, 255, 255, 0)
    outputChatBox("So cua ban: " .. phoneNumber, player, 255, 255, 255)
    outputChatBox("Goi cuoc: " .. settings.plan .. " (" .. settings.minutesUsed .. " phut da dung)", player, 255, 255, 255)
    outputChatBox("Commands:", player, 255, 255, 255)
    outputChatBox("/call [number] - Goi dien", player, 200, 200, 200)
    outputChatBox("/hangup - Tat may", player, 200, 200, 200)
    outputChatBox("/sms [number] [message] - Gui tin nhan", player, 200, 200, 200)
    outputChatBox("/contacts - Danh ba", player, 200, 200, 200)
    outputChatBox("/addcontact [number] [name] - Them danh ba", player, 200, 200, 200)
    outputChatBox("/phoneprivacy - Bat/tat che do rieng tu", player, 200, 200, 200)
    outputChatBox("/speakerphone - Bat/tat loa ngoai", player, 200, 200, 200)
    outputChatBox("/phoneplan - Xem/doi goi cuoc", player, 200, 200, 200)
end)

-- Make phone call
addCommandHandler("call", function(player, _, targetNumber)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then
        outputChatBox("Ban khong co dien thoai!", player, 255, 0, 0)
        return
    end
    
    if not targetNumber then
        outputChatBox("Su dung: /call [phone number]", player, 255, 255, 255)
        return
    end
    
    targetNumber = tonumber(targetNumber)
    if not targetNumber or not phoneSystem.phones[targetNumber] then
        outputChatBox("So dien thoai khong hop le hoac khong ton tai!", player, 255, 0, 0)
        return
    end
    
    local target = phoneSystem.phones[targetNumber]
    if not isElement(target) then
        outputChatBox("Nguoi dung khong online!", player, 255, 0, 0)
        return
    end
    
    if target == player then
        outputChatBox("Ban khong the goi cho chinh minh!", player, 255, 0, 0)
        return
    end
    
    -- Check if already in call
    if phoneSystem.calls[phoneNumber] then
        outputChatBox("Ban dang trong cuoc goi khac!", player, 255, 0, 0)
        return
    end
    
    if phoneSystem.calls[targetNumber] then
        outputChatBox("May ban goi dang ban!", player, 255, 0, 0)
        return
    end
    
    -- Check privacy settings
    local targetSettings = phoneSystem.settings[targetNumber]
    if targetSettings.privacy then
        outputChatBox("May ban goi da tat nhan cuoc goi!", player, 255, 0, 0)
        return
    end
    
    -- Create call
    phoneSystem.calls[phoneNumber] = {
        caller = player,
        callee = target,
        startTime = getRealTime().timestamp,
        status = "ringing"
    }
    phoneSystem.calls[targetNumber] = phoneSystem.calls[phoneNumber]
    
    outputChatBox("Dang goi den " .. targetNumber .. "...", player, 255, 255, 0)
    outputChatBox("Cuoc goi tu " .. phoneNumber .. " - /pickup de nghe may hoac /hangup de tu choi", target, 255, 255, 0)
    
    -- Auto hangup after 30 seconds if not picked up
    setTimer(function()
        if phoneSystem.calls[phoneNumber] and phoneSystem.calls[phoneNumber].status == "ringing" then
            phoneSystem.calls[phoneNumber] = nil
            phoneSystem.calls[targetNumber] = nil
            outputChatBox("Cuoc goi khong duoc tra loi", player, 255, 0, 0)
            outputChatBox("Cuoc goi da bi huy", target, 255, 255, 0)
        end
    end, 30000, 1)
end)

-- Pick up phone
addCommandHandler("pickup", function(player)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then return end
    
    local call = phoneSystem.calls[phoneNumber]
    if not call or call.status ~= "ringing" or call.callee ~= player then
        outputChatBox("Khong co cuoc goi nao!", player, 255, 0, 0)
        return
    end
    
    call.status = "active"
    call.startTime = getRealTime().timestamp
    
    outputChatBox("Cuoc goi bat dau - /hangup de tat may", call.caller, 0, 255, 0)
    outputChatBox("Cuoc goi bat dau - /hangup de tat may", call.callee, 0, 255, 0)
    
    -- Start charging per minute
    call.chargeTimer = setTimer(function()
        if phoneSystem.calls[phoneNumber] and phoneSystem.calls[phoneNumber].status == "active" then
            local callerPhone = getElementData(call.caller, "player.phoneNumber")
            local callerSettings = phoneSystem.settings[callerPhone]
            
            callerSettings.minutesUsed = callerSettings.minutesUsed + 1
            
            -- Check if over free minutes
            local plan = phoneSystem.phonePlans[callerSettings.plan]
            if callerSettings.minutesUsed > plan.freeMinutes then
                if getPlayerMoney(call.caller) >= phoneSystem.callCost then
                    takePlayerMoney(call.caller, phoneSystem.callCost)
                    outputChatBox("Chi phi cuoc goi: $" .. phoneSystem.callCost, call.caller, 255, 255, 0)
                else
                    -- Not enough money, end call
                    executeCommandHandler("hangup", call.caller)
                    outputChatBox("Khong du tien de tiep tuc cuoc goi!", call.caller, 255, 0, 0)
                end
            end
        end
    end, 60000, 0) -- Every minute
end)

-- Hang up phone
addCommandHandler("hangup", function(player)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then return end
    
    local call = phoneSystem.calls[phoneNumber]
    if not call then
        outputChatBox("Ban khong dang trong cuoc goi nao!", player, 255, 0, 0)
        return
    end
    
    local otherPlayer = (call.caller == player) and call.callee or call.caller
    local otherNumber = getElementData(otherPlayer, "player.phoneNumber")
    
    if call.chargeTimer then
        killTimer(call.chargeTimer)
    end
    
    phoneSystem.calls[phoneNumber] = nil
    phoneSystem.calls[otherNumber] = nil
    
    outputChatBox("Cuoc goi da ket thuc", player, 255, 255, 0)
    outputChatBox("Cuoc goi da ket thuc", otherPlayer, 255, 255, 0)
    
    if call.status == "active" then
        local duration = getRealTime().timestamp - call.startTime
        outputChatBox("Thoi gian goi: " .. math.floor(duration / 60) .. " phut", call.caller, 255, 255, 255)
    end
end)

-- Send SMS
addCommandHandler("sms", function(player, _, targetNumber, ...)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then
        outputChatBox("Ban khong co dien thoai!", player, 255, 0, 0)
        return
    end
    
    if not targetNumber or not ... then
        outputChatBox("Su dung: /sms [phone number] [message]", player, 255, 255, 255)
        return
    end
    
    local message = table.concat({...}, " ")
    targetNumber = tonumber(targetNumber)
    
    if not targetNumber or not phoneSystem.phones[targetNumber] then
        outputChatBox("So dien thoai khong hop le!", player, 255, 0, 0)
        return
    end
    
    local target = phoneSystem.phones[targetNumber]
    if not isElement(target) then
        outputChatBox("Nguoi dung khong online!", player, 255, 0, 0)
        return
    end
    
    -- Check money for SMS
    if getPlayerMoney(player) < 10 then
        outputChatBox("Ban khong du tien gui SMS! (Chi phi: $10)", player, 255, 0, 0)
        return
    end
    
    takePlayerMoney(player, 10)
    
    -- Store message
    if not phoneSystem.messages[targetNumber] then
        phoneSystem.messages[targetNumber] = {}
    end
    
    table.insert(phoneSystem.messages[targetNumber], {
        from = phoneNumber,
        message = message,
        time = getRealTime().timestamp
    })
    
    outputChatBox("SMS gui thanh cong den " .. targetNumber, player, 0, 255, 0)
    outputChatBox("SMS tu " .. phoneNumber .. ": " .. message, target, 255, 255, 0)
    outputChatBox("Su dung /checkmessages de xem tat ca tin nhan", target, 200, 200, 200)
end)

-- Check messages
addCommandHandler("checkmessages", function(player)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then return end
    
    local messages = phoneSystem.messages[phoneNumber]
    if not messages or #messages == 0 then
        outputChatBox("Ban khong co tin nhan nao!", player, 255, 255, 0)
        return
    end
    
    outputChatBox("=== TIN NHAN ===", player, 255, 255, 0)
    for i = math.max(1, #messages - 10), #messages do -- Show last 10 messages
        local msg = messages[i]
        local timeStr = os.date("%H:%M", msg.time)
        outputChatBox("[" .. timeStr .. "] " .. msg.from .. ": " .. msg.message, player, 255, 255, 255)
    end
end)

-- Contacts system
addCommandHandler("contacts", function(player)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then return end
    
    local contacts = phoneSystem.contacts[phoneNumber]
    if not contacts or not next(contacts) then
        outputChatBox("Danh ba trong! Su dung /addcontact de them", player, 255, 255, 0)
        return
    end
    
    outputChatBox("=== DANH BA ===", player, 255, 255, 0)
    for number, name in pairs(contacts) do
        local status = "Offline"
        if phoneSystem.phones[number] and isElement(phoneSystem.phones[number]) then
            status = "Online"
        end
        outputChatBox(name .. " - " .. number .. " (" .. status .. ")", player, 255, 255, 255)
    end
end)

addCommandHandler("addcontact", function(player, _, number, ...)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then return end
    
    if not number or not ... then
        outputChatBox("Su dung: /addcontact [phone number] [name]", player, 255, 255, 255)
        return
    end
    
    local name = table.concat({...}, " ")
    number = tonumber(number)
    
    if not number then
        outputChatBox("So dien thoai khong hop le!", player, 255, 0, 0)
        return
    end
    
    phoneSystem.contacts[phoneNumber][number] = name
    outputChatBox("Da them " .. name .. " (" .. number .. ") vao danh ba", player, 0, 255, 0)
end)

addCommandHandler("removecontact", function(player, _, number)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then return end
    
    if not number then
        outputChatBox("Su dung: /removecontact [phone number]", player, 255, 255, 255)
        return
    end
    
    number = tonumber(number)
    if phoneSystem.contacts[phoneNumber][number] then
        local name = phoneSystem.contacts[phoneNumber][number]
        phoneSystem.contacts[phoneNumber][number] = nil
        outputChatBox("Da xoa " .. name .. " khoi danh ba", player, 255, 255, 0)
    else
        outputChatBox("Khong tim thay contact nay!", player, 255, 0, 0)
    end
end)

-- Phone privacy
addCommandHandler("phoneprivacy", function(player)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then return end
    
    local settings = phoneSystem.settings[phoneNumber]
    settings.privacy = not settings.privacy
    
    local status = settings.privacy and "BAT" or "TAT"
    outputChatBox("Che do rieng tu da duoc " .. status, player, 255, 255, 0)
    
    if settings.privacy then
        outputChatBox("Ban se khong nhan duoc cuoc goi tu so la!", player, 255, 255, 255)
    else
        outputChatBox("Ban se nhan tat ca cuoc goi", player, 255, 255, 255)
    end
end)

-- Speakerphone
addCommandHandler("speakerphone", function(player)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then return end
    
    local call = phoneSystem.calls[phoneNumber]
    if not call or call.status ~= "active" then
        outputChatBox("Ban khong dang trong cuoc goi nao!", player, 255, 0, 0)
        return
    end
    
    local settings = phoneSystem.settings[phoneNumber]
    settings.speakerphone = not settings.speakerphone
    
    local status = settings.speakerphone and "BAT" or "TAT"
    outputChatBox("Loa ngoai da duoc " .. status, player, 255, 255, 0)
    
    local otherPlayer = (call.caller == player) and call.callee or call.caller
    outputChatBox(getPlayerName(player) .. " da " .. status .. " loa ngoai", otherPlayer, 255, 255, 0)
end)

-- Phone plans
addCommandHandler("phoneplan", function(player, _, newPlan)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then return end
    
    local settings = phoneSystem.settings[phoneNumber]
    
    if not newPlan then
        outputChatBox("=== GOI CUOC HIEN TAI ===", player, 255, 255, 0)
        local currentPlan = phoneSystem.phonePlans[settings.plan]
        outputChatBox("Goi: " .. currentPlan.name, player, 255, 255, 255)
        outputChatBox("Phi hang thang: $" .. currentPlan.monthlyFee, player, 255, 255, 255)
        outputChatBox("Phut mien phi: " .. currentPlan.freeMinutes, player, 255, 255, 255)
        outputChatBox("Phut da dung: " .. settings.minutesUsed, player, 255, 255, 255)
        
        outputChatBox("=== GOI CUOC CO SAN ===", player, 255, 255, 0)
        for planId, plan in pairs(phoneSystem.phonePlans) do
            outputChatBox(planId .. ": " .. plan.name .. " ($" .. plan.monthlyFee .. "/thang, " .. plan.freeMinutes .. " phut)", player, 200, 200, 200)
        end
        outputChatBox("Su dung: /phoneplan [plan] de doi goi", player, 255, 255, 255)
        return
    end
    
    if not phoneSystem.phonePlans[newPlan] then
        outputChatBox("Goi cuoc khong hop le!", player, 255, 0, 0)
        return
    end
    
    local plan = phoneSystem.phonePlans[newPlan]
    if getPlayerMoney(player) < plan.monthlyFee then
        outputChatBox("Ban khong du tien doi goi cuoc! Can: $" .. plan.monthlyFee, player, 255, 0, 0)
        return
    end
    
    takePlayerMoney(player, plan.monthlyFee)
    settings.plan = newPlan
    settings.minutesUsed = 0 -- Reset usage
    
    outputChatBox("Da doi thanh goi " .. plan.name, player, 0, 255, 0)
    outputChatBox("Phi: $" .. plan.monthlyFee .. " - Phut mien phi: " .. plan.freeMinutes, player, 255, 255, 255)
end)

-- Phone book (directory)
addCommandHandler("phonebook", function(player, _, searchName)
    if not searchName then
        outputChatBox("Su dung: /phonebook [player name]", player, 255, 255, 255)
        outputChatBox("Tim kiem so dien thoai cua player khac", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromName(searchName)
    if not targetPlayer then
        outputChatBox("Khong tim thay player: " .. searchName, player, 255, 0, 0)
        return
    end
    
    local targetPhone = getElementData(targetPlayer, "player.phoneNumber")
    if not targetPhone then
        outputChatBox(getPlayerName(targetPlayer) .. " khong co dien thoai!", player, 255, 0, 0)
        return
    end
    
    -- Check if target allows phone book lookup
    local targetSettings = phoneSystem.settings[targetPhone]
    if targetSettings.privacy then
        outputChatBox("So dien thoai cua " .. getPlayerName(targetPlayer) .. " duoc bao mat!", player, 255, 0, 0)
        return
    end
    
    outputChatBox("So dien thoai cua " .. getPlayerName(targetPlayer) .. ": " .. targetPhone, player, 0, 255, 0)
end)

-- Handle phone chat during calls
addEventHandler("onPlayerChat", root, function(message, messageType)
    if messageType ~= 0 then return end -- Only normal chat
    
    local phoneNumber = getElementData(source, "player.phoneNumber")
    if not phoneNumber then return end
    
    local call = phoneSystem.calls[phoneNumber]
    if not call or call.status ~= "active" then return end
    
    -- If in active call, send message to both players
    local otherPlayer = (call.caller == source) and call.callee or call.caller
    local settings = phoneSystem.settings[phoneNumber]
    
    cancelEvent() -- Cancel normal chat
    
    if settings.speakerphone then
        -- Speakerphone: nearby players can hear
        outputChatBox("(Phone) " .. getPlayerName(source) .. ": " .. message, source, 255, 255, 0)
        outputChatBox("(Phone) " .. getPlayerName(source) .. ": " .. message, otherPlayer, 255, 255, 0)
        
        -- Let nearby players hear
        local x, y, z = getElementPosition(source)
        local nearbyPlayers = getElementsWithinRange(x, y, z, 10, "player")
        for _, player in ipairs(nearbyPlayers) do
            if player ~= source and player ~= otherPlayer then
                outputChatBox("(Speakerphone) " .. getPlayerName(source) .. ": " .. message, player, 200, 200, 200)
            end
        end
    else
        -- Private call
        outputChatBox("(Phone) " .. getPlayerName(source) .. ": " .. message, source, 255, 255, 0)
        outputChatBox("(Phone) " .. getPlayerName(source) .. ": " .. message, otherPlayer, 255, 255, 0)
    end
end)

-- Emergency calls
addCommandHandler("911", function(player, _, ...)
    local phoneNumber = getElementData(player, "player.phoneNumber")
    if not phoneNumber then
        outputChatBox("Ban khong co dien thoai!", player, 255, 0, 0)
        return
    end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /911 [emergency message]", player, 255, 255, 255)
        return
    end
    
    local x, y, z = getElementPosition(player)
    local location = "X: " .. math.floor(x) .. " Y: " .. math.floor(y)
    
    -- Send to all cops
    for _, cop in ipairs(getElementsByType("player")) do
        if hasPermission(cop, "police") then
            outputChatBox("=== CUOC GOI KHAN CAP 911 ===", cop, 255, 0, 0)
            outputChatBox("Tu: " .. getPlayerName(player) .. " (SDT: " .. phoneNumber .. ")", cop, 255, 255, 255)
            outputChatBox("Vi tri: " .. location, cop, 255, 255, 255)
            outputChatBox("Tin nhan: " .. message, cop, 255, 255, 255)
        end
    end
    
    outputChatBox("Cuoc goi khan cap 911 da duoc gui!", player, 255, 255, 0)
    outputChatBox("Canh sat se den ho tro ban som", player, 255, 255, 255)
end)

-- Cleanup on player quit
addEventHandler("onPlayerQuit", root, function()
    local phoneNumber = getElementData(source, "player.phoneNumber")
    if not phoneNumber then return end
    
    -- End any active calls
    local call = phoneSystem.calls[phoneNumber]
    if call then
        local otherPlayer = (call.caller == source) and call.callee or call.caller
        local otherNumber = getElementData(otherPlayer, "player.phoneNumber")
        
        if call.chargeTimer then
            killTimer(call.chargeTimer)
        end
        
        phoneSystem.calls[phoneNumber] = nil
        phoneSystem.calls[otherNumber] = nil
        
        outputChatBox("Cuoc goi da bi ngat ket noi", otherPlayer, 255, 0, 0)
    end
    
    phoneSystem.phones[phoneNumber] = nil
end)

-- Monthly billing system
setTimer(function()
    for phoneNumber, settings in pairs(phoneSystem.settings) do
        local player = phoneSystem.phones[phoneNumber]
        if isElement(player) then
            local timeSinceLastBill = getRealTime().timestamp - settings.lastBill
            if timeSinceLastBill >= 86400 then -- 24 hours = 1 month in game
                local plan = phoneSystem.phonePlans[settings.plan]
                if getPlayerMoney(player) >= plan.monthlyFee then
                    takePlayerMoney(player, plan.monthlyFee)
                    outputChatBox("Hoa don dien thoai hang thang: $" .. plan.monthlyFee, player, 255, 255, 0)
                    settings.lastBill = getRealTime().timestamp
                    settings.minutesUsed = 0 -- Reset monthly usage
                else
                    outputChatBox("Khong du tien tra hoa don dien thoai! Dich vu se bi cat", player, 255, 0, 0)
                    settings.plan = "basic" -- Downgrade to basic
                end
            end
        end
    end
end, 60000, 0) -- Check every minute

print("Communication & Phone System loaded: calls, SMS, contacts, privacy, plans, 911")
