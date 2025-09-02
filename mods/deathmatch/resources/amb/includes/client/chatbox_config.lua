-- ================================================================
-- AMB MTA:SA - Enhanced Custom Chatbox
-- Chatbox tùy chỉnh với font lớn và nhiều dòng hơn
-- ================================================================

-- Client log function (write to client.log)
function clientLog(level, message)
    local rt = getRealTime()
    local timestamp = string.format("[%04d-%02d-%02d %02d:%02d:%02d]", rt.year + 1900, rt.month + 1, rt.monthday,
        rt.hour, rt.minute, rt.second)

    local logLine = string.format("%s %s: %s", timestamp, level, message)

    -- Write to file only, no console output unless error
    local file = fileOpen("logs/client.log", false)
    if not file then
        -- Try to create file
        file = fileCreate("logs/client.log")
        if not file then
            -- Only output to console if file creation failed
            outputConsole("[CLIENT_LOG_ERROR] Could not create logs/client.log: " .. logLine)
            return
        end
    else
        -- Move to end of file for append
        fileSetPos(file, fileGetSize(file))
    end

    if file then
        fileWrite(file, logLine .. "\n")
        fileClose(file)
        -- Silent operation - no console output unless it's an error
    end
end

local screenW, screenH = guiGetScreenSize()
local chatMessages = {}
local maxMessages = 15 -- Tăng lên 15 dòng để hiển thị nhiều hơn
local chatFont = "default-bold"
local chatFontSize = 1.1 -- Tăng font size lên 130% để dễ đọc hơn
local chatVisible = true -- Luôn hiển thị custom chatbox
local chatAlpha = 255 -- Tăng độ rõ nét tối đa
local chatInput = ""
local chatInputActive = false
local chatInputCursor = 0
local chatInputBox = nil
local commandHistory = {} -- Command history storage
local historyIndex = 0 -- Current position in history

-- Export chatInputActive to global scope for input handler
_G.chatInputActive = false
_G.chatInputBox = nil

-- Vị trí và kích thước chatbox - dời lên phía trên bên trái
local chatX = 15
local chatY = 30 -- Dời lên cao hơn
local chatWidth = 450 -- Tăng độ rộng để chứa text dài hơn
local chatHeight = 300 -- Tăng chiều cao để chứa 15 dòng với spacing tốt
local lineHeight = 15 -- Tăng khoảng cách giữa các dòng để tránh chồng chéo
local inputHeight = 20 -- Tăng chiều cao input box

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

-- UTF-8 safe functions (fallback nếu không có utf8 library)
local function safeUtf8Len(str)
    if utf8 and utf8.len then
        return utf8.len(str) or #str
    end
    return #str
end

local function safeUtf8Sub(str, start, finish)
    if utf8 and utf8.sub then
        return utf8.sub(str, start, finish) or string.sub(str, start, finish or -1)
    end
    return string.sub(str, start, finish or -1)
end

-- Cấu hình chatbox khi resource khởi động
addEventHandler("onClientResourceStart", resourceRoot, function()
    -- Ẩn chatbox mặc định của MTA hoàn toàn
    showChat(false)

    -- Khởi tạo custom chatbox
    addEventHandler("onClientRender", root, drawCustomChatbox)

    -- Unbind tất cả T key bindings của MTA
    unbindKey("t", "down", "chatbox")

    -- Bind T key cho custom chat input hoàn toàn
    bindKey("t", "down", function()
        if not chatInputActive then
            -- Prevent MTA default chat from showing
            cancelEvent()
            -- Open custom input without delay
            openChatInput()
        end
    end)

    -- Đảm bảo F8 console vẫn hoạt động
    unbindKey("F8", "down") -- Unbind any existing bindings
    -- F8 sẽ sử dụng MTA default behavior

    clientLog("CLIENNT", "✅ [CHATBOX] Enhanced custom chatbox loaded - custom input only")
    -- Hiển thị chatbox (ít welcome messages)
    chatVisible = true
    addChatMessage("🎮 AMB MTA:SA Server Ready", 100, 255, 100)
end)

-- Cleanup khi resource stop
addEventHandler("onClientResourceStop", resourceRoot, function()
    closeChatInput()

    -- Restore MTA default chatbox
    showChat(true)

    clientLog("CLIENNT", "✅ [CHATBOX] Custom chatbox cleaned up and MTA default restored")
end)

-- Thêm tin nhắn vào custom chatbox
function addChatMessage(text, r, g, b, timestamp)
    local time = timestamp or getRealTime()
    local timeStr = string.format("[%02d:%02d]", time.hour, time.minute)

    local message = {
        text = text,
        r = r or 255,
        g = g or 255,
        b = b or 255,
        time = timeStr,
        alpha = 255,
        fadeTimer = getTickCount()
    }

    table.insert(chatMessages, message)

    -- Giữ chỉ maxMessages tin nhắn gần nhất
    if #chatMessages > maxMessages then
        table.remove(chatMessages, 1)
    end

    -- Auto-show chatbox khi có tin nhắn mới (trừ system messages)
    if not chatVisible and not string.find(text, "📺") then
        chatVisible = true
        clientLog("CLIENNT", "📺 [CHATBOX] Auto-shown due to new message")
    end
end

-- Vẽ custom chatbox
function drawCustomChatbox()
    if not chatVisible then
        return
    end

    local currentTime = getTickCount()

    -- Vẽ background chatbox với độ trong suốt
    dxDrawRectangle(chatX - 5, chatY - 5, chatWidth + 10, chatHeight + 10, tocolor(0, 0, 0, chatAlpha * 0.7))

    -- Vẽ viền
    dxDrawRectangle(chatX - 5, chatY - 5, chatWidth + 10, 3, tocolor(255, 165, 0, chatAlpha)) -- Top
    dxDrawRectangle(chatX - 5, chatY + chatHeight + 2, chatWidth + 10, 3, tocolor(255, 165, 0, chatAlpha)) -- Bottom

    -- Vẽ các tin nhắn với spacing tốt hơn
    for i, message in ipairs(chatMessages) do
        local y = chatY + (i - 1) * lineHeight + 5 -- Thêm padding top

        -- Đảm bảo không vẽ quá khung chatbox
        if y + lineHeight > chatY + chatHeight then
            break
        end

        -- Tính toán fade effect (tin nhắn cũ sẽ mờ dần)
        local age = currentTime - message.fadeTimer
        local alpha = chatAlpha
        if age > 15000 then -- Sau 15 giây bắt đầu fade
            alpha = math.max(80, chatAlpha - ((age - 15000) / 30)) -- Fade trong 30 giây
        end

        -- Vẽ timestamp với khoảng cách rõ ràng
        dxDrawText(message.time, chatX + 5, y, chatX + 85, y + lineHeight, tocolor(180, 180, 180, alpha),
            chatFontSize * 0.85, chatFont, "left", "center")

        -- Vẽ tin nhắn chính với font lớn và spacing rõ ràng
        dxDrawText(message.text, chatX + 90, y, chatX + chatWidth - 15, y + lineHeight,
            tocolor(message.r, message.g, message.b, alpha), chatFontSize, chatFont, "left", "center", false, true)
    end

    -- Không hiển thị hint text để tránh chồng chéo với input box

    -- Không hiển thị status typing nữa để tránh chồng chéo
end

-- Mở chat input với GUI hoàn toàn custom
function openChatInput()
    -- Đảm bảo không mở nếu đã có input active
    if chatInputActive then
        return
    end

    chatInputActive = true
    _G.chatInputActive = true
    chatInput = ""
    chatInputCursor = 0
    
    -- Reset history index khi mở chat input
    historyIndex = #commandHistory + 1

    -- Tạo GUI input custom ở vị trí rõ ràng
    local inputX = chatX
    local inputY = chatY + chatHeight + 20 -- Tăng khoảng cách
    local inputWidth = chatWidth
    local inputHeight = 30 -- Tăng chiều cao

    -- Destroy existing input box if any
    if chatInputBox then
        destroyElement(chatInputBox)
        chatInputBox = nil
        _G.chatInputBox = nil
    end

    -- Tạo GUI edit box mới hoàn toàn sạch
    chatInputBox = guiCreateEdit(inputX, inputY, inputWidth, inputHeight, "", false)
    _G.chatInputBox = chatInputBox

    -- Cấu hình edit box
    guiSetAlpha(chatInputBox, 1.0) -- Tăng độ rõ nét
    guiSetFont(chatInputBox, "default-bold-small")
    guiEditSetCaretIndex(chatInputBox, 0)
    guiBringToFront(chatInputBox)
    guiSetInputEnabled(true)
    guiSetInputMode("no_binds_when_editing")

    -- Hiển thị và focus
    guiSetVisible(chatInputBox, true)
    showCursor(true)

    -- Set text rỗng để đảm bảo không có chữ "t" dính và focus input
    setTimer(function()
        if chatInputBox and isElement(chatInputBox) then
            guiSetText(chatInputBox, "")
            guiEditSetCaretIndex(chatInputBox, 0)
            -- Focus the input box
            guiBringToFront(chatInputBox)
            
            -- Reset history index when opening fresh input
            historyIndex = #commandHistory + 1
        end
    end, 10, 1)

    -- Remove old event handlers to avoid duplicates
    if _G.chatAcceptHandler then
        removeEventHandler("onClientGUIAccepted", chatInputBox, _G.chatAcceptHandler)
    end
    if _G.chatKeyHandler then
        removeEventHandler("onClientKey", root, _G.chatKeyHandler)
    end

    -- Event handler cho Enter (accept)
    _G.chatAcceptHandler = function()
        local text = guiGetText(source)
        if text and text ~= "" then
            sendChatMessage(text)
        end
        closeChatInput()
    end
    addEventHandler("onClientGUIAccepted", chatInputBox, _G.chatAcceptHandler)

    -- Key handler cho command history (arrow keys) và ESC
    _G.chatKeyHandler = function(key, press)
        if not press or not chatInputActive or not chatInputBox or not isElement(chatInputBox) then
            return
        end
        
        if key == "escape" then
            closeChatInput()
            cancelEvent()
        elseif key == "arrow_u" then -- Mũi tên lên - lấy command cũ hơn
            if historyIndex > 1 then
                historyIndex = historyIndex - 1
                guiSetText(chatInputBox, commandHistory[historyIndex] or "")
                guiEditSetCaretIndex(chatInputBox, string.len(guiGetText(chatInputBox)))
            end
            cancelEvent()
        elseif key == "arrow_d" then -- Mũi tên xuống - lấy command mới hơn
            if historyIndex < #commandHistory then
                historyIndex = historyIndex + 1
                guiSetText(chatInputBox, commandHistory[historyIndex] or "")
                guiEditSetCaretIndex(chatInputBox, string.len(guiGetText(chatInputBox)))
            elseif historyIndex == #commandHistory then
                historyIndex = #commandHistory + 1
                guiSetText(chatInputBox, "")
                guiEditSetCaretIndex(chatInputBox, 0)
            end
            cancelEvent()
        end
    end
    addEventHandler("onClientKey", root, _G.chatKeyHandler)
end

-- Đóng chat input
function closeChatInput()
    chatInputActive = false
    _G.chatInputActive = false
    chatInput = ""

    -- Remove event handlers
    if _G.chatAcceptHandler and chatInputBox and isElement(chatInputBox) then
        removeEventHandler("onClientGUIAccepted", chatInputBox, _G.chatAcceptHandler)
        _G.chatAcceptHandler = nil
    end
    if _G.chatKeyHandler then
        removeEventHandler("onClientKey", root, _G.chatKeyHandler)
        _G.chatKeyHandler = nil
    end

    -- Ẩn và destroy GUI input
    if chatInputBox and isElement(chatInputBox) then
        destroyElement(chatInputBox)
        chatInputBox = nil
        _G.chatInputBox = nil
    end

    showCursor(false)
    guiSetInputEnabled(false)
end

-- Gửi tin nhắn
function sendChatMessage(message)
    local text = message or chatInput
    if text and text ~= "" then
        -- Add to command history (chỉ thêm nếu khác với command cuối cùng)
        if #commandHistory == 0 or commandHistory[#commandHistory] ~= text then
            table.insert(commandHistory, text)
            -- Giới hạn 50 command gần nhất
            if #commandHistory > 50 then
                table.remove(commandHistory, 1)
            end
        end
        -- Reset history index
        historyIndex = #commandHistory + 1
        
        if string.sub(text, 1, 1) == "/" then
            -- Xử lý command - KHÔNG hiển thị trong chatbox để tránh duplicate
            local cmd = string.sub(text, 2)
            
            -- Gửi command sang server để execute
            triggerServerEvent("onCustomPlayerCommand", localPlayer, cmd)
            
            -- Log command locally để user biết đã gửi
            clientLog("COMMAND", "Sent to server: /" .. cmd)
            
            -- Show feedback in custom chatbox
            addChatMessage(">>> /" .. cmd, 150, 150, 150)
        else
            -- Xử lý chat thường
            -- Gửi sang server để handle việc broadcast
            triggerServerEvent("onCustomPlayerChat", localPlayer, text)
            
            -- Log chat locally
            clientLog("CHAT", "Sent: " .. text)
        end
    end

    closeChatInput()
end

-- Xử lý key events cho chat input và navigation
addEventHandler("onClientKey", root, function(key, press)
    -- Toggle chatbox với F6
    if key == "F6" and press then
        chatVisible = not chatVisible
        addChatMessage(chatVisible and "📺 Custom chatbox enabled" or "📺 Custom chatbox disabled", 255, 255, 0)
        return
    end
end)

-- Nhận chat messages từ players khác
-- Intercept tin nhắn từ server
addEventHandler("onClientChatMessage", root, function(text, r, g, b)
    -- Chỉ hiển thị trong custom chatbox, KHÔNG log vào console để tránh duplicate
    addChatMessage(text, r, g, b)

    -- Block default chat display để tránh duplicate
    cancelEvent()
end)

-- Export functions
_G.addChatMessage = addChatMessage
_G.toggleCustomChatbox = function()
    chatVisible = not chatVisible
    return chatVisible
end

-- Command để toggle chatbox
addCommandHandler("togglechat", function()
    chatVisible = not chatVisible
    local status = chatVisible and "shown" or "hidden"
    addChatMessage("📺 Custom chatbox " .. status, 255, 255, 0)
    clientLog("CLIENNT", "📺 [CHATBOX] Toggled to: " .. status)
end)

-- Command để thay đổi kích thước font
addCommandHandler("chatfont", function(_, size)
    local newSize = tonumber(size)
    if newSize and newSize >= 0.5 and newSize <= 2.0 then
        chatFontSize = newSize
        addChatMessage("📝 Font size changed to " .. tostring(newSize), 255, 165, 0)
    else
        addChatMessage("❌ Invalid font size. Use 0.5 to 2.0", 255, 0, 0)
    end
end)

-- Cleanup khi resource stop
addEventHandler("onClientResourceStop", resourceRoot, function()
    if originalOutputChatBox then
        outputChatBox = originalOutputChatBox
    end
    removeEventHandler("onClientRender", root, drawCustomChatbox)

    -- Cleanup chat input GUI nếu đang active
    if chatInputActive then
        closeChatInput()
    end
end)

outputServerLog("[CHATBOX] Enhanced chatbox configuration loaded!")
