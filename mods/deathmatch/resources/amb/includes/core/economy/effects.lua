--[[
    BANKING & ECONOMY CLIENT EFFECTS
    
    Xử lý hiệu ứng client-side cho banking system
]] -- Money display
local moneyDisplay = {
    money = 0,
    bank = 0,
    showAnimation = false,
    animationTimer = nil
}

-- Update money display
addEvent("economy:updateMoney", true)
addEventHandler("economy:updateMoney", getRootElement(), function(amount)
    moneyDisplay.money = amount
    moneyDisplay.showAnimation = true

    if moneyDisplay.animationTimer then
        killTimer(moneyDisplay.animationTimer)
    end

    moneyDisplay.animationTimer = setTimer(function()
        moneyDisplay.showAnimation = false
    end, 3000, 1)
end)

-- Update bank display
addEvent("economy:updateBank", true)
addEventHandler("economy:updateBank", getRootElement(), function(amount)
    moneyDisplay.bank = amount
end)

-- Draw money HUD
addEventHandler("onClientRender", getRootElement(), function()
    local screenW, screenH = guiGetScreenSize()

    -- Draw money
    if moneyDisplay.money > 0 or moneyDisplay.showAnimation then
        local text = "$" .. formatMoney(moneyDisplay.money)
        local color = moneyDisplay.showAnimation and {100, 255, 100, 255} or {255, 255, 255, 200}
        dxDrawText(text, screenW - 200, 50, screenW - 20, 70, tocolor(color[1], color[2], color[3], color[4]), 1.2,
            "default-bold", "right", "center")
    end
end)

-- Banking transaction sounds
addEvent("bank:playTransaction", true)
addEventHandler("bank:playTransaction", getRootElement(), function(transactionType)
    if transactionType == "withdraw" then
        local sound = playSound("files/sounds/economy/cash_register.mp3")
        if sound then
            setSoundVolume(sound, 0.5)
        end

    elseif transactionType == "deposit" then
        local sound = playSound("files/sounds/economy/money_count.mp3")
        if sound then
            setSoundVolume(sound, 0.4)
        end
    end
end)

-- ATM sounds
addEvent("atm:playSound", true)
addEventHandler("atm:playSound", getRootElement(), function(soundType)
    if soundType == "balance" then
        local sound = playSound("files/sounds/economy/atm_beep.mp3")
        if sound then
            setSoundVolume(sound, 0.6)
        end
    end
end)

-- Payment animation
addEvent("economy:payAnimation", true)
addEventHandler("economy:payAnimation", getRootElement(), function(payer, receiver, amount)
    local localPlayer = getLocalPlayer()

    if payer == localPlayer or receiver == localPlayer then
        -- Create floating text
        local x, y, z = getElementPosition(payer)
        local text = "$" .. formatMoney(amount)

        -- Money transfer effect
        local startTime = getTickCount()
        local duration = 2000

        local function drawPaymentEffect()
            local now = getTickCount()
            local elapsed = now - startTime
            local progress = elapsed / duration

            if progress >= 1.0 then
                removeEventHandler("onClientRender", getRootElement(), drawPaymentEffect)
                return
            end

            local alpha = math.floor(255 * (1 - progress))
            local offsetY = progress * 50

            local screenX, screenY = getScreenFromWorldPosition(x, y, z + 1 + offsetY)
            if screenX and screenY then
                dxDrawText(text, screenX - 50, screenY - 10, screenX + 50, screenY + 10, tocolor(100, 255, 100, alpha),
                    1.5, "default-bold", "center", "center")
            end
        end

        addEventHandler("onClientRender", getRootElement(), drawPaymentEffect)

        -- Play sound
        local sound = playSound("files/sounds/economy/cash_exchange.mp3")
        if sound then
            setSoundVolume(sound, 0.7)
        end
    end
end)

-- Payday notification
addEvent("economy:paydayReceived", true)
addEventHandler("economy:paydayReceived", getRootElement(), function(amount)
    local screenW, screenH = guiGetScreenSize()

    -- Create payday notification
    local startTime = getTickCount()
    local duration = 5000

    local function drawPaydayNotification()
        local now = getTickCount()
        local elapsed = now - startTime
        local progress = elapsed / duration

        if progress >= 1.0 then
            removeEventHandler("onClientRender", getRootElement(), drawPaydayNotification)
            return
        end

        local alpha = 255
        if progress > 0.8 then
            alpha = math.floor(255 * (1 - (progress - 0.8) / 0.2))
        end

        local y = screenH * 0.3

        dxDrawText("PAYDAY!", 0, y - 30, screenW, y, tocolor(255, 255, 100, alpha), 2.0, "default-bold", "center",
            "center")
        dxDrawText("Bạn đã nhận $" .. formatMoney(amount), 0, y + 10, screenW, y + 30,
            tocolor(100, 255, 100, alpha), 1.5, "default-bold", "center", "center")
    end

    addEventHandler("onClientRender", getRootElement(), drawPaydayNotification)

    -- Play payday sound
    local sound = playSound("files/sounds/economy/payday.mp3")
    if sound then
        setSoundVolume(sound, 0.8)
    end
end)

-- ATM GUI
local atmGUI = {
    window = nil,
    visible = false
}

-- Show ATM interface
addEvent("atm:showInterface", true)
addEventHandler("atm:showInterface", getRootElement(), function()
    if atmGUI.visible then
        return
    end

    local screenW, screenH = guiGetScreenSize()
    local width, height = 400, 300
    local x = (screenW - width) / 2
    local y = (screenH - height) / 2

    atmGUI.window = guiCreateWindow(x, y, width, height, "ATM - Máy Rút Tiền Tự Động", false)
    guiWindowSetSizable(atmGUI.window, false)

    local balanceBtn = guiCreateButton(50, 50, 300, 40, "Kiểm Tra Số Dư", false, atmGUI.window)
    local withdrawBtn = guiCreateButton(50, 100, 300, 40, "Rút Tiền", false, atmGUI.window)
    local depositBtn = guiCreateButton(50, 150, 300, 40, "Gửi Tiền", false, atmGUI.window)
    local closeBtn = guiCreateButton(50, 200, 300, 40, "Đóng", false, atmGUI.window)

    addEventHandler("onClientGUIClick", balanceBtn, function()
        executeCommandHandler("atmbalance")
    end, false)

    addEventHandler("onClientGUIClick", withdrawBtn, function()
        local amount = inputBox("Nhập số tiền muốn rút:", "0")
        if amount and tonumber(amount) then
            executeCommandHandler("atmwithdraw", amount)
        end
    end, false)

    addEventHandler("onClientGUIClick", depositBtn, function()
        local amount = inputBox("Nhập số tiền muốn gửi:", "0")
        if amount and tonumber(amount) then
            executeCommandHandler("atmdeposit", amount)
        end
    end, false)

    addEventHandler("onClientGUIClick", closeBtn, function()
        hideATMInterface()
    end, false)

    atmGUI.visible = true
    showCursor(true)
end)

-- Hide ATM interface
function hideATMInterface()
    if atmGUI.window then
        destroyElement(atmGUI.window)
        atmGUI.window = nil
    end
    atmGUI.visible = false
    showCursor(false)
end

-- Simple input box function
function inputBox(text, defaultValue)
    -- This would normally be a proper GUI dialog
    -- For now, we'll use a placeholder
    return defaultValue
end

-- Bank marker effects
addEventHandler("onClientMarkerHit", getRootElement(), function(hitPlayer, matchingDimension)
    if hitPlayer == getLocalPlayer() and matchingDimension then
        local markerType = getElementData(source, "type")

        if markerType == "bank" then
            outputChatBox("Bạn đã vào ngân hàng! Sử dụng /withdraw, /deposit, /balance", 100, 255, 100)

        elseif markerType == "atm" then
            outputChatBox("ATM - Sử dụng /atm để xem menu", 100, 255, 100)
            triggerEvent("atm:showInterface", getLocalPlayer())
        end
    end
end)

-- Money pickup effects
addEventHandler("onClientPickupHit", getRootElement(), function(hitPlayer, matchingDimension)
    if hitPlayer == getLocalPlayer() and matchingDimension then
        local pickupType = getElementData(source, "type")

        if pickupType == "money" then
            local amount = getElementData(source, "amount") or 0

            -- Money pickup animation
            local x, y, z = getElementPosition(source)
            local startTime = getTickCount()
            local duration = 1500

            local function drawPickupEffect()
                local now = getTickCount()
                local elapsed = now - startTime
                local progress = elapsed / duration

                if progress >= 1.0 then
                    removeEventHandler("onClientRender", getRootElement(), drawPickupEffect)
                    return
                end

                local alpha = math.floor(255 * (1 - progress))
                local offsetY = progress * 30

                local screenX, screenY = getScreenFromWorldPosition(x, y, z + offsetY)
                if screenX and screenY then
                    dxDrawText("+$" .. formatMoney(amount), screenX - 50, screenY - 10, screenX + 50, screenY + 10,
                        tocolor(100, 255, 100, alpha), 1.2, "default-bold", "center", "center")
                end
            end

            addEventHandler("onClientRender", getRootElement(), drawPickupEffect)

            -- Play pickup sound
            local sound = playSound("files/sounds/economy/money_pickup.mp3")
            if sound then
                setSoundVolume(sound, 0.6)
            end
        end
    end
end)

outputDebugString("Banking & Economy Client Effects loaded successfully!")
