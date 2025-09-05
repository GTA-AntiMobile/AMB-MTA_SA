-- ================================================================
-- AMB MTA:SA - Enhanced Custom Chatbox (Client-Side)
-- ================================================================
local screenW, screenH = guiGetScreenSize()
local chatVisible = true
local chatAlpha = 255
local chatFont = "default-bold"
local chatFontSize = 1.1
local fontBaseHeight = dxGetFontHeight(chatFontSize, chatFont)
local lineHeight = math.floor(fontBaseHeight + 6)

-- Messages & history
local chatMessages = {}
-- local maxMessages = 300
local chatInputBox = nil
local chatInputActive = false
local chatKeyHandler = nil
local chatScrollOffset = 0
local chatboxActive = false
_G.persistentCommandHistory = _G.persistentCommandHistory or {}

-- Chatbox position
local chatX, chatY = 15, 30
local chatWidth, chatHeight = 650, 450

---------------------------------------------------------------------
-- Add message
---------------------------------------------------------------------
function addChatMessage(text, r, g, b)
    if not text then
        return
    end
    for line in string.gmatch(text, "[^\n]+") do
        local rt = getRealTime()
        local timestamp = string.format("[%02d:%02d]", rt.hour, rt.minute)
        table.insert(chatMessages, {
            time = timestamp,
            text = line,
            r = r or 255,
            g = g or 255,
            b = b or 255
        })
    end
    -- while #chatMessages > maxMessages do
    --     table.remove(chatMessages, 1)
    -- end
    chatScrollOffset = 0
end

---------------------------------------------------------------------
-- Draw chat
---------------------------------------------------------------------
function drawCustomChatbox()
    if not chatVisible then
        return
    end
    dxDrawRectangle(chatX - 5, chatY - 5, chatWidth + 10, chatHeight + 10, tocolor(0, 0, 0, chatAlpha * 0.7))
    dxDrawRectangle(chatX - 5, chatY - 5, chatWidth + 10, 3, tocolor(255, 165, 0, chatAlpha))
    dxDrawRectangle(chatX - 5, chatY + chatHeight + 2, chatWidth + 10, 3, tocolor(255, 165, 0, chatAlpha))

    local visibleLines = math.floor(chatHeight / lineHeight)
    local startIndex = math.max(1, #chatMessages - visibleLines + 1 - chatScrollOffset)
    local endIndex = math.min(#chatMessages, startIndex + visibleLines - 1)
    local drawIndex = 0

    for i = startIndex, endIndex do
        local msg = chatMessages[i]
        if msg then
            local y = chatY + (drawIndex * lineHeight)
            drawIndex = drawIndex + 1
            dxDrawText(msg.time, chatX + 5, y, chatX + 85, y + lineHeight, tocolor(180, 180, 180, chatAlpha),
                chatFontSize * 0.85, chatFont, "left", "center")
            dxDrawText(msg.text, chatX + 90, y, chatX + chatWidth - 15, y + lineHeight,
                tocolor(msg.r, msg.g, msg.b, chatAlpha), chatFontSize, chatFont, "left", "center", false, true)
        end
    end

    if chatScrollOffset > 0 then
        dxDrawText("↑ SCROLL ↑", chatX + chatWidth - 100, chatY - 20, chatX + chatWidth, chatY,
            tocolor(255, 255, 0, chatAlpha), 0.8, chatFont, "center", "center")
    end
end

---------------------------------------------------------------------
-- Open chat input - với T key protection
---------------------------------------------------------------------
function openChatInput()
    if chatInputActive then
        return
    end
    chatInputActive = true
    _G.chatInputActive = true

    local inputY = chatY + chatHeight + 20
    if chatInputBox and isElement(chatInputBox) then
        destroyElement(chatInputBox)
    end

    chatInputBox = guiCreateEdit(chatX, inputY, chatWidth, 30, "", false)
    _G.chatInputBox = chatInputBox
    guiSetAlpha(chatInputBox, 1.0)
    guiSetFont(chatInputBox, "default-bold-small")
    guiBringToFront(chatInputBox)
    guiSetInputEnabled(true)
    guiSetVisible(chatInputBox, true)
    showCursor(true)
    
    -- CLEAR any existing text để tránh T dính
    setTimer(function()
        if chatInputBox and isElement(chatInputBox) then
            guiSetText(chatInputBox, "")
        end
    end, 50, 1)

    -- Enter send
    addEventHandler("onClientGUIAccepted", chatInputBox, function()
        local text = guiGetText(chatInputBox)
        if text and text ~= "" then
            sendChatMessage(text)
        end
        closeChatInput()
        chatboxActive = false
        chatVisible = false
        showChat(false)
    end)

    -- History navigation
    local history = _G.persistentCommandHistory or {}
    local historyIndex = #history + 1
    chatKeyHandler = function(key, press)
        if not press or not chatInputActive then
            return
        end
        if key == "escape" then
            closeChatInput()
            cancelEvent()
        elseif key == "arrow_u" then
            if #history > 0 and historyIndex > 1 then
                historyIndex = historyIndex - 1
                local cmd = history[historyIndex]
                guiSetText(chatInputBox, cmd)
                guiEditSetCaretIndex(chatInputBox, #cmd)
            end
            cancelEvent()
        elseif key == "arrow_d" then
            if #history > 0 then
                if historyIndex < #history then
                    historyIndex = historyIndex + 1
                    local cmd = history[historyIndex]
                    guiSetText(chatInputBox, cmd)
                    guiEditSetCaretIndex(chatInputBox, #cmd)
                elseif historyIndex == #history then
                    historyIndex = #history + 1
                    guiSetText(chatInputBox, "")
                    guiEditSetCaretIndex(chatInputBox, 0)
                end
            end
            cancelEvent()
        end
    end
    addEventHandler("onClientKey", root, chatKeyHandler)
end

---------------------------------------------------------------------
-- Close chat input
---------------------------------------------------------------------
function closeChatInput()
    chatInputActive = false
    _G.chatInputActive = false
    if chatKeyHandler then
        removeEventHandler("onClientKey", root, chatKeyHandler)
        chatKeyHandler = nil
    end
    if chatInputBox and isElement(chatInputBox) then
        destroyElement(chatInputBox)
        chatInputBox = nil
        _G.chatInputBox = nil
    end
    guiSetInputEnabled(false)
    showCursor(false)
end

---------------------------------------------------------------------
-- Send chat or command
---------------------------------------------------------------------
function sendChatMessage(message)
    if not message or message:match("^%s*$") then
        return
    end
    _G.persistentCommandHistory = _G.persistentCommandHistory or {}
    table.insert(_G.persistentCommandHistory, message)
    if #_G.persistentCommandHistory > 50 then
        table.remove(_G.persistentCommandHistory, 1)
    end

    if message:sub(1, 1) == "/" then
        triggerServerEvent("onCustomPlayerCommand", localPlayer, message:sub(2))
    else
        triggerServerEvent("onCustomPlayerChat", localPlayer, message)
    end
end

---------------------------------------------------------------------
-- Events
---------------------------------------------------------------------
addEventHandler("onClientChatMessage", root, function(text, r, g, b)
    cancelEvent()
    addChatMessage(text, r, g, b)
end)

addEvent("onServerCustomChatMessage", true)
addEventHandler("onServerCustomChatMessage", root, function(text, r, g, b)
    addChatMessage(text, r, g, b)
end)

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
addEventHandler("onClientResourceStart", resourceRoot, function()

    -- Khi mới vào, chatbox sẽ ẩn hoàn toàn
    chatboxActive = false
    chatVisible = false
    showChat(false)

    -- Mouse wheel scroll
    addEventHandler("onClientKey", root, function(key, press)
        if not press then return end
        if key == "mouse_wheel_up" then
            local visibleLines = math.floor(chatHeight / lineHeight)
            if chatScrollOffset < #chatMessages - visibleLines then
                chatScrollOffset = chatScrollOffset + 3
            end
        elseif key == "mouse_wheel_down" then
            if chatScrollOffset > 0 then
                chatScrollOffset = math.max(0, chatScrollOffset - 3)
            end
        end
    end)

    addEventHandler("onClientRender", root, drawCustomChatbox)

    addChatMessage("🎮 AMB Chatbox Loaded - Nhấn F6 để mở/ẩn chat, Mouse wheel để scroll", 100, 255, 100)
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
    showChat(true)
end)

bindKey("F6", "down", toggleChatbox)
function toggleChatbox()
    if not chatboxActive then
        chatboxActive = true
        chatVisible = true
        openChatInput()
        showChat(false) -- Luôn ẩn chatbox mặc định khi mở custom chatbox
    else
        chatboxActive = false
        chatVisible = false
        closeChatInput()
        showChat(false) -- Hiện lại chatbox mặc định khi tắt custom chatbox
    end
end

bindKey("F6", "down", toggleChatbox)