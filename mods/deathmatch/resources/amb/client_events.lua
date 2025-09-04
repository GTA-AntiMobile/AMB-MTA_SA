-- Vehicle engine client events
addEvent("onVehicleEngineChange", true)
addEventHandler("onVehicleEngineChange", root, function(vehicle, state)
    if vehicle and isElement(vehicle) then
        if state then
            -- Engine start sound
            local sound = playSound3D("files/sounds/engine_start.mp3", getElementPosition(vehicle))
            if sound then
                setSoundMaxDistance(sound, 30)
            end
        else
            -- Engine stop sound
            local sound = playSound3D("files/sounds/engine_stop.mp3", getElementPosition(vehicle))
            if sound then
                setSoundMaxDistance(sound, 20)
            end
        end
    end
end)

-- Business transaction client events
addEvent("onBusinessTransaction", true)
addEventHandler("onBusinessTransaction", root, function(amount, type)
    if type == "deposit" then
        outputChatBox(string.format("💰 Deposited $%d to business vault", amount), 0, 255, 0)
    elseif type == "withdraw" then
        outputChatBox(string.format("💰 Withdrew $%d from business vault", amount), 255, 255, 100)
    end

    -- Money transaction sound
    playSound("files/sounds/money.mp3", false)
end)

-- Animation sync client events
addEvent("onPlayerAnimation", true)
addEventHandler("onPlayerAnimation", root, function(player, block, anim, time, loop, updatePosition, interruptable)
    if player and isElement(player) then
        setPedAnimation(player, block, anim, time, loop, updatePosition, interruptable)
    end
end)

-- Vehicle lock client events
addEvent("onVehicleLockChange", true)
addEventHandler("onVehicleLockChange", root, function(vehicle, locked)
    if vehicle and isElement(vehicle) then
        -- Lock/unlock sound
        local sound = playSound3D(locked and "files/sounds/car_lock.mp3" or "files/sounds/car_unlock.mp3",
            getElementPosition(vehicle))
        if sound then
            setSoundMaxDistance(sound, 10)
        end

        -- Visual feedback
        if getElementData(vehicle, "owner") == getPlayerName(localPlayer) then
            outputChatBox(locked and "🔒 Vehicle locked" or "🔓 Vehicle unlocked", 255, 255, 100)
        end
    end
end)

-- Phone call client events
addEvent("onPhoneCall", true)
addEventHandler("onPhoneCall", root, function(caller, ringing)
    if ringing then
        -- Phone ring sound
        local ringSound = playSound("files/sounds/phone_ring.mp3", true) -- Loop
        setElementData(localPlayer, "phoneRingSound", ringSound)

        -- Show incoming call GUI
        local sx, sy = guiGetScreenSize()
        local callWindow = guiCreateWindow(sx / 2 - 150, sy / 2 - 100, 300, 200, "Incoming Call", false)
        guiWindowSetSizable(callWindow, false)

        local callerLabel = guiCreateLabel(10, 30, 280, 30, "Caller: " .. caller, false, callWindow)
        guiSetFont(callerLabel, "clear-normal")
        guiLabelSetHorizontalAlign(callerLabel, "center")

        local acceptBtn = guiCreateButton(10, 80, 130, 30, "Accept", false, callWindow)
        local rejectBtn = guiCreateButton(160, 80, 130, 30, "Reject", false, callWindow)

        setElementData(localPlayer, "phoneCallWindow", callWindow)

        addEventHandler("onClientGUIClick", acceptBtn, function()
            triggerServerEvent("onPlayerAcceptCall", localPlayer, caller)
            destroyElement(callWindow)
            if ringSound and isElement(ringSound) then
                destroyElement(ringSound)
            end
        end, false)

        addEventHandler("onClientGUIClick", rejectBtn, function()
            triggerServerEvent("onPlayerRejectCall", localPlayer, caller)
            destroyElement(callWindow)
            if ringSound and isElement(ringSound) then
                destroyElement(ringSound)
            end
        end, false)
    else
        -- Stop ringing
        local ringSound = getElementData(localPlayer, "phoneRingSound")
        if ringSound and isElement(ringSound) then
            destroyElement(ringSound)
        end

        local callWindow = getElementData(localPlayer, "phoneCallWindow")
        if callWindow and isElement(callWindow) then
            destroyElement(callWindow)
        end
    end
end)

-- Gas station client events
addEvent("onPlayerFillGas", true)
addEventHandler("onPlayerFillGas", root, function()
    -- Gas filling sound
    playSound("files/sounds/gas_fill.mp3", false)

    -- Show filling progress (simple simulation)
    outputChatBox("⛽ Filling gas...", 255, 255, 100)

    local progress = 0
    local fillTimer = setTimer(function()
        progress = progress + 20
        outputChatBox(string.format("⛽ Filling... %d%%", progress), 255, 255, 100)

        if progress >= 100 then
            outputChatBox("⛽ Tank full!", 0, 255, 0)
            killTimer(source)
        end
    end, 500, 5)
end)

-- Stop animation client event
addEvent("player:stopAnimation", true)
addEventHandler("player:stopAnimation", localPlayer, function(player)
    if not isElement(player) then
        return
    end

    -- Dừng animation của player
    setPedAnimation(player, false)

    -- Nếu bạn có UI hoặc hiệu ứng client-side khác, có thể reset ở đây
    -- Ví dụ: clear custom animation markers
    -- clearCustomAnimationEffects(player)
end)
