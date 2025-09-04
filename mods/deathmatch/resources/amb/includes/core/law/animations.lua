--[[
    LAW ENFORCEMENT CLIENT ANIMATIONS
    
    Xử lý animations và effects cho law enforcement system
]]

-- Animation IDs
local ANIM_HANDSUP = "ped"
local ANIM_HANDSUP_NAME = "handsup"
local ANIM_CUFFED = "ped"
local ANIM_CUFFED_NAME = "cower"

-- Set hands up animation
addEvent("law:setHandsUpAnimation", true)
addEventHandler("law:setHandsUpAnimation", getRootElement(), function(player)
    if player and isElement(player) then
        setPedAnimation(player, ANIM_HANDSUP, ANIM_HANDSUP_NAME, -1, true, false, false)
    end
end)

-- Remove hands up animation
addEvent("law:removeHandsUpAnimation", true)
addEventHandler("law:removeHandsUpAnimation", getRootElement(), function(player)
    if player and isElement(player) then
        setPedAnimation(player, false)
    end
end)

-- Set cuffed animation
addEvent("law:setCuffAnimation", true)
addEventHandler("law:setCuffAnimation", getRootElement(), function(player)
    if player and isElement(player) then
        setPedAnimation(player, ANIM_CUFFED, ANIM_CUFFED_NAME, -1, true, false, false)
    end
end)

-- Remove cuffed animation
addEvent("law:removeCuffAnimation", true)
addEventHandler("law:removeCuffAnimation", getRootElement(), function(player)
    if player and isElement(player) then
        setPedAnimation(player, false)
    end
end)

-- Disable controls for cuffed players
addEventHandler("onClientRender", getRootElement(), function()
    local player = getLocalPlayer()
    if player then
        local isCuffed = getElementData(player, "cuffed")
        if isCuffed then
            -- Disable movement controls
            setControlState(player, "forwards", false)
            setControlState(player, "backwards", false)
            setControlState(player, "left", false)
            setControlState(player, "right", false)
            setControlState(player, "jump", false)
            setControlState(player, "sprint", false)
            setControlState(player, "fire", false)
            setControlState(player, "action", false)
        end
    end
end)

-- Show cuffed status
addEventHandler("onClientRender", getRootElement(), function()
    local player = getLocalPlayer()
    if player then
        local isCuffed = getElementData(player, "cuffed")
        if isCuffed then
            local screenW, screenH = guiGetScreenSize()
            local text = "Bạn đã bị còng tay!"
            dxDrawText(text, 0, screenH - 100, screenW, screenH - 80, tocolor(255, 100, 100, 255), 1.5, "default-bold", "center", "center")
        end
        
        local isJailed = getElementData(player, "jailed")
        if isJailed then
            local jailTime = getElementData(player, "jailTime") or 0
            local minutes = math.floor(jailTime / 60)
            local seconds = jailTime % 60
            
            local screenW, screenH = guiGetScreenSize()
            local text = string.format("Thời gian còn lại: %02d:%02d", minutes, seconds)
            dxDrawText(text, 0, 50, screenW, 70, tocolor(255, 100, 100, 255), 1.5, "default-bold", "center", "center")
        end
    end
end)

outputDebugString("Law Enforcement Client Animations loaded successfully!")
