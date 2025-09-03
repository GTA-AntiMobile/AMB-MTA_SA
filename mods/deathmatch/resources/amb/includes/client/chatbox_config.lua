-- ================================================================
-- AMB MTA:SA - Enhanced Custom Chatbox (Client-Side Clean Version)
-- ================================================================
local screenW, screenH = guiGetScreenSize()
local chatVisible = true
local chatAlpha = 255
local chatFont = "default-bold"
local chatFontSize = 1.1
local fontBaseHeight = dxGetFontHeight(chatFontSize, chatFont)
local lineHeight = math.floor(fontBaseHeight + 6)

-- Store messages
local chatMessages = {}
local maxMessages = 300
local commandHistory = {}
local historyIndex = 0
local chatScrollOffset = 0

-- Persistent storage cho history
_G.persistentCommandHistory = _G.persistentCommandHistory or {}

-- Input state
local chatInputBox = nil
local chatInputActive = false
_G.chatInputActive = false
_G.chatInputBox = nil
local chatKeyHandler = nil -- Store handler reference for removal

-- Chatbox position
local chatX, chatY = 15, 30
local chatWidth, chatHeight = 650, 450

---------------------------------------------------------------------
-- Add message to custom chat
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
            b = b or 255,
            tick = getTickCount() + math.random(1, 10)
        })
    end

    while #chatMessages > maxMessages do
        table.remove(chatMessages, 1)
    end

    chatScrollOffset = 0
end

---------------------------------------------------------------------
-- Draw custom chat
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
        if i > 0 and chatMessages[i] then
            local msg = chatMessages[i]
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
-- Open chat input
---------------------------------------------------------------------
function openChatInput()
    if chatInputActive then
        return
    end

    chatInputActive = true
    _G.chatInputActive = true

    commandHistory = _G.persistentCommandHistory
    historyIndex = #_G.persistentCommandHistory + 1

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
    guiSetInputMode("no_binds_when_editing")
    guiSetVisible(chatInputBox, true)
    showCursor(true)

    setTimer(function()
        if isElement(chatInputBox) then
            guiSetText(chatInputBox, "")
            guiEditSetCaretIndex(chatInputBox, 0)
            guiBringToFront(chatInputBox)
        end
    end, 50, 1)

    addEventHandler("onClientGUIAccepted", chatInputBox, function()
        local text = guiGetText(chatInputBox)
        if text and text ~= "" then
            sendChatMessage(text)
        end
        closeChatInput()
    end)

    -- Key navigation for history
    chatKeyHandler = function(key, press)
        -- Key navigation for history
        chatKeyHandler = function(key, press)
            if not press or not chatInputActive then
                return
            end

            if key == "escape" then
                closeChatInput()
                cancelEvent()

                -- Arrow UP: newest -> oldest
            elseif key == "arrow_u" then
                local currentHistory = _G.persistentCommandHistory
                if #currentHistory > 0 and historyIndex > 1 then
                    historyIndex = historyIndex - 1
                    local cmd = currentHistory[historyIndex]
                    guiSetText(chatInputBox, cmd)
                    guiEditSetCaretIndex(chatInputBox, string.len(cmd))
                end
                cancelEvent()

                -- Arrow DOWN: oldest -> newest, then clear
            elseif key == "arrow_d" then
                local currentHistory = _G.persistentCommandHistory
                if #currentHistory > 0 then
                    if historyIndex < #currentHistory then
                        historyIndex = historyIndex + 1
                        local cmd = currentHistory[historyIndex]
                        guiSetText(chatInputBox, cmd)
                        guiEditSetCaretIndex(chatInputBox, string.len(cmd))
                    elseif historyIndex == #currentHistory then
                        historyIndex = #currentHistory + 1
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

        -- Remove key event handler
        if chatKeyHandler then
            removeEventHandler("onClientKey", root, chatKeyHandler)
            chatKeyHandler = nil
        end

        if chatInputBox and isElement(chatInputBox) then
            destroyElement(chatInputBox)
            chatInputBox = nil
            _G.chatInputBox = nil
        end

        showCursor(false)
        guiSetInputEnabled(false)
    end

    ---------------------------------------------------------------------
    -- Send chat message or command
    ---------------------------------------------------------------------
    function sendChatMessage(message)
        if message == "" then
            return
        end

        -- Xoá bản cũ nếu đã tồn tại để tránh duplicate
        for i, cmd in ipairs(_G.persistentCommandHistory) do
            if cmd == message then
                table.remove(_G.persistentCommandHistory, i)
                break
            end
        end

        -- Thêm newest vào cuối
        table.insert(_G.persistentCommandHistory, message)

        -- Giữ tối đa 50 message
        if #_G.persistentCommandHistory > 50 then
            table.remove(_G.persistentCommandHistory, 1)
        end

        commandHistory = _G.persistentCommandHistory
        historyIndex = #_G.persistentCommandHistory + 1

        -- Gửi command hoặc chat
        if string.sub(message, 1, 1) == "/" then
            local cmd = string.sub(message, 2)
            triggerServerEvent("onCustomPlayerCommand", localPlayer, cmd)
        else
            triggerServerEvent("onCustomPlayerChat", localPlayer, message)
        end
    end

    ---------------------------------------------------------------------
    -- Event: Receive chat from server
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
    -- Toggle custom chatbox
    ---------------------------------------------------------------------
    addCommandHandler("togglechat", function()
        chatVisible = not chatVisible
        local state = chatVisible and "shown" or "hidden"
        addChatMessage("📺 Chatbox " .. state, 255, 255, 0)
    end)

    ---------------------------------------------------------------------
    -- Clear command history
    ---------------------------------------------------------------------
    addCommandHandler("clearhistory", function()
        _G.persistentCommandHistory = {}
        commandHistory = {}
        historyIndex = 1
        addChatMessage("📚 Command history cleared", 255, 255, 0)
    end)

    ---------------------------------------------------------------------
    -- Init
    ---------------------------------------------------------------------
    addEventHandler("onClientResourceStart", resourceRoot, function()
        showChat(false)
        addEventHandler("onClientRender", root, drawCustomChatbox)

        unbindKey("t", "down", "chatbox")
        bindKey("t", "down", openChatInput)

        -- Scroll với chuột
        addEventHandler("onClientKey", root, function(key, press)
            if not press then
                return
            end

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

        addChatMessage("🎮 AMB Chatbox Loaded - Mouse wheel để scroll", 100, 255, 100)
    end)

    addEventHandler("onClientResourceStop", resourceRoot, function()
        showChat(true)
    end)
end
