-- ================================
-- AMB MTA:SA - Player Animlist System
-- Animation commands and management
-- ================================

-- Animation categories and data
local animationCategories = {
    ["dance"] = {
        {name = "dance1", dict = "DANCING", anim = "dance_loop", time = -1},
        {name = "dance2", dict = "DANCING", anim = "DAN_Down_A", time = -1},
        {name = "dance3", dict = "DANCING", anim = "DAN_Left_A", time = -1},
        {name = "dance4", dict = "DANCING", anim = "DAN_Right_A", time = -1}
    },
    ["greeting"] = {
        {name = "wave", dict = "ON_LOOKERS", anim = "wave_loop", time = 3000},
        {name = "salute", dict = "POLICE", anim = "CopTraf_Come", time = 3000},
        {name = "bow", dict = "CASINO", anim = "cards_pick_01", time = 3000}
    },
    ["emotions"] = {
        {name = "cry", dict = "GRAVEYARD", anim = "mrnF_loop", time = 5000},
        {name = "laugh", dict = "RAPPING", anim = "Laugh_01", time = 3000},
        {name = "taunt", dict = "GANGS", anim = "prtial_gngtlkD", time = 3000}
    },
    ["actions"] = {
        {name = "smoke", dict = "SMOKING", anim = "M_smklean_loop", time = -1},
        {name = "drink", dict = "BAR", anim = "dnk_stndM_loop", time = 5000},
        {name = "sit", dict = "BEACH", anim = "bather", time = -1},
        {name = "lay", dict = "BEACH", anim = "Lay_Bac_Loop", time = -1}
    }
}

-- Main animation command
addCommandHandler("anim", function(player, _, category, animName)
    if not category then
        outputChatBox("=== ANIMATION SYSTEM ===", player, 255, 255, 0)
        outputChatBox("Categories: dance, greeting, emotions, actions", player, 255, 255, 255)
        outputChatBox("Usage: /anim [category] [animation_name]", player, 255, 255, 255)
        outputChatBox("Use /animlist [category] to see available animations", player, 255, 255, 255)
        outputChatBox("Use /stopanim to stop current animation", player, 255, 255, 255)
        return
    end
    
    if not animationCategories[category] then
        outputChatBox("Invalid category! Available: dance, greeting, emotions, actions", player, 255, 0, 0)
        return
    end
    
    if not animName then
        outputChatBox("Please specify animation name. Use /animlist " .. category, player, 255, 255, 255)
        return
    end
    
    -- Find animation
    local animData = nil
    for _, anim in ipairs(animationCategories[category]) do
        if anim.name == animName then
            animData = anim
            break
        end
    end
    
    if not animData then
        outputChatBox("Animation not found! Use /animlist " .. category, player, 255, 0, 0)
        return
    end
    
    -- Play animation
    setPedAnimation(player, animData.dict, animData.anim, animData.time, true, true, true)
    setElementData(player, "currentAnimation", {dict = animData.dict, anim = animData.anim})
    
    outputChatBox("Playing animation: " .. animData.name, player, 0, 255, 0)
    
    -- Auto stop for timed animations
    if animData.time > 0 then
        setTimer(function()
            if isElement(player) then
                setPedAnimation(player, false)
                setElementData(player, "currentAnimation", nil)
            end
        end, animData.time, 1)
    end
    
    incrementCommandStat("playerCommands")
end)

-- List animations in category
addCommandHandler("animlist", function(player, _, category)
    if not category then
        outputChatBox("=== ANIMATION CATEGORIES ===", player, 255, 255, 0)
        for cat, _ in pairs(animationCategories) do
            outputChatBox("• " .. cat, player, 255, 255, 255)
        end
        outputChatBox("Use /animlist [category] to see animations", player, 255, 255, 255)
        return
    end
    
    if not animationCategories[category] then
        outputChatBox("Invalid category! Available: dance, greeting, emotions, actions", player, 255, 0, 0)
        return
    end
    
    outputChatBox("=== " .. category:upper() .. " ANIMATIONS ===", player, 255, 255, 0)
    for _, anim in ipairs(animationCategories[category]) do
        local timeStr = anim.time == -1 and "Loop" or (anim.time/1000) .. "s"
        outputChatBox("• " .. anim.name .. " (" .. timeStr .. ")", player, 255, 255, 255)
    end
    outputChatBox("Use /anim " .. category .. " [animation_name]", player, 255, 255, 255)
    
    incrementCommandStat("playerCommands")
end)

-- Stop animation command
addCommandHandler("stopanim", function(player, cmd)
    setPedAnimation(player, false)
    setElementData(player, "currentAnimation", nil)
    outputChatBox("Animation stopped", player, 255, 255, 0)
    
    incrementCommandStat("playerCommands")
end)

-- Dance command shortcut
addCommandHandler("dance", function(player, _, danceNum)
    local danceNumber = tonumber(danceNum) or 1
    if danceNumber < 1 or danceNumber > 4 then
        danceNumber = 1
    end
    
    local danceAnim = animationCategories["dance"][danceNumber]
    setPedAnimation(player, danceAnim.dict, danceAnim.anim, -1, true, true, true)
    setElementData(player, "currentAnimation", {dict = danceAnim.dict, anim = danceAnim.anim})
    
    outputChatBox("Dancing! Use /stopanim to stop", player, 0, 255, 0)
    
    incrementCommandStat("playerCommands")
end)

-- Sit command
addCommandHandler("sit", function(player, cmd)
    local sitAnim = animationCategories["actions"][3]
    setPedAnimation(player, sitAnim.dict, sitAnim.anim, -1, true, true, true)
    setElementData(player, "currentAnimation", {dict = sitAnim.dict, anim = sitAnim.anim})
    
    outputChatBox("You are now sitting. Use /stopanim to stand up", player, 0, 255, 0)
    
    incrementCommandStat("playerCommands")
end)

-- Lay command  
addCommandHandler("lay", function(player, cmd)
    local layAnim = animationCategories["actions"][4]
    setPedAnimation(player, layAnim.dict, layAnim.anim, -1, true, true, true)
    setElementData(player, "currentAnimation", {dict = layAnim.dict, anim = layAnim.anim})
    
    outputChatBox("You are now laying down. Use /stopanim to get up", player, 0, 255, 0)
    
    incrementCommandStat("playerCommands")
end)

-- Smoke command
addCommandHandler("smoke", function(player, cmd)
    local smokeAnim = animationCategories["actions"][1]
    setPedAnimation(player, smokeAnim.dict, smokeAnim.anim, -1, true, true, true)
    setElementData(player, "currentAnimation", {dict = smokeAnim.dict, anim = smokeAnim.anim})
    
    outputChatBox("You are now smoking. Use /stopanim to stop", player, 0, 255, 0)
    
    incrementCommandStat("playerCommands")
end)

-- Animation on player join (clear any stuck animations)
addEventHandler("onPlayerJoin", root, function()
    setElementData(source, "currentAnimation", nil)
end)

-- Animation system info
addCommandHandler("animinfo", function(player, cmd)
    local currentAnim = getElementData(player, "currentAnimation")
    if currentAnim then
        outputChatBox("Current animation: " .. currentAnim.dict .. " - " .. currentAnim.anim, player, 255, 255, 0)
    else
        outputChatBox("No animation currently playing", player, 255, 255, 255)
    end
    
    outputChatBox("Animation System - Total categories: " .. #animationCategories, player, 255, 255, 255)
    
    incrementCommandStat("playerCommands")
end)

-- Animation system loaded
registerCommandSystem("Player Animations", 8, true)
