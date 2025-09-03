-- ================================
-- AMB Chat Control System
-- Prevents non-logged users from chatting
-- ================================
-- Utility function để split string
function split(str, delimiter)
    local result = {}
    local pattern = "(.-)" .. delimiter
    local lastEnd = 1
    local s, e, cap = str:find(pattern, 1)
    while s do
        if s ~= 1 or cap ~= "" then
            table.insert(result, cap)
        end
        lastEnd = e + 1
        s, e, cap = str:find(pattern, lastEnd)
    end
    if lastEnd <= #str then
        cap = str:sub(lastEnd)
        table.insert(result, cap)
    end
    return result
end

-- Gửi tin nhắn custom tới 1 player, hỗ trợ xuống dòng
function sendCustomMessage(player, text, r, g, b)
    if not isElement(player) then
        outputDebugString("[sendCustomMessage] Invalid player element: " .. tostring(player))
        return
    end

    outputDebugString("[sendCustomMessage] Sending to " .. getPlayerName(player) .. ": " .. text)

    -- Split multiline text
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end

    -- Nếu không có dòng nào thì gửi luôn text gốc
    if #lines == 0 then
        triggerClientEvent(player, "onServerCustomChatMessage", root, text, r or 255, g or 255, b or 255)
        return
    end

    -- Gửi từng dòng với delay nhỏ để không bị overlap
    for i, line in ipairs(lines) do
        setTimer(function()
            if isElement(player) then
                triggerClientEvent(player, "onServerCustomChatMessage", root, line, r or 255, g or 255, b or 255)
            end
        end, (i - 1) * 150, 1) -- Delay 150ms
    end
end

-- Gửi tin nhắn cho tất cả người chơi
function broadcastCustomMessage(text, r, g, b)
    triggerClientEvent(root, "onServerCustomChatMessage", root, text, r or 255, g or 255, b or 255)
end

-- Block chat for non-logged players
addEventHandler("onPlayerChat", root, function(message, messageType)
    local player = source

    -- Check if player is logged in
    if not getElementData(player, "loggedIn") then
        cancelEvent() -- Block the chat message
        return
    end

    -- Allow chat for logged players
    local username = getElementData(player, "username") or "Unknown"
    outputDebugString("[CHAT] " .. username .. ": " .. message)
end)

-- Cho phép client gửi command
addEvent("onCustomPlayerCommand", true)
addEventHandler("onCustomPlayerCommand", root, function(cmd)
    local player = client

    if not getElementData(player, "loggedIn") then
        outputChatBox("❌ Bạn phải đăng nhập trước khi có thể chat được!", player, 255, 100, 100)
        return
    end

    local parts = split(cmd, " ")
    local command = parts[1]
    local args = {unpack(parts, 2)}

    outputDebugString("[COMMAND] " .. getPlayerName(player) .. " executing: /" .. cmd)

    -- Execute directly
    executeCommandHandler(command, player, unpack(args))
end)

-- Cho phép client gửi chat thường
addEvent("onCustomPlayerChat", true)
addEventHandler("onCustomPlayerChat", root, function(msg)
    local player = client

    if not getElementData(player, "loggedIn") then
        sendCustomMessage(player, "❌ Bạn phải đăng nhập trước khi có thể chat được!", 255, 100, 100)
        return
    end

    if type(msg) == "string" and msg ~= "" then
        local username = getElementData(player, "username") or getPlayerName(player)
        local fullMessage = username .. ": " .. msg

        -- Broadcast custom
        broadcastCustomMessage(fullMessage, 255, 255, 255)

        -- Server log
        outputDebugString("[CHAT] " .. fullMessage)
        outputConsole("[CHAT] " .. fullMessage)
    end
end)

-- Block private messages for non-logged players
addEventHandler("onPlayerPrivateMessage", root, function(message, receiver)
    local player = source

    if not getElementData(player, "loggedIn") then
        outputChatBox("❌ Bạn phải đăng nhập trước khi có thể chat riêng tư được!", player, 255,
            100, 100)
        cancelEvent()
        return
    end

    -- Check if receiver is logged in
    if not getElementData(receiver, "loggedIn") then
        outputChatBox("❌ Target player is not logged in!", player, 255, 100, 100)
        cancelEvent()
        return
    end
end)

-- Block team chat for non-logged players  
addEventHandler("onPlayerTeamChat", root, function(message)
    local player = source

    if not getElementData(player, "loggedIn") then
        outputChatBox("❌ Bạn phải đăng nhập trước khi có thể chat nhóm được!", player, 255, 100,
            100)
        cancelEvent()
        return
    end
end)

outputDebugString("[CHAT] Chat control system loaded - blocking chat for non-logged players")
