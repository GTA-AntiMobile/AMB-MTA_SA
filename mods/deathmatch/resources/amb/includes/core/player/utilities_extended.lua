-- ================================
-- AMB MTA:SA - Player Utility System Extended
-- Mass migration of additional player utility commands
-- ================================

-- Accept command for various invitations
addCommandHandler("accept", function(player, cmd, inviteType)
    if not inviteType then
        outputChatBox("Su dung: /accept [death/phone/job/faction/business/event]", player, 255, 255, 255)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    local invites = playerData.invites or {}
    
    if inviteType == "death" then
        if playerData.injured then
            -- Accept death
            playerData.injured = false
            playerData.health = 100
            setElementHealth(player, 100)
            
            -- Respawn at hospital
            setElementPosition(player, 1177.7, -1323.8, 14.1) -- All Saints Hospital
            setElementInterior(player, 0)
            setElementDimension(player, 0)
            
            outputChatBox("💀 Ban da chon chet va duoc chuyen den benh vien.", player, 255, 100, 100)
            
            -- Lose some money
            local money = playerData.money or 0
            local deathFee = math.floor(money * 0.1) -- 10% death fee
            if deathFee > 10000 then deathFee = 10000 end
            playerData.money = money - deathFee
            
            outputChatBox(string.format("💰 Ban da mat $%d phi benh vien.", deathFee), player, 255, 200, 100)
        else
            outputChatBox("❌ Ban khong bi thuong.", player, 255, 100, 100)
        end
        
    elseif inviteType == "phone" then
        if invites.phoneCall then
            local caller = invites.phoneCall.caller
            local callerPlayer = getPlayerByName(caller)
            
            if callerPlayer then
                outputChatBox(string.format("📞 Ban da nhan cuoc goi tu %s.", caller), player, 0, 255, 0)
                outputChatBox(string.format("📞 %s da nhan cuoc goi cua ban.", getPlayerName(player)), callerPlayer, 0, 255, 0)
                
                -- Set both in call
                playerData.inCall = true
                playerData.callPartner = callerPlayer
                
                local callerData = getElementData(callerPlayer, "playerData") or {}
                callerData.inCall = true
                callerData.callPartner = player
                
                setElementData(player, "playerData", playerData)
                setElementData(callerPlayer, "playerData", callerData)
                
                -- Clear invite
                invites.phoneCall = nil
            else
                outputChatBox("❌ Nguoi goi khong con online.", player, 255, 100, 100)
                invites.phoneCall = nil
            end
        else
            outputChatBox("❌ Ban khong co cuoc goi nao de nhan.", player, 255, 100, 100)
        end
        
    elseif inviteType == "job" then
        if invites.job then
            local jobData = invites.job
            playerData.job = jobData.jobName
            playerData.jobRank = 1
            
            outputChatBox(string.format("✅ Ban da gia nhap cong viec: %s", jobData.jobName), player, 0, 255, 0)
            
            -- Clear invite
            invites.job = nil
        else
            outputChatBox("❌ Ban khong co loi moi cong viec nao.", player, 255, 100, 100)
        end
        
    elseif inviteType == "faction" then
        if invites.faction then
            local factionData = invites.faction
            playerData.faction = factionData.factionID
            playerData.factionRank = 1
            
            outputChatBox(string.format("✅ Ban da gia nhap faction: %s", factionData.factionName), player, 0, 255, 0)
            
            -- Notify faction members
            for _, p in ipairs(getElementsByType("player")) do
                local pData = getElementData(p, "playerData")
                if pData and pData.faction == factionData.factionID then
                    outputChatBox(string.format("📢 %s da gia nhap faction.", getPlayerName(player)), p, 100, 255, 100)
                end
            end
            
            -- Clear invite
            invites.faction = nil
        else
            outputChatBox("❌ Ban khong co loi moi faction nao.", player, 255, 100, 100)
        end
        
    elseif inviteType == "business" then
        if invites.business then
            local businessData = invites.business
            playerData.business = businessData.businessID
            playerData.businessRank = 1
            
            outputChatBox(string.format("✅ Ban da gia nhap business: %s", businessData.businessName), player, 0, 255, 0)
            
            -- Clear invite
            invites.business = nil
        else
            outputChatBox("❌ Ban khong co loi moi business nao.", player, 255, 100, 100)
        end
        
    elseif inviteType == "event" then
        if invites.event then
            local eventData = invites.event
            
            -- Teleport to event
            setElementPosition(player, eventData.x, eventData.y, eventData.z)
            setElementInterior(player, eventData.interior or 0)
            setElementDimension(player, eventData.dimension or 0)
            
            outputChatBox(string.format("🎉 Ban da tham gia event: %s", eventData.eventName), player, 0, 255, 0)
            
            -- Add to event participants
            playerData.currentEvent = eventData.eventID
            
            -- Clear invite
            invites.event = nil
        else
            outputChatBox("❌ Ban khong co loi moi event nao.", player, 255, 100, 100)
        end
    else
        outputChatBox("❌ Loai accept khong hop le.", player, 255, 100, 100)
        return
    end
    
    -- Update player data
    playerData.invites = invites
    setElementData(player, "playerData", playerData)
end)

-- Accent command for language/accent setting
addCommandHandler("accent", function(player, cmd, accentType)
    if not accentType then
        outputChatBox("Su dung: /accent [vn/en/none]", player, 255, 255, 255)
        outputChatBox("Cac accent co san: vn (Tieng Viet), en (English), none (Khong accent)", player, 255, 255, 255)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    
    if accentType == "vn" then
        playerData.accent = "vietnamese"
        outputChatBox("✅ Ban da dat accent thanh Tieng Viet.", player, 0, 255, 0)
    elseif accentType == "en" then
        playerData.accent = "english"
        outputChatBox("✅ Ban da dat accent thanh English.", player, 0, 255, 0)
    elseif accentType == "none" then
        playerData.accent = nil
        outputChatBox("✅ Ban da tat accent.", player, 0, 255, 0)
    else
        outputChatBox("❌ Accent khong hop le. Su dung: vn/en/none", player, 255, 100, 100)
        return
    end
    
    setElementData(player, "playerData", playerData)
end)

-- Accept call command
addCommandHandler("acceptcall", function(player)
    local playerData = getElementData(player, "playerData") or {}
    local invites = playerData.invites or {}
    
    if invites.phoneCall then
        local caller = invites.phoneCall.caller
        local callerPlayer = getPlayerByName(caller)
        
        if callerPlayer then
            outputChatBox(string.format("📞 Ban da nhan cuoc goi tu %s.", caller), player, 0, 255, 0)
            outputChatBox(string.format("📞 %s da nhan cuoc goi cua ban.", getPlayerName(player)), callerPlayer, 0, 255, 0)
            
            -- Set both in call
            playerData.inCall = true
            playerData.callPartner = callerPlayer
            
            local callerData = getElementData(callerPlayer, "playerData") or {}
            callerData.inCall = true
            callerData.callPartner = player
            
            setElementData(player, "playerData", playerData)
            setElementData(callerPlayer, "playerData", callerData)
            
            -- Clear invite
            invites.phoneCall = nil
            playerData.invites = invites
            setElementData(player, "playerData", playerData)
        else
            outputChatBox("❌ Nguoi goi khong con online.", player, 255, 100, 100)
            invites.phoneCall = nil
            playerData.invites = invites
            setElementData(player, "playerData", playerData)
        end
    else
        outputChatBox("❌ Ban khong co cuoc goi nao de nhan.", player, 255, 100, 100)
    end
end)

-- Accept event command
addCommandHandler("acceptevent", function(player)
    local playerData = getElementData(player, "playerData") or {}
    local invites = playerData.invites or {}
    
    if invites.event then
        local eventData = invites.event
        
        -- Teleport to event
        setElementPosition(player, eventData.x, eventData.y, eventData.z)
        setElementInterior(player, eventData.interior or 0)
        setElementDimension(player, eventData.dimension or 0)
        
        outputChatBox(string.format("🎉 Ban da tham gia event: %s", eventData.eventName), player, 0, 255, 0)
        
        -- Add to event participants
        playerData.currentEvent = eventData.eventID
        
        -- Clear invite
        invites.event = nil
        playerData.invites = invites
        setElementData(player, "playerData", playerData)
    else
        outputChatBox("❌ Ban khong co loi moi event nao.", player, 255, 100, 100)
    end
end)

-- Add contact command (phone book)
addCommandHandler("addcontact", function(player, cmd, phoneNumber, contactName)
    if not phoneNumber or not contactName then
        outputChatBox("Su dung: /addcontact [so_dien_thoai] [ten_lien_lac]", player, 255, 255, 255)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    
    -- Check if player has phone
    if not playerData.phone then
        outputChatBox("❌ Ban khong co dien thoai.", player, 255, 100, 100)
        return
    end
    
    -- Initialize contacts if not exists
    if not playerData.phoneContacts then
        playerData.phoneContacts = {}
    end
    
    -- Check if contact already exists
    for _, contact in ipairs(playerData.phoneContacts) do
        if contact.number == phoneNumber then
            outputChatBox("❌ So dien thoai nay da co trong danh ba.", player, 255, 100, 100)
            return
        end
        if contact.name == contactName then
            outputChatBox("❌ Ten lien lac nay da ton tai.", player, 255, 100, 100)
            return
        end
    end
    
    -- Add contact
    table.insert(playerData.phoneContacts, {
        number = phoneNumber,
        name = contactName,
        addedTime = getRealTime().timestamp
    })
    
    setElementData(player, "playerData", playerData)
    outputChatBox(string.format("✅ Da them %s (%s) vao danh ba.", contactName, phoneNumber), player, 0, 255, 0)
end)

-- Delete contact command
addCommandHandler("delcontact", function(player, cmd, contactName)
    if not contactName then
        outputChatBox("Su dung: /delcontact [ten_lien_lac]", player, 255, 255, 255)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    
    -- Check if player has phone
    if not playerData.phone then
        outputChatBox("❌ Ban khong co dien thoai.", player, 255, 100, 100)
        return
    end
    
    if not playerData.phoneContacts then
        outputChatBox("❌ Danh ba trong.", player, 255, 100, 100)
        return
    end
    
    -- Find and remove contact
    for i, contact in ipairs(playerData.phoneContacts) do
        if string.lower(contact.name) == string.lower(contactName) then
            table.remove(playerData.phoneContacts, i)
            setElementData(player, "playerData", playerData)
            outputChatBox(string.format("✅ Da xoa %s khoi danh ba.", contactName), player, 0, 255, 0)
            return
        end
    end
    
    outputChatBox("❌ Khong tim thay lien lac nay trong danh ba.", player, 255, 100, 100)
end)

-- View contacts command
addCommandHandler("contacts", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    -- Check if player has phone
    if not playerData.phone then
        outputChatBox("❌ Ban khong co dien thoai.", player, 255, 100, 100)
        return
    end
    
    if not playerData.phoneContacts or #playerData.phoneContacts == 0 then
        outputChatBox("📱 Danh ba trong.", player, 255, 255, 100)
        return
    end
    
    outputChatBox("📱 ===== DANH BA =====", player, 255, 255, 100)
    for i, contact in ipairs(playerData.phoneContacts) do
        outputChatBox(string.format("%d. %s - %s", i, contact.name, contact.number), player, 255, 255, 255)
    end
    outputChatBox("==================", player, 255, 255, 100)
end)

-- Extended Animation command
addCommandHandler("animext", function(player, cmd, animType, animName)
    if not animType then
        outputChatBox("Su dung: /animext [stop/dance/greet/misc] [ten_anim]", player, 255, 255, 255)
        outputChatBox("Vi du: /animext dance 1, /animext greet wave, /animext stop", player, 255, 255, 255)
        return
    end
    
    if animType == "stop" then
        setPedAnimation(player, false)
        outputChatBox("✅ Da dung animation.", player, 0, 255, 0)
        return
    end
    
    if not animName then
        if animType == "dance" then
            outputChatBox("Cac dance co san: 1, 2, 3, 4", player, 255, 255, 255)
        elseif animType == "greet" then
            outputChatBox("Cac greet co san: wave, nod, bow", player, 255, 255, 255)
        elseif animType == "misc" then
            outputChatBox("Cac misc co san: sit, smoke, drink, eat", player, 255, 255, 255)
        end
        return
    end
    
    local success = false
    
    if animType == "dance" then
        if animName == "1" then
            setPedAnimation(player, "DANCING", "dance_loop", -1, true, false, false)
            success = true
        elseif animName == "2" then
            setPedAnimation(player, "DANCING", "DAN_Down_A", -1, true, false, false)
            success = true
        elseif animName == "3" then
            setPedAnimation(player, "DANCING", "DAN_Left_A", -1, true, false, false)
            success = true
        elseif animName == "4" then
            setPedAnimation(player, "DANCING", "DAN_Right_A", -1, true, false, false)
            success = true
        end
    elseif animType == "greet" then
        if animName == "wave" then
            setPedAnimation(player, "ON_LOOKERS", "wave_loop", 3000, true, false, false)
            success = true
        elseif animName == "nod" then
            setPedAnimation(player, "MISC", "nod", 2000, true, false, false)
            success = true
        elseif animName == "bow" then
            setPedAnimation(player, "CARRY", "crry_prtial", 3000, true, false, false)
            success = true
        end
    elseif animType == "misc" then
        if animName == "sit" then
            setPedAnimation(player, "BEACH", "bather", -1, true, false, false)
            success = true
        elseif animName == "smoke" then
            setPedAnimation(player, "SMOKING", "M_smklean_loop", -1, true, false, false)
            success = true
        elseif animName == "drink" then
            setPedAnimation(player, "BAR", "dnk_stndM_loop", -1, true, false, false)
            success = true
        elseif animName == "eat" then
            setPedAnimation(player, "FOOD", "EAT_Burger", 5000, true, false, false)
            success = true
        end
    end
    
    if success then
        outputChatBox(string.format("✅ Da thuc hien animation: %s %s", animType, animName), player, 0, 255, 0)
    else
        outputChatBox("❌ Animation khong hop le.", player, 255, 100, 100)
    end
end)

-- Helper function to get player by name
function getPlayerByName(name)
    for _, player in ipairs(getElementsByType("player")) do
        if string.lower(getPlayerName(player)) == string.lower(name) then
            return player
        end
    end
    return false
end

outputDebugString("[AMB] Player utility system extended loaded - 8 commands")
