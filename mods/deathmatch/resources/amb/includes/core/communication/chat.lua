-- ================================
-- AMB Chat Control System
-- Prevents non-logged users from chatting
-- ================================

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
