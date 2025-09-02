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

-- Block chat for non-logged players
addEventHandler("onPlayerChat", root, function(message, messageType)
    local player = source

    -- Check if player is logged in
    if not getElementData(player, "loggedIn") then
        outputChatBox("❌ You must login first to use chat!", player, 255, 100, 100)
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
    
    -- Debug log to verify event is received
    outputDebugString("[DEBUG] onCustomPlayerCommand received from " .. getPlayerName(player) .. ": " .. tostring(cmd))
    
    -- Check if player is logged in before processing commands
    if not getElementData(player, "loggedIn") then
        outputChatBox("❌ You must login first to use commands!", player, 255, 100, 100)
        return
    end
    
    -- Parse command and arguments
    local cmdParts = split(cmd, " ")
    local command = cmdParts[1]
    local args = {}
    for i = 2, #cmdParts do
        table.insert(args, cmdParts[i])
    end
    
    -- Log command attempt
    outputDebugString("[COMMAND] " .. getPlayerName(player) .. " attempting: /" .. cmd)
    
    -- Try to execute command using simpler approach
    local success = false
    
    -- Method 1: Try direct executeCommandHandler
    if executeCommandHandler then
        success = executeCommandHandler(command, player, unpack(args))
        if success then
            outputDebugString("[COMMAND] Successfully executed via executeCommandHandler: /" .. cmd)
        end
    end
    
    -- Method 2: If that failed, try triggering command event
    if not success then
        local fullCommand = "/" .. cmd
        success = triggerEvent("onConsole", player, fullCommand)
        if success then
            outputDebugString("[COMMAND] Successfully executed via onConsole: /" .. cmd)
        end
    end
    
    -- If all methods failed
    if not success then
        outputChatBox("Unknown command: /" .. command, player, 255, 100, 100)
        outputDebugString("[COMMAND] Command failed: /" .. cmd)
    end
end)

-- Cho phép client gửi chat thường
addEvent("onCustomPlayerChat", true)
addEventHandler("onCustomPlayerChat", root, function(msg)
    local player = client
    
    -- Debug log to verify event is received
    outputDebugString("[DEBUG] onCustomPlayerChat received from " .. getPlayerName(player) .. ": " .. tostring(msg))
    
    -- Check if player is logged in
    if not getElementData(player, "loggedIn") then
        outputChatBox("❌ You must login first to use chat!", player, 255, 100, 100)
        return
    end
    
    if type(msg) == "string" and msg ~= "" then
        local playerName = getPlayerName(player)
        local username = getElementData(player, "username") or playerName
        
        -- Broadcast tin nhắn cho tất cả players
        local fullMessage = username .. ": " .. msg
        outputChatBox(fullMessage, root, 255, 255, 255)
        
        -- Log vào server debug và console
        outputDebugString("[CHAT] " .. fullMessage)
        outputConsole("[CHAT] " .. fullMessage)
    end
end)

-- Block private messages for non-logged players
addEventHandler("onPlayerPrivateMessage", root, function(message, receiver)
    local player = source

    if not getElementData(player, "loggedIn") then
        outputChatBox("❌ You must login first to send private messages!", player, 255, 100, 100)
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
        outputChatBox("❌ You must login first to use team chat!", player, 255, 100, 100)
        cancelEvent()
        return
    end
end)

outputDebugString("[CHAT] Chat control system loaded - blocking chat for non-logged players")
