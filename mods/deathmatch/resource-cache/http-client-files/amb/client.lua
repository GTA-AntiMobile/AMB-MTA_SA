-- ================================================================
-- AMB MTA:SA - Login Client (Full UI: Login + Register)
-- ================================================================

local loginWindow, usernameEdit, passwordEdit, loginButton, registerButton = nil, nil, nil, nil, nil

-- Create login modal
function createSimpleLogin()
    if isElement(loginWindow) then
        outputDebugString("⚠️ [LOGIN] Window already exists, skipping creation")
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
    
    -- Auto-create login on client start
    addEventHandler("onClientResourceStart", resourceRoot, function()
        outputDebugString("=== CLIENT STARTED ===")
        setTimer(createSimpleLogin, 1000, 1)
    end)

    -- thêm handler phím Enter
    addEventHandler("onClientGUIAccepted", root, function(element)
        if element == usernameEdit or element == passwordEdit then
            onLoginButtonClick()
        end
    end)


    outputDebugString("✅ [LOGIN] Window created & cursor enabled")
end

-- Login attempt
function onLoginAttempt()
    if not isElement(loginWindow) then return end
    local username = guiGetText(usernameEdit)
    local password = guiGetText(passwordEdit)

    if username == "" or password == "" then
        outputChatBox("⚠️ Please enter username and password", 255, 0, 0)
        return
    end

    outputDebugString("🖱️ [LOGIN] Login attempt: " .. username)
    triggerServerEvent("onPlayerLoginRequest", localPlayer, username, password)
end

-- Register attempt
function onRegisterAttempt()
    if not isElement(loginWindow) then return end
    local username = guiGetText(usernameEdit)
    local password = guiGetText(passwordEdit)

    if username == "" or password == "" then
        outputChatBox("⚠️ Please enter username and password to register", 255, 0, 0)
        return
    end

    outputDebugString("🖱️ [LOGIN] Register attempt: " .. username)
    triggerServerEvent("onPlayerRegisterRequest", localPlayer, username, password)
end

-- Force close login window
function forceCloseLogin()
    if isElement(loginWindow) then
        destroyElement(loginWindow)
        loginWindow, usernameEdit, passwordEdit, loginButton, registerButton = nil, nil, nil, nil, nil
        showCursor(false)
        outputDebugString("🔒 [LOGIN] Window closed & cursor disabled")
    end
end

-- Server response
addEvent("onLoginResponse", true)
addEventHandler("onLoginResponse", root, function(success, message)
    outputDebugString("📩 [LOGIN] Response: " .. message)
    if success then
        forceCloseLogin()
        outputChatBox("🎉 " .. message, 0, 255, 0)
    else
        outputChatBox("⚠️ " .. message, 255, 0, 0)
    end
end)

addEvent("onRegisterResponse", true)
addEventHandler("onRegisterResponse", root, function(success, message)
    outputDebugString("📩 [REGISTER] Response: " .. message)
    if success then
        outputChatBox("✅ " .. message, 0, 255, 0)
    else
        outputChatBox("⚠️ " .. message, 255, 0, 0)
    end
end)

-- Auto-create on resource start
addEventHandler("onClientResourceStart", resourceRoot, function()
    outputDebugString("=== CLIENT STARTED ===")
    setTimer(createSimpleLogin, 1000, 1)
end)

addEvent("onClientLoadCustomSkin", true)
addEventHandler("onClientLoadCustomSkin", root, function(customSkinID)
    outputDebugString("[CLIENT] Loading custom skin ID " .. tostring(customSkinID))
    -- Tính baseSkinID từ customSkinID
    local baseSkinID = 0 + ((customSkinID - 20001) % 310)
    setElementModel(localPlayer, baseSkinID)
    -- Replace model bằng file custom
    local txd = engineLoadTXD("skins/" .. customSkinID .. ".txd")
    if txd then engineImportTXD(txd, baseSkinID) end
    local dff = engineLoadDFF("skins/" .. customSkinID .. ".dff", baseSkinID)
    if dff then engineReplaceModel(dff, baseSkinID) end
end)
