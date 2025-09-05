-- ================================
-- AMB MTA:SA - Client Event Handlers
-- Client-side listeners for server commands
-- ================================
-- Police speedcam client events
addEvent("onSpeedViolation", true)
addEventHandler("onSpeedViolation", root, function(speed, limit, cameraID)
    local x, y, z = getElementPosition(localPlayer)

    -- Flash effect for speed violation
    setWeather(19) -- Lightning effect
    setTimer(function()
        setWeather(0) -- Clear weather
    end, 1000, 1)

    -- Speed violation sound
    playSound("files/sounds/speedcam.mp3", false)

    -- Show speed violation message
    outputChatBox(string.format("⚡ SPEED CAMERA: %d km/h (Limit: %d)", speed, limit), 255, 100, 100)
end)

-- Police arrest client events
addEvent("onPlayerArrested", true)
addEventHandler("onPlayerArrested", root, function(officer, reason, time)
    -- Arrest screen effect
    setPlayerHudComponentVisible("all", false)

    -- Show arrest message
    local sx, sy = guiGetScreenSize()
    local arrestLabel = guiCreateLabel(sx / 2 - 200, sy / 2 - 50, 400, 100, string.format(
        "🚔 ARRESTED\nOfficer: %s\nReason: %s\nTime: %d minutes", officer, reason, time), false)
    guiSetFont(arrestLabel, "clear-normal")
    guiLabelSetHorizontalAlign(arrestLabel, "center")
    guiLabelSetVerticalAlign(arrestLabel, "center")

    -- Remove arrest message after 5 seconds
    setTimer(function()
        if isElement(arrestLabel) then
            destroyElement(arrestLabel)
        end
        setPlayerHudComponentVisible("all", true)
    end, 5000, 1)
end)

-- Tazer effect client events
addEvent("onPlayerTazed", true)
addEventHandler("onPlayerTazed", root, function()
    -- Tazer screen effect
    local sx, sy = guiGetScreenSize()
    local tazerEffect = guiCreateStaticImage(0, 0, sx, sy, "files/images/tazer_effect.png", false)

    -- Electric sound
    playSound("files/sounds/tazer.mp3", false)

    -- Remove effect after 2 seconds
    setTimer(function()
        if isElement(tazerEffect) then
            destroyElement(tazerEffect)
        end
    end, 2000, 1)
end)

-- Arrest command
local arrestWindow = nil
local arrestTimerLabel = nil
local arrestTimeRemaining = 0
local arrestTimer = nil

-- Handcuff animation
local function playHandcuffAnimation()
    local ped = getLocalPlayer()
    setPedAnimation(ped, "CRACK", "crckdeth2", -1, true, false, false, false)
end

-- Stop handcuff animation
local function stopHandcuffAnimation()
    local ped = getLocalPlayer()
    setPedAnimation(ped, false)
end

-- Countdown update
local function updateArrestTimer()
    if arrestTimeRemaining <= 0 then
        if isElement(arrestWindow) then
            destroyElement(arrestWindow)
            arrestWindow = nil
        end
        stopHandcuffAnimation()
        if isTimer(arrestTimer) then
            killTimer(arrestTimer)
        end
        return
    end
    local minutes = math.floor(arrestTimeRemaining / 60)
    local seconds = arrestTimeRemaining % 60
    if isElement(arrestTimerLabel) then
        guiSetText(arrestTimerLabel, string.format("⏱ Thời gian còn lại: %02d:%02d", minutes, seconds))
    end
    arrestTimeRemaining = arrestTimeRemaining - 1
end

-- Show Arrest UI
local function showArrestUI(officerName, jailTime)
    if isElement(arrestWindow) then
        destroyElement(arrestWindow)
    end

    local screenW, screenH = guiGetScreenSize()
    local w, h = 350, 150
    local x, y = (screenW - w) / 2, (screenH - h) / 2

    arrestWindow = guiCreateWindow(x, y, w, h, "🚔 Bị bắt giữ bởi " .. officerName, false)
    guiWindowSetSizable(arrestWindow, false)

    arrestTimerLabel = guiCreateLabel(20, 40, w - 40, 30, "", false, arrestWindow)
    guiLabelSetHorizontalAlign(arrestTimerLabel, "center", true)
    guiLabelSetColor(arrestTimerLabel, 255, 0, 0)

    local infoLabel = guiCreateLabel(20, 70, w - 40, 50,
        "Bạn đang bị giam giữ.\nKhông thể di chuyển hoặc thoát khỏi jail.", false, arrestWindow)
    guiLabelSetHorizontalAlign(infoLabel, "center", true)

    arrestTimeRemaining = jailTime * 60
    playHandcuffAnimation()

    arrestTimer = setTimer(updateArrestTimer, 1000, 0)
end

-- Event from server
addEvent("onPlayerArrested", true)
addEventHandler("onPlayerArrested", localPlayer, function(officerName, jailTime)
    showArrestUI(officerName, jailTime)
end)

-- Optional: disable movement while arrested
local arrested = false
addEventHandler("onClientRender", root, function()
    if arrestTimeRemaining > 0 then
        arrested = true
    else
        arrested = false
    end
    if arrested then
        toggleControl("fire", false)
        toggleControl("aim_weapon", false)
        toggleControl("accelerate", false)
        toggleControl("brake_reverse", false)
        toggleControl("jump", false)
        toggleControl("enter_exit", false)
    else
        toggleControl("fire", true)
        toggleControl("aim_weapon", true)
        toggleControl("accelerate", true)
        toggleControl("brake_reverse", true)
        toggleControl("jump", true)
        toggleControl("enter_exit", true)
    end
end)
