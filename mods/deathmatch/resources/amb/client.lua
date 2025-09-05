-- ================================================================
-- AMB MTA:SA - Login Client (Full UI: Login + Register)
-- ================================================================
local loginWindow, usernameEdit, passwordEdit, loginButton, registerButton = nil, nil, nil, nil, nil

-- Create login modal
function createSimpleLogin()
    if isElement(loginWindow) then
        clientLog("CLIENT", "⚠️ [LOGIN] Window already exists, skipping creation")
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

    -- Disable movement keys 
    bindKey("w", "down", function()
        cancelEvent()
    end) -- Block W
    bindKey("a", "down", function()
        cancelEvent()
    end) -- Block A  
    bindKey("s", "down", function()
        cancelEvent()
    end) -- Block S
    bindKey("d", "down", function()
        cancelEvent()
    end) -- Block D
    bindKey("space", "down", function()
        cancelEvent()
    end) -- Block SPACE
    bindKey("lshift", "down", function()
        cancelEvent()
    end) -- Block SHIFT
    bindKey("lctrl", "down", function()
        cancelEvent()
    end) -- Block CTRL
    bindKey("f1", "down", function()
        cancelEvent()
    end) -- Block F1
    bindKey("f2", "down", function()
        cancelEvent()
    end) -- Block F2
    bindKey("f3", "down", function()
        cancelEvent()
    end) -- Block F3
    bindKey("escape", "down", function()
        cancelEvent()
    end) -- Block ESC

    -- Global function to block TAB during login
    _G.blockTabDuringLogin = function(button, press)
        if press and button == "tab" and isElement(loginWindow) then
            cancelEvent()
        end
    end
    addEventHandler("onClientKey", root, _G.blockTabDuringLogin)

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

    clientLog("CLIENT", "✅ [LOGIN] Window created & cursor enabled, controls disabled")
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
        clientLog("CLIENT", "⚠️ [LOGIN] Empty username or password")
        return
    end

    clientLog("CLIENT", "🖱️ [LOGIN] Attempting login for: " .. username)
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

    clientLog("CLIENT", "🖱️ [REGISTER] Attempting registration for: " .. username)
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

        -- Unbind all the blocked keys
        unbindKey("w", "down")
        unbindKey("a", "down")
        unbindKey("s", "down")
        unbindKey("d", "down")
        unbindKey("space", "down")
        unbindKey("lshift", "down")
        unbindKey("lctrl", "down")
        unbindKey("f1", "down") -- Unbind F1
        unbindKey("f2", "down") -- Unbind F2
        unbindKey("f3", "down") -- Unbind F3
        unbindKey("escape", "down") -- Unbind ESC

        -- Remove the TAB blocking handler
        if _G.blockTabDuringLogin then
            removeEventHandler("onClientKey", root, _G.blockTabDuringLogin)
            _G.blockTabDuringLogin = nil
        end
        unbindKey("escape", "down") -- Unbind ESC

        clientLog("CLIENT", "🔒 [LOGIN] Window closed & cursor disabled, controls enabled")
    end
end

-- Client log function (send to server for file writing)
function clientLog(level, message)
    local rt = getRealTime()
    local timestamp = string.format("[%04d-%02d-%02d %02d:%02d:%02d]", rt.year + 1900, rt.month + 1, rt.monthday,
        rt.hour, rt.minute, rt.second)

    local logLine = string.format("%s %s: %s", timestamp, level, message)

    -- Send to server for file logging (MTA clients can't write files directly)
    triggerServerEvent("onClientLogMessage", localPlayer, logLine)
end

-- Server response
addEvent("onLoginResponse", true)
addEventHandler("onLoginResponse", root, function(success, message, accountData)
    if success and accountData then
        forceCloseLogin()
        triggerServerEvent("onPlayerSpawnRequest", localPlayer, accountData)
    else
        outputChatBox("⚠️ " .. message, 255, 0, 0)
    end
end)

addEvent("onRegisterResponse", true)
addEventHandler("onRegisterResponse", root, function(success, message)
    clientLog("CLIENT", "📩 [REGISTER] Response: " .. message)
    if success then
        outputChatBox("✅ " .. message, 0, 255, 0)
    else
        outputChatBox("⚠️ " .. message, 255, 0, 0)
    end
end)

-- Auto-create on resource start
addEventHandler("onClientResourceStart", resourceRoot, function()
    clientLog("CLIENT", "=== CLIENT STARTED ===")
    setTimer(createSimpleLogin, 1000, 1)
end)

addEventHandler("onResourceStart", resourceRoot, loadBanks)

addEvent("onAdminLevelChanged", true)
addEventHandler("onAdminLevelChanged", root, function(newLevel)
    local level = tonumber(newLevel) or 0
    outputChatBox("🚨 Admin level cua ban da duoc cap len: " .. level, 255, 200, 0)
    -- Cập nhật HUD / icon admin ở đây nếu có
    -- playSoundFrontEnd(44) -- ví dụ
end)
