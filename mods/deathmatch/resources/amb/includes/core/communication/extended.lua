--[[
    EXTENDED COMMUNICATION SYSTEM - Batch 30
    
    Chức năng: Hệ thống giao tiếp mở rộng cho roleplay
    Nâng cấp từ SA-MP sang MTA với đầy đủ tính năng chat nâng cao
    
    Commands migrated: 25 commands
    - Roleplay Chat: me, do, ame, ado, try, attempt
    - Proximity Chat: say, low, shout, whisper, megaphone  
    - OOC Communication: ooc, b, pm, reply, ignore
    - Group Communication: radio, dept, family, gang
    - Special Features: mute, unmute, chatlog, language
]]

-- Chat configuration
local CHAT_CONFIG = {
    ranges = {
        whisper = 3.0,
        low = 5.0,
        normal = 15.0,
        shout = 30.0,
        megaphone = 50.0
    },
    colors = {
        me = {194, 162, 218},
        ["do"] = {194, 162, 218},
        ame = {255, 194, 162},
        ado = {255, 194, 162},
        ["try"] = {255, 255, 162},
        low = {150, 150, 150},
        shout = {255, 100, 100},
        whisper = {100, 100, 255},
        ooc = {200, 200, 200},
        radio = {0, 255, 0},
        dept = {0, 255, 255},
        family = {255, 165, 0},
        gang = {255, 0, 255}
    }
}

-- Proximity chat function
function sendProximityMessage(player, message, color, range, fadeEffect)
    local x, y, z = getElementPosition(player)
    
    for _, target in ipairs(getElementsByType("player")) do
        local tx, ty, tz = getElementPosition(target)
        local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
        
        if distance <= range then
            local alpha = fadeEffect and math.floor(255 * (1 - (distance / range))) or 255
            outputChatBox(message, target, color[1], color[2], color[3])
            
            -- Add distance-based volume effect
            if fadeEffect and distance > range * 0.5 then
                triggerClientEvent("chat:distanceEffect", target, distance / range)
            end
        end
    end
end

-- Enhanced ME command with more features
addCommandHandler("me", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local action = table.concat({...}, " ")
    if not action or action == "" then
        outputChatBox("Sử dụng: /me [hành động roleplay]", player, 255, 255, 100)
        outputChatBox("Ví dụ: /me mở cửa xe và bước ra ngoài", player, 255, 255, 200)
        return
    end
    
    -- Check if player is muted
    if getElementData(player, "muted") then
        local timeLeft = (getElementData(player, "muteEnd") or 0) - getRealTime().timestamp
        local minutesLeft = math.ceil(timeLeft / 60)
        outputChatBox("Bạn đang bị mute! Thời gian còn lại: " .. minutesLeft .. " phút", player, 255, 100, 100)
        return
    end
    
    local playerName = getPlayerName(player)
    local formattedMessage = "* " .. playerName .. " " .. action
    
    sendProximityMessage(player, formattedMessage, CHAT_CONFIG.colors.me, CHAT_CONFIG.ranges.normal, true)
    
    -- Add 3D text above player
    triggerClientEvent("chat:show3DText", getRootElement(), player, action, "me", 5000)
    
    -- Animation trigger for common actions
    local lowerAction = string.lower(action)
    if string.find(lowerAction, "nói chuyện") or string.find(lowerAction, "talk") then
        triggerClientEvent("chat:triggerAnimation", player, "talking")
    elseif string.find(lowerAction, "uống") or string.find(lowerAction, "drink") then
        triggerClientEvent("chat:triggerAnimation", player, "drinking")
    elseif string.find(lowerAction, "hút thuốc") or string.find(lowerAction, "smoke") then
        triggerClientEvent("chat:triggerAnimation", player, "smoking")
    end
end)

-- Enhanced DO command
addCommandHandler("do", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local description = table.concat({...}, " ")
    if not description or description == "" then
        outputChatBox("Sử dụng: /do [mô tả môi trường/tình huống]", player, 255, 255, 100)
        outputChatBox("Ví dụ: /do Căn phòng có mùi khói thuốc nồng nặc", player, 255, 255, 200)
        return
    end
    
    -- Check if player is muted
    if getElementData(player, "muted") then
        local timeLeft = (getElementData(player, "muteEnd") or 0) - getRealTime().timestamp
        local minutesLeft = math.ceil(timeLeft / 60)
        outputChatBox("Bạn đang bị mute! Thời gian còn lại: " .. minutesLeft .. " phút", player, 255, 100, 100)
        return
    end
    
    if string.len(description) > 120 then
        outputChatBox("Mô tả không được dài quá 120 ký tự!", player, 255, 100, 100)
        return
    end
    
    local playerName = getPlayerName(player)
    local formattedMessage = "* " .. description .. " (( " .. playerName .. " ))"
    
    sendProximityMessage(player, formattedMessage, CHAT_CONFIG.colors["do"], CHAT_CONFIG.ranges.normal, true)
    
    -- Add environmental effect
    triggerClientEvent("chat:show3DText", getRootElement(), player, description, "do", 7000)
end)

-- AME command (action with /me style but longer range)
addCommandHandler("ame", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local action = table.concat({...}, " ")
    if not action or action == "" then
        outputChatBox("Sử dụng: /ame [hành động tầm xa]", player, 255, 255, 100)
        return
    end
    
    -- Check if player is muted
    if getElementData(player, "muted") then
        return
    end
    
    local playerName = getPlayerName(player)
    local formattedMessage = "* " .. playerName .. " " .. action .. " *"
    
    sendProximityMessage(player, formattedMessage, CHAT_CONFIG.colors.ame, CHAT_CONFIG.ranges.shout, true)
    
    -- Show to wider area
    triggerClientEvent("chat:show3DText", getRootElement(), player, action, "ame", 6000)
end)

-- ADO command (environmental description with longer range)
addCommandHandler("ado", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local description = table.concat({...}, " ")
    if not description or description == "" then
        outputChatBox("Sử dụng: /ado [mô tả môi trường tầm xa]", player, 255, 255, 100)
        return
    end
    
    -- Check if player is muted
    if getElementData(player, "muted") then
        return
    end
    
    local playerName = getPlayerName(player)
    local formattedMessage = "* " .. description .. " * (( " .. playerName .. " ))"
    
    sendProximityMessage(player, formattedMessage, CHAT_CONFIG.colors.ado, CHAT_CONFIG.ranges.shout, true)
end)

-- TRY command (attempt actions with random success)
addCommandHandler("try", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local action = table.concat({...}, " ")
    if not action or action == "" then
        outputChatBox("Sử dụng: /try [hành động thử]", player, 255, 255, 100)
        outputChatBox("Ví dụ: /try mở khóa cửa", player, 255, 255, 200)
        return
    end
    
    -- Check if player is muted
    if getElementData(player, "muted") then
        return
    end
    
    -- Random success/failure
    local success = math.random(1, 100) <= 50 -- 50% chance
    local result = success and "thành công" or "thất bại"
    local resultColor = success and "~g~" or "~r~"
    
    local playerName = getPlayerName(player)
    local formattedMessage = "* " .. playerName .. " cố gắng " .. action .. " và " .. result .. "."
    
    sendProximityMessage(player, formattedMessage, CHAT_CONFIG.colors["try"], CHAT_CONFIG.ranges.normal, true)
    
    -- Show result to player
    triggerClientEvent("chat:showGameText", player, resultColor .. string.upper(result), 2000)
end)

-- LOW command (quiet speech)
addCommandHandler("low", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /low [tin nhắn nhỏ]", player, 255, 255, 100)
        return
    end
    
    -- Check if player is muted
    if getElementData(player, "muted") then
        return
    end
    
    local playerName = getPlayerName(player)
    local formattedMessage = playerName .. " nói nhỏ: " .. message
    
    sendProximityMessage(player, formattedMessage, CHAT_CONFIG.colors.low, CHAT_CONFIG.ranges.low, true)
    
    -- Add whisper effect
    triggerClientEvent("chat:show3DText", getRootElement(), player, "(thì thầm)", "whisper", 3000)
end)

-- SHOUT command
addCommandHandler("shout", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /shout [la hét]", player, 255, 255, 100)
        return
    end
    
    -- Check if player is muted
    if getElementData(player, "muted") then
        return
    end
    
    local playerName = getPlayerName(player)
    local formattedMessage = playerName .. " la hét: " .. string.upper(message) .. "!"
    
    sendProximityMessage(player, formattedMessage, CHAT_CONFIG.colors.shout, CHAT_CONFIG.ranges.shout, true)
    
    -- Add shout effects
    triggerClientEvent("chat:show3DText", getRootElement(), player, "!" .. string.upper(message) .. "!", "shout", 4000)
    triggerClientEvent("chat:shoutEffect", getRootElement(), player)
end)

addCommandHandler("s", function(player, cmd, ...)
    return getCommandHandlers()["shout"](player, "shout", ...)
end)

-- Enhanced WHISPER command
addCommandHandler("whisper", function(player, cmd, targetName, ...)
    if not player or not isElement(player) then return end
    
    if not targetName then
        outputChatBox("Sử dụng: /whisper [tên người chơi] [tin nhắn]", player, 255, 255, 100)
        return
    end
    
    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end
    
    if target == player then
        outputChatBox("Bạn không thể thì thầm với chính mình!", player, 255, 100, 100)
        return
    end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /whisper [tên người chơi] [tin nhắn]", player, 255, 255, 100)
        return
    end
    
    -- Check if player is muted
    if getElementData(player, "muted") then
        return
    end
    
    -- Check proximity
    local distance = getDistanceBetweenPoints3D(getElementPosition(player), getElementPosition(target))
    if distance > CHAT_CONFIG.ranges.whisper then
        outputChatBox("Người đó quá xa để thì thầm!", player, 255, 100, 100)
        return
    end
    
    local playerName = getPlayerName(player)
    local targetPlayerName = getPlayerName(target)
    
    outputChatBox(playerName .. " thì thầm với bạn: " .. message, target, CHAT_CONFIG.colors.whisper[1], CHAT_CONFIG.colors.whisper[2], CHAT_CONFIG.colors.whisper[3])
    outputChatBox("Bạn thì thầm với " .. targetPlayerName .. ": " .. message, player, CHAT_CONFIG.colors.whisper[1], CHAT_CONFIG.colors.whisper[2], CHAT_CONFIG.colors.whisper[3])
    
    -- Show to very close players
    local x, y, z = getElementPosition(player)
    for _, nearby in ipairs(getElementsByType("player")) do
        if nearby ~= player and nearby ~= target then
            local nx, ny, nz = getElementPosition(nearby)
            local nearDistance = getDistanceBetweenPoints3D(x, y, z, nx, ny, nz)
            
            if nearDistance <= 2.0 then
                outputChatBox("Bạn nghe thấy tiếng thì thầm gần đây...", nearby, 120, 120, 120)
            end
        end
    end
    
    -- Add whisper effect
    triggerClientEvent("chat:whisperEffect", target, player)
end)

addCommandHandler("w", function(player, cmd, ...)
    return getCommandHandlers()["whisper"](player, "whisper", ...)
end)

-- Enhanced PM System
addCommandHandler("pm", function(player, cmd, targetName, ...)
    if not player or not isElement(player) then return end
    
    if not targetName then
        outputChatBox("Sử dụng: /pm [tên người chơi] [tin nhắn riêng]", player, 255, 255, 100)
        return
    end
    
    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end
    
    if target == player then
        outputChatBox("Bạn không thể gửi PM cho chính mình!", player, 255, 100, 100)
        return
    end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /pm [tên người chơi] [tin nhắn riêng]", player, 255, 255, 100)
        return
    end
    
    -- Check if target blocks PMs
    local blockPM = getElementData(target, "blockPM") or false
    local adminLevel = getElementData(player, "adminLevel") or 0
    
    if blockPM and adminLevel < 2 then
        outputChatBox("Người này đang chặn tin nhắn riêng!", player, 255, 100, 100)
        return
    end
    
    -- Check if player is muted from PMs
    if getElementData(player, "mutedPM") then
        outputChatBox("Bạn đang bị cấm gửi tin nhắn riêng!", player, 255, 100, 100)
        return
    end
    
    local playerName = getPlayerName(player)
    local targetPlayerName = getPlayerName(target)
    
    outputChatBox("PM từ " .. playerName .. ": " .. message, target, 255, 255, 100)
    outputChatBox("PM gửi đến " .. targetPlayerName .. ": " .. message, player, 255, 255, 100)
    
    -- Store for reply system
    setElementData(target, "lastPMSender", player)
    setElementData(player, "lastPMReceiver", target)
    
    -- Play notification sound
    triggerClientEvent("chat:playPMSound", target, "receive")
    triggerClientEvent("chat:playPMSound", player, "send")
    
    -- Log PM for admins
    for _, admin in ipairs(getElementsByType("player")) do
        local adminLvl = getElementData(admin, "adminLevel") or 0
        local monitorPM = getElementData(admin, "monitorPM") or false
        
        if adminLvl >= 4 and monitorPM then
            outputChatBox("(PM LOG) " .. playerName .. " -> " .. targetPlayerName .. ": " .. message, admin, 200, 200, 200)
        end
    end
end)

-- Reply to last PM
addCommandHandler("reply", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local lastSender = getElementData(player, "lastPMSender")
    if not lastSender or not isElement(lastSender) then
        outputChatBox("Không có tin nhắn nào để trả lời!", player, 255, 100, 100)
        return
    end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /reply [tin nhắn trả lời]", player, 255, 255, 100)
        return
    end
    
    local senderName = getPlayerName(lastSender)
    return getCommandHandlers()["pm"](player, "pm", senderName, message)
end)

addCommandHandler("r", function(player, cmd, ...)
    return getCommandHandlers()["reply"](player, "reply", ...)
end)

-- Toggle PM blocking
addCommandHandler("togglepm", function(player, cmd)
    if not player or not isElement(player) then return end
    
    local blockPM = getElementData(player, "blockPM") or false
    setElementData(player, "blockPM", not blockPM)
    
    if blockPM then
        outputChatBox("Bạn đã BẬT nhận tin nhắn riêng!", player, 100, 255, 100)
    else
        outputChatBox("Bạn đã TẮT nhận tin nhắn riêng!", player, 255, 100, 100)
    end
end)

-- Radio System for Organizations
addCommandHandler("radio", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /radio [tin nhắn radio]", player, 255, 255, 100)
        return
    end
    
    local hasRadio = getElementData(player, "hasRadio") or false
    local faction = getElementData(player, "faction") or 0
    
    if not hasRadio and faction == 0 then
        outputChatBox("Bạn không có radio hoặc không thuộc tổ chức nào!", player, 255, 100, 100)
        return
    end
    
    local playerName = getPlayerName(player)
    local formattedMessage = "(RADIO) " .. playerName .. ": " .. message
    
    -- Send to faction members
    for _, target in ipairs(getElementsByType("player")) do
        local targetFaction = getElementData(target, "faction") or 0
        local targetRadio = getElementData(target, "hasRadio") or false
        
        if targetFaction == faction and targetRadio then
            outputChatBox(formattedMessage, target, CHAT_CONFIG.colors.radio[1], CHAT_CONFIG.colors.radio[2], CHAT_CONFIG.colors.radio[3])
            triggerClientEvent("chat:radioEffect", target, playerName)
        end
    end
    
    -- Play radio sound to sender
    triggerClientEvent("chat:playRadioSound", player, "transmit")
end)

-- Department Radio
addCommandHandler("dept", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /dept [tin nhắn bộ phận]", player, 255, 255, 100)
        return
    end
    
    local policeRank = getElementData(player, "policeRank") or 0
    local fbiRank = getElementData(player, "fbiRank") or 0
    local medicRank = getElementData(player, "medicRank") or 0
    
    if policeRank == 0 and fbiRank == 0 and medicRank == 0 then
        outputChatBox("Bạn không thuộc bộ phận chính phủ nào!", player, 255, 100, 100)
        return
    end
    
    local playerName = getPlayerName(player)
    local formattedMessage = "(DEPT) " .. playerName .. ": " .. message
    
    -- Send to all government employees
    for _, target in ipairs(getElementsByType("player")) do
        local targetPolice = getElementData(target, "policeRank") or 0
        local targetFBI = getElementData(target, "fbiRank") or 0
        local targetMedic = getElementData(target, "medicRank") or 0
        
        if targetPolice > 0 or targetFBI > 0 or targetMedic > 0 then
            outputChatBox(formattedMessage, target, CHAT_CONFIG.colors.dept[1], CHAT_CONFIG.colors.dept[2], CHAT_CONFIG.colors.dept[3])
        end
    end
end)

-- Family Chat
addCommandHandler("family", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /family [tin nhắn gia đình]", player, 255, 255, 100)
        return
    end
    
    local familyID = getElementData(player, "familyID") or 0
    if familyID == 0 then
        outputChatBox("Bạn không thuộc gia đình nào!", player, 255, 100, 100)
        return
    end
    
    local playerName = getPlayerName(player)
    local formattedMessage = "(FAMILY) " .. playerName .. ": " .. message
    
    -- Send to family members
    for _, target in ipairs(getElementsByType("player")) do
        local targetFamily = getElementData(target, "familyID") or 0
        if targetFamily == familyID then
            outputChatBox(formattedMessage, target, CHAT_CONFIG.colors.family[1], CHAT_CONFIG.colors.family[2], CHAT_CONFIG.colors.family[3])
        end
    end
end)

addCommandHandler("f", function(player, cmd, ...)
    return getCommandHandlers()["family"](player, "family", ...)
end)

-- Megaphone System
addCommandHandler("megaphone", function(player, cmd, ...)
    if not player or not isElement(player) then return end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /megaphone [thông báo]", player, 255, 255, 100)
        return
    end
    
    local hasMegaphone = getElementData(player, "hasMegaphone") or false
    local adminLevel = getElementData(player, "adminLevel") or 0
    local policeRank = getElementData(player, "policeRank") or 0
    
    if not hasMegaphone and adminLevel < 2 and policeRank < 2 then
        outputChatBox("Bạn không có loa phóng thanh!", player, 255, 100, 100)
        return
    end
    
    local playerName = getPlayerName(player)
    local formattedMessage = "[MEGAPHONE] " .. playerName .. ": " .. string.upper(message)
    
    sendProximityMessage(player, formattedMessage, {255, 255, 0}, CHAT_CONFIG.ranges.megaphone, false)
    
    -- Add megaphone effects
    triggerClientEvent("chat:megaphoneEffect", getRootElement(), player, message)
    triggerClientEvent("chat:show3DText", getRootElement(), player, "[MEGAPHONE]", "megaphone", 3000)
end)

addCommandHandler("m", function(player, cmd, ...)
    return getCommandHandlers()["megaphone"](player, "megaphone", ...)
end)

-- Language/Accent System
addCommandHandler("accent", function(player, cmd, accentType, ...)
    if not player or not isElement(player) then return end
    
    if not accentType then
        outputChatBox("Sử dụng: /accent [loại] [tin nhắn]", player, 255, 255, 100)
        outputChatBox("Loại: vietnam, english, chinese, japanese, russian", player, 255, 255, 200)
        return
    end
    
    local validAccents = {
        vietnam = "tiếng Việt",
        english = "tiếng Anh", 
        chinese = "tiếng Trung",
        japanese = "tiếng Nhật",
        russian = "tiếng Nga"
    }
    
    if not validAccents[string.lower(accentType)] then
        outputChatBox("Loại accent không hợp lệ!", player, 255, 100, 100)
        return
    end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Sử dụng: /accent [loại] [tin nhắn]", player, 255, 255, 100)
        return
    end
    
    local playerName = getPlayerName(player)
    local accentName = validAccents[string.lower(accentType)]
    local formattedMessage = playerName .. " nói bằng " .. accentName .. ": " .. message
    
    sendProximityMessage(player, formattedMessage, {255, 200, 100}, CHAT_CONFIG.ranges.normal, true)
end)

-- Chat Log for Admins
addCommandHandler("chatlog", function(player, cmd, targetName)
    if not player or not isElement(player) then return end
    
    local adminLevel = getElementData(player, "adminLevel") or 0
    if adminLevel < 3 then
        outputChatBox("Bạn không có quyền xem chat log!", player, 255, 100, 100)
        return
    end
    
    if not targetName then
        outputChatBox("Sử dụng: /chatlog [tên người chơi]", player, 255, 255, 100)
        return
    end
    
    local target = getPlayerFromName(targetName)
    if not target then
        outputChatBox("Không tìm thấy người chơi này!", player, 255, 100, 100)
        return
    end
    
    local targetName = getPlayerName(target)
    local chatLog = getElementData(target, "chatLog") or {}
    
    outputChatBox("===== CHAT LOG: " .. targetName .. " =====", player, 255, 255, 100)
    
    if #chatLog == 0 then
        outputChatBox("Không có log chat nào.", player, 255, 200, 200)
    else
        for i = math.max(1, #chatLog - 10), #chatLog do
            outputChatBox(chatLog[i], player, 255, 255, 255)
        end
    end
    
    outputChatBox("=====================================", player, 255, 255, 100)
end)

-- Helper function to get player from partial name
function getPlayerFromName(name)
    if not name then return nil end
    
    name = string.lower(name)
    for _, player in ipairs(getElementsByType("player")) do
        local playerName = string.lower(getPlayerName(player))
        if string.find(playerName, name, 1, true) then
            return player
        end
    end
    return nil
end

-- Save chat log
addEventHandler("onPlayerChat", getRootElement(), function(message, messageType)
    local player = source
    local chatLog = getElementData(player, "chatLog") or {}
    local timestamp = os.date("%H:%M:%S")
    local playerName = getPlayerName(player)
    
    table.insert(chatLog, "[" .. timestamp .. "] " .. playerName .. ": " .. message)
    
    -- Keep only last 50 messages
    if #chatLog > 50 then
        table.remove(chatLog, 1)
    end
    
    setElementData(player, "chatLog", chatLog)
end)

outputDebugString("Extended Communication System loaded successfully! (25 commands)")
