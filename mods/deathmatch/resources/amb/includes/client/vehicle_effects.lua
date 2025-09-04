--[[
    CLIENT-SIDE COMMUNICATION EFFECTS
    
    Chức năng: Xử lý các hiệu ứng chat cho hệ thống giao tiếp mở rộng
    Bao gồm: 3D text, animations, sounds, GUI effects
]]

-- 3D Text system for chat
local activeChatTexts = {}
local chatAnimations = {}

-- Chat sound configuration
local CHAT_SOUNDS = {
    pm_receive = "sounds/pm_receive.mp3",
    pm_send = "sounds/pm_send.mp3", 
    radio_transmit = "sounds/radio_beep.mp3",
    whisper = "sounds/whisper.mp3",
    shout = "sounds/shout.mp3",
    megaphone = "sounds/megaphone.mp3"
}

-- Show 3D text above players for chat actions
addEvent("chat:show3DText", true)
addEventHandler("chat:show3DText", root, function(player, text, chatType, duration)
    if not isElement(player) or getElementType(player) ~= "player" then return end
    
    -- Remove existing text for this player
    if activeChatTexts[player] then
        destroyElement(activeChatTexts[player])
    end
    
    local x, y, z = getElementPosition(player)
    z = z + 1.0 -- Above player head
    
    -- Configure text appearance based on chat type
    local scale = 1.0
    local color = {255, 255, 255}
    
    if chatType == "me" then
        color = {194, 162, 218}
        scale = 0.8
    elseif chatType == "do" then
        color = {194, 162, 218}
        scale = 0.7
        text = "(" .. text .. ")"
    elseif chatType == "ame" then
        color = {255, 194, 162}
        scale = 1.0
    elseif chatType == "try" then
        color = {255, 255, 162}
        scale = 0.9
    elseif chatType == "whisper" then
        color = {100, 100, 255}
        scale = 0.6
    elseif chatType == "shout" then
        color = {255, 100, 100}
        scale = 1.2
    elseif chatType == "megaphone" then
        color = {255, 255, 0}
        scale = 1.5
    end
    
    -- Create 3D text
    local text3D = createText3D(text, x, y, z, color[1], color[2], color[3], scale)
    if text3D then
        activeChatTexts[player] = text3D
        
        -- Auto-destroy after duration
        setTimer(function()
            if isElement(text3D) then
                destroyElement(text3D)
            end
            activeChatTexts[player] = nil
        end, duration or 5000, 1)
        
        -- Attach to player if moving
        attachElements(text3D, player, 0, 0, 1.0)
    end
end)

-- Create 3D text element
function createText3D(text, x, y, z, r, g, b, scale)
    local textDisplay = createObject(1337, x, y, z) -- Invisible object
    if textDisplay then
        setElementAlpha(textDisplay, 0)
        setElementCollisionsEnabled(textDisplay, false)
        
        -- Create the actual text display using dxDraw in render event
        local textData = {
            text = text,
            r = r or 255,
            g = g or 255, 
            b = b or 255,
            scale = scale or 1.0,
            element = textDisplay
        }
        
        return textDisplay
    end
    return false
end

-- Trigger player animations based on chat content
addEvent("chat:triggerAnimation", true)
addEventHandler("chat:triggerAnimation", localPlayer, function(animType)
    if not animType then return end
    
    -- Stop current animation
    setPedAnimation(localPlayer)
    
    -- Apply new animation
    if animType == "talking" then
        setPedAnimation(localPlayer, "PED", "IDLE_CHAT", 3000, true, false, false)
    elseif animType == "drinking" then
        setPedAnimation(localPlayer, "BAR", "dnk_stndM_loop", 3000, true, false, false)
    elseif animType == "smoking" then
        setPedAnimation(localPlayer, "SMOKING", "M_smklean_loop", 5000, true, false, false)
    elseif animType == "phone" then
        setPedAnimation(localPlayer, "PED", "phone_talk", 3000, true, false, false)
    end
    
    -- Store animation info
    chatAnimations[localPlayer] = {
        type = animType,
        startTime = getTickCount()
    }
end)

-- Distance-based chat effect (voice fading)
addEvent("chat:distanceEffect", true)
addEventHandler("chat:distanceEffect", localPlayer, function(fadeRatio)
    if not fadeRatio then return end
    
    -- Create audio fade effect
    local volume = 1.0 - (fadeRatio * 0.7) -- Don't fade completely
    setSoundVolume(localPlayer, volume)
    
    -- Visual fade effect for UI
    local alpha = math.floor(255 * (1 - fadeRatio * 0.5))
    triggerEvent("hud:setChatAlpha", localPlayer, alpha)
end)

-- Show game text for try command results
addEvent("chat:showGameText", true)
addEventHandler("chat:showGameText", localPlayer, function(text, duration)
    if not text then return end
    
    -- Remove color codes for game text
    local cleanText = string.gsub(text, "~%w~", "")
    
    -- Show in center of screen
    local screenW, screenH = guiGetScreenSize()
    local textWidth = dxGetTextWidth(cleanText, 2.0, "default-bold")
    local x = (screenW - textWidth) / 2
    local y = screenH * 0.3
    
    -- Color based on result
    local r, g, b = 255, 255, 255
    if string.find(string.upper(text), "THÀNH CÔNG") then
        r, g, b = 100, 255, 100
    elseif string.find(string.upper(text), "THẤT BẠI") then
        r, g, b = 255, 100, 100
    end
    
    -- Display text with fade effect
    local startTime = getTickCount()
    local function renderGameText()
        local elapsed = getTickCount() - startTime
        local alpha = 255
        
        if elapsed > (duration - 1000) then
            alpha = 255 * ((duration - elapsed) / 1000)
        end
        
        if elapsed < duration and alpha > 0 then
            dxDrawText(cleanText, x, y, x, y, tocolor(r, g, b, alpha), 2.0, "default-bold", "left", "top", false, false, false, true)
        else
            removeEventHandler("onClientRender", root, renderGameText)
        end
    end
    
    addEventHandler("onClientRender", root, renderGameText)
end)

-- Shout effect with screen shake
addEvent("chat:shoutEffect", true)  
addEventHandler("chat:shoutEffect", localPlayer, function(shouter)
    if not isElement(shouter) then return end
    
    -- Get distance from shouter
    local px, py, pz = getElementPosition(localPlayer)
    local sx, sy, sz = getElementPosition(shouter)
    local distance = getDistanceBetweenPoints3D(px, py, pz, sx, sy, sz)
    
    if distance <= 30.0 then
        -- Screen shake intensity based on distance
        local intensity = (30.0 - distance) / 30.0
        triggerEvent("camera:shake", localPlayer, intensity * 0.5, 500)
        
        -- Play shout sound
        if fileExists(CHAT_SOUNDS.shout) then
            local sound = playSound(CHAT_SOUNDS.shout)
            setSoundVolume(sound, intensity * 0.8)
        end
    end
end)

-- Whisper effect with audio filter
addEvent("chat:whisperEffect", true)
addEventHandler("chat:whisperEffect", localPlayer, function(whisperer)
    if not isElement(whisperer) then return end
    
    -- Play whisper sound
    if fileExists(CHAT_SOUNDS.whisper) then
        local sound = playSound(CHAT_SOUNDS.whisper)
        setSoundVolume(sound, 0.3)
    end
    
    -- Create subtle visual effect
    local fx = createEffect("spark_shower", getElementPosition(whisperer))
    setTimer(destroyElement, 1000, 1, fx)
end)

-- PM notification system
addEvent("chat:playPMSound", true)
addEventHandler("chat:playPMSound", localPlayer, function(soundType)
    local soundFile = soundType == "receive" and CHAT_SOUNDS.pm_receive or CHAT_SOUNDS.pm_send
    
    if fileExists(soundFile) then
        local sound = playSound(soundFile)
        setSoundVolume(sound, 0.6)
    end
    
    -- Show notification popup
    if soundType == "receive" then
        triggerEvent("hud:showNotification", localPlayer, "Tin nhắn mới!", "Bạn có tin nhắn riêng mới", 3000)
    end
end)

-- Radio effects
addEvent("chat:radioEffect", true)
addEventHandler("chat:radioEffect", localPlayer, function(senderName)
    if not senderName then return end
    
    -- Radio static effect
    if fileExists(CHAT_SOUNDS.radio_transmit) then
        local sound = playSound(CHAT_SOUNDS.radio_transmit)
        setSoundVolume(sound, 0.4)
    end
    
    -- Show radio indicator
    triggerEvent("hud:showRadioIndicator", localPlayer, senderName, 2000)
end)

addEvent("chat:playRadioSound", true)
addEventHandler("chat:playRadioSound", localPlayer, function(soundType)
    if soundType == "transmit" and fileExists(CHAT_SOUNDS.radio_transmit) then
        local sound = playSound(CHAT_SOUNDS.radio_transmit)
        setSoundVolume(sound, 0.5)
    end
end)

-- Megaphone effects
addEvent("chat:megaphoneEffect", true)
addEventHandler("chat:megaphoneEffect", localPlayer, function(speaker, message)
    if not isElement(speaker) or not message then return end
    
    -- Megaphone sound
    if fileExists(CHAT_SOUNDS.megaphone) then
        local sound = playSound(CHAT_SOUNDS.megaphone)
        setSoundVolume(sound, 0.8)
    end
    
    -- Large 3D text effect
    triggerEvent("chat:show3DText", localPlayer, speaker, message, "megaphone", 5000)
    
    -- Echo effect for nearby players
    local px, py, pz = getElementPosition(localPlayer)
    local sx, sy, sz = getElementPosition(speaker)
    local distance = getDistanceBetweenPoints3D(px, py, pz, sx, sy, sz)
    
    if distance <= 50.0 then
        -- Create echo effect
        setTimer(function()
            if fileExists(CHAT_SOUNDS.megaphone) then
                local echoSound = playSound(CHAT_SOUNDS.megaphone)
                setSoundVolume(echoSound, 0.2)
            end
        end, 500, 1)
    end
end)

-- Camera shake effect
addEvent("camera:shake", true)
addEventHandler("camera:shake", localPlayer, function(intensity, duration)
    if not intensity or not duration then return end
    
    local camera = getCamera()
    local startTime = getTickCount()
    
    local function shakeCamera()
        local elapsed = getTickCount() - startTime
        if elapsed < duration then
            local shakeX = math.random(-intensity, intensity)
            local shakeY = math.random(-intensity, intensity)
            
            setCameraShakeLevel(intensity * 100)
        else
            setCameraShakeLevel(0)
            removeEventHandler("onClientRender", root, shakeCamera)
        end
    end
    
    addEventHandler("onClientRender", root, shakeCamera)
end)

-- HUD Integration events
addEvent("hud:setChatAlpha", true)
addEvent("hud:showNotification", true)  
addEvent("hud:showRadioIndicator", true)

-- Cleanup on resource stop
addEventHandler("onClientResourceStop", resourceRoot, function()
    -- Clean up active 3D texts
    for player, text3D in pairs(activeChatTexts) do
        if isElement(text3D) then
            destroyElement(text3D)
        end
    end
    activeChatTexts = {}
    
    -- Stop animations
    for player, anim in pairs(chatAnimations) do
        if isElement(player) then
            setPedAnimation(player)
        end
    end
    chatAnimations = {}
end)

outputDebugString("Communication Effects Client-Side loaded successfully!")
