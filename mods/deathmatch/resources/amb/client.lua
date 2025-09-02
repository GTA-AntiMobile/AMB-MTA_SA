-- ================================================================
-- AMB MTA:SA - Login Client (Full UI: Login + Register)
-- ================================================================
local loginWindow, usernameEdit, passwordEdit, loginButton, registerButton = nil, nil, nil, nil, nil

-- Create login modal
function createSimpleLogin()
    if isElement(loginWindow) then
        clientLog("CLIENNT", "⚠️ [LOGIN] Window already exists, skipping creation")
        return
    end

    local sw, sh = guiGetScreenSize()
    loginWindow = guiCreateWindow((sw - 350) / 2, (sh - 240) / 2, 350, 240, "AMB Roleplay - Login", false)
    guiWindowSetSizable(loginWindow, false)

    guiCreateLabel(40, 50, 90, 25, "Username:", false, loginWindow)
    usernameEdit = guiCreateEdit(140, 50, 170, 25, "", false, loginWindow)

    guiCreateLabel(40, 100, 90, 25, "Password:", false, loginWindow)
    passwordEdit = guiCreateEdit(140, 100, 170, 25, "", false, loginWindow)
    guiEditSetMasked(passwordEdit, true)

    loginButton = guiCreateButton(70, 160, 90, 35, "Login", false, loginWindow)
    registerButton = guiCreateButton(190, 160, 90, 35, "Register", false, loginWindow)

    showCursor(true)
    
    -- Disable ALL player controls during login
    toggleAllControls(false, true, false) -- (enabled, gtaControls, mtaControls)
    setElementFrozen(localPlayer, true)
    
    -- Disable movement keys but NOT TAB (let scoreboard work normally)
    bindKey("w", "down", function() cancelEvent() end) -- Block W
    bindKey("a", "down", function() cancelEvent() end) -- Block A  
    bindKey("s", "down", function() cancelEvent() end) -- Block S
    bindKey("d", "down", function() cancelEvent() end) -- Block D
    bindKey("space", "down", function() cancelEvent() end) -- Block SPACE
    bindKey("lshift", "down", function() cancelEvent() end) -- Block SHIFT
    bindKey("lctrl", "down", function() cancelEvent() end) -- Block CTRL
    -- Don't block TAB - let scoreboard work normally

    -- Event handlers
    addEventHandler("onClientGUIClick", loginButton, onLoginAttempt, false)
    addEventHandler("onClientGUIClick", registerButton, onRegisterAttempt, false)

    -- Enter support
    addEventHandler("onClientGUIAccepted", passwordEdit, onLoginAttempt, false) -- enter khi trong password
    addEventHandler("onClientKey", root, function(button, press)
        if press and button == "enter" and isElement(loginWindow) then
            onLoginAttempt()
            cancelEvent()
        end
    end)

    clientLog("CLIENNT", "✅ [LOGIN] Window created & cursor enabled, controls disabled")
end

-- Login attempt
function onLoginAttempt()
    if not isElement(loginWindow) then
        return
    end
    local username = guiGetText(usernameEdit)
    local password = guiGetText(passwordEdit)

    if username == "" or password == "" then
        outputChatBox("⚠️ Please enter username and password", 255, 0, 0)
        clientLog("CLIENNT", "⚠️ [LOGIN] Empty username or password")
        return
    end

    clientLog("CLIENNT", "🖱️ [LOGIN] Attempting login for: " .. username)
    triggerServerEvent("onPlayerLoginRequest", localPlayer, username, password)
end

-- Register attempt
function onRegisterAttempt()
    if not isElement(loginWindow) then
        return
    end
    local username = guiGetText(usernameEdit)
    local password = guiGetText(passwordEdit)

    if username == "" or password == "" then
        outputChatBox("⚠️ Please enter username and password to register", 255, 0, 0)
        return
    end

    clientLog("CLIENNT", "🖱️ [REGISTER] Attempting registration for: " .. username)
    triggerServerEvent("onPlayerRegisterRequest", localPlayer, username, password)
end

-- Force close login window
function forceCloseLogin()
    if isElement(loginWindow) then
        destroyElement(loginWindow)
        loginWindow, usernameEdit, passwordEdit, loginButton, registerButton = nil, nil, nil, nil, nil
        showCursor(false)
        
        -- Re-enable player controls after login
        toggleAllControls(true, true, true) -- (enabled, gtaControls, mtaControls)
        setElementFrozen(localPlayer, false)
        
        -- Unbind the blocked keys (but not TAB)
        unbindKey("w", "down")
        unbindKey("a", "down")
        unbindKey("s", "down") 
        unbindKey("d", "down")
        unbindKey("space", "down")
        unbindKey("lshift", "down")
        unbindKey("lctrl", "down")
        -- Don't unbind TAB since we didn't bind it
        
        clientLog("CLIENNT", "🔒 [LOGIN] Window closed & cursor disabled, controls enabled")
    end
end

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

-- Server response
addEvent("onLoginResponse", true)
addEventHandler("onLoginResponse", root, function(success, message)
    clientLog("CLIENNT", "📩 [LOGIN] Response: " .. message)
    if success then
        forceCloseLogin()
        -- Don't show message here - server already sends welcome message separately
    else
        outputChatBox("⚠️ " .. message, 255, 0, 0)
    end
end)

addEvent("onRegisterResponse", true)
addEventHandler("onRegisterResponse", root, function(success, message)
    clientLog("CLIENNT", "📩 [REGISTER] Response: " .. message)
    if success then
        outputChatBox("✅ " .. message, 0, 255, 0)
    else
        outputChatBox("⚠️ " .. message, 255, 0, 0)
    end
end)

-- Auto-create on resource start
addEventHandler("onClientResourceStart", resourceRoot, function()
    clientLog("CLIENNT", "=== CLIENT STARTED ===")
    setTimer(createSimpleLogin, 1000, 1)
end)

addEvent("onClientLoadCustomSkin", true)
addEventHandler("onClientLoadCustomSkin", root, function(customSkinID)
    clientLog("CLIENNT", "🎨 [SKIN] Loading custom skin ID " .. tostring(customSkinID))
    -- Tính baseSkinID từ customSkinID
    local baseSkinID = 0 + ((customSkinID - 20001) % 310)
    setElementModel(localPlayer, baseSkinID)
    -- Replace model bằng file custom
    local txd = engineLoadTXD("skins/" .. customSkinID .. ".txd")
    if txd then
        engineImportTXD(txd, baseSkinID)
    end
    local dff = engineLoadDFF("skins/" .. customSkinID .. ".dff", baseSkinID)
    if dff then
        engineReplaceModel(dff, baseSkinID)
    end
end)
