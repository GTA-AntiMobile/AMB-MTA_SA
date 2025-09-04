-- ================================
-- AMB MTA:SA - Player Interaction Commands
-- Mass migration of interaction-related commands
-- ================================

-- Give money command
addCommandHandler("givemoney", function(player, cmd, playerIdOrName, amount)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerIdOrName or not amount then
        outputChatBox("Su dung: /givemoney [player_id] [amount]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    if targetPlayer == player then
        outputChatBox("❌ Ban khong the give money cho chinh minh.", player, 255, 100, 100)
        return
    end
    
    local giveAmount = tonumber(amount)
    if not giveAmount or giveAmount <= 0 then
        outputChatBox("❌ So tien khong hop le.", player, 255, 100, 100)
        return
    end
    
    if (playerData.money or 0) < giveAmount then
        outputChatBox("❌ Ban khong co du tien.", player, 255, 100, 100)
        return
    end
    
    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 5 then
        outputChatBox("❌ Ban qua xa nguoi choi do.", player, 255, 100, 100)
        return
    end
    
    -- Transfer money
    local targetData = getElementData(targetPlayer, "playerData") or {}
    playerData.money = (playerData.money or 0) - giveAmount
    targetData.money = (targetData.money or 0) + giveAmount
    
    setElementData(player, "playerData", playerData)
    setElementData(targetPlayer, "playerData", targetData)
    
    outputChatBox(string.format("💰 Da give $%d cho %s.", giveAmount, getPlayerName(targetPlayer)), player, 0, 255, 0)
    outputChatBox(string.format("💰 %s da give ban $%d.", getPlayerName(player), giveAmount), targetPlayer, 0, 255, 0)
end)

-- Pay command (for services)
addCommandHandler("pay", function(player, cmd, playerIdOrName, amount)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerIdOrName or not amount then
        outputChatBox("Su dung: /pay [player_id] [amount]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    if targetPlayer == player then
        outputChatBox("❌ Ban khong the pay chinh minh.", player, 255, 100, 100)
        return
    end
    
    local payAmount = tonumber(amount)
    if not payAmount or payAmount <= 0 then
        outputChatBox("❌ So tien khong hop le.", player, 255, 100, 100)
        return
    end
    
    if (playerData.money or 0) < payAmount then
        outputChatBox("❌ Ban khong co du tien.", player, 255, 100, 100)
        return
    end
    
    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 5 then
        outputChatBox("❌ Ban qua xa nguoi choi do.", player, 255, 100, 100)
        return
    end
    
    -- Send payment offer
    local targetData = getElementData(targetPlayer, "playerData") or {}
    targetData.paymentOffer = {
        from = player,
        amount = payAmount,
        time = getRealTime().timestamp
    }
    setElementData(targetPlayer, "playerData", targetData)
    
    outputChatBox(string.format("💰 Da gui payment offer $%d den %s.", payAmount, getPlayerName(targetPlayer)), player, 255, 255, 100)
    outputChatBox(string.format("💰 %s muon pay ban $%d. Su dung /accept payment hoac /deny payment.", getPlayerName(player), payAmount), targetPlayer, 255, 255, 100)
end)

-- Accept payment
addCommandHandler("accept", function(player, cmd, type)
    local playerData = getElementData(player, "playerData") or {}
    
    if not type then
        outputChatBox("Su dung: /accept [payment/repair/heal/etc]", player, 255, 255, 255)
        return
    end
    
    if type == "payment" then
        if not playerData.paymentOffer then
            outputChatBox("❌ Ban khong co payment offer nao.", player, 255, 100, 100)
            return
        end
        
        local offer = playerData.paymentOffer
        if not isElement(offer.from) then
            outputChatBox("❌ Payment offer da expired.", player, 255, 100, 100)
            playerData.paymentOffer = nil
            setElementData(player, "playerData", playerData)
            return
        end
        
        local fromData = getElementData(offer.from, "playerData") or {}
        if (fromData.money or 0) < offer.amount then
            outputChatBox("❌ Nguoi do khong con du tien.", player, 255, 100, 100)
            playerData.paymentOffer = nil
            setElementData(player, "playerData", playerData)
            return
        end
        
        -- Transfer money
        fromData.money = (fromData.money or 0) - offer.amount
        playerData.money = (playerData.money or 0) + offer.amount
        playerData.paymentOffer = nil
        
        setElementData(player, "playerData", playerData)
        setElementData(offer.from, "playerData", fromData)
        
        outputChatBox(string.format("✅ Da nhan $%d tu %s.", offer.amount, getPlayerName(offer.from)), player, 0, 255, 0)
        outputChatBox(string.format("✅ %s da accept payment $%d.", getPlayerName(player), offer.amount), offer.from, 0, 255, 0)
    end
end)

-- Deny payment
addCommandHandler("deny", function(player, cmd, type)
    local playerData = getElementData(player, "playerData") or {}
    
    if not type then
        outputChatBox("Su dung: /deny [payment/repair/heal/etc]", player, 255, 255, 255)
        return
    end
    
    if type == "payment" then
        if not playerData.paymentOffer then
            outputChatBox("❌ Ban khong co payment offer nao.", player, 255, 100, 100)
            return
        end
        
        local offer = playerData.paymentOffer
        playerData.paymentOffer = nil
        setElementData(player, "playerData", playerData)
        
        if isElement(offer.from) then
            outputChatBox(string.format("❌ %s da deny payment cua ban.", getPlayerName(player)), offer.from, 255, 100, 100)
        end
        
        outputChatBox("❌ Da deny payment offer.", player, 255, 100, 100)
    end
end)

-- Trade system
addCommandHandler("trade", function(player, cmd, playerIdOrName, action, item, amount)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerIdOrName then
        outputChatBox("Su dung: /trade [player_id] [start/offer/accept/cancel]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    if targetPlayer == player then
        outputChatBox("❌ Ban khong the trade voi chinh minh.", player, 255, 100, 100)
        return
    end
    
    -- Check distance
    local px, py, pz = getElementPosition(player)
    local tx, ty, tz = getElementPosition(targetPlayer)
    if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) > 3 then
        outputChatBox("❌ Ban qua xa de trade.", player, 255, 100, 100)
        return
    end
    
    if not action then action = "start" end
    
    if action == "start" then
        local targetData = getElementData(targetPlayer, "playerData") or {}
        
        if playerData.trading or targetData.trading then
            outputChatBox("❌ Mot trong 2 nguoi dang trade roi.", player, 255, 100, 100)
            return
        end
        
        -- Start trade session
        playerData.trading = {
            partner = targetPlayer,
            offers = {},
            confirmed = false
        }
        targetData.trading = {
            partner = player,
            offers = {},
            confirmed = false
        }
        
        setElementData(player, "playerData", playerData)
        setElementData(targetPlayer, "playerData", targetData)
        
        outputChatBox(string.format("🔄 Bat dau trade voi %s.", getPlayerName(targetPlayer)), player, 255, 255, 100)
        outputChatBox(string.format("🔄 %s muon trade voi ban.", getPlayerName(player)), targetPlayer, 255, 255, 100)
        
    elseif action == "offer" then
        if not playerData.trading then
            outputChatBox("❌ Ban khong dang trade.", player, 255, 100, 100)
            return
        end
        
        if not item or not amount then
            outputChatBox("Su dung: /trade [player] offer [item/money] [amount]", player, 255, 255, 255)
            return
        end
        
        local offerAmount = tonumber(amount)
        if not offerAmount or offerAmount <= 0 then
            outputChatBox("❌ So luong khong hop le.", player, 255, 100, 100)
            return
        end
        
        if item == "money" then
            if (playerData.money or 0) < offerAmount then
                outputChatBox("❌ Ban khong co du tien.", player, 255, 100, 100)
                return
            end
            
            playerData.trading.offers = {money = offerAmount}
            setElementData(player, "playerData", playerData)
            
            outputChatBox(string.format("💰 Da offer $%d.", offerAmount), player, 255, 255, 100)
            outputChatBox(string.format("💰 %s offer $%d.", getPlayerName(player), offerAmount), playerData.trading.partner, 255, 255, 100)
        end
        
    elseif action == "accept" then
        if not playerData.trading then
            outputChatBox("❌ Ban khong dang trade.", player, 255, 100, 100)
            return
        end
        
        playerData.trading.confirmed = true
        setElementData(player, "playerData", playerData)
        
        local partnerData = getElementData(playerData.trading.partner, "playerData") or {}
        
        if partnerData.trading and partnerData.trading.confirmed then
            -- Both confirmed, execute trade
            if playerData.trading.offers.money and partnerData.trading.offers.money then
                -- Money trade
                local myOffer = playerData.trading.offers.money
                local partnerOffer = partnerData.trading.offers.money
                
                playerData.money = (playerData.money or 0) - myOffer + partnerOffer
                partnerData.money = (partnerData.money or 0) - partnerOffer + myOffer
            end
            
            -- Clear trade session
            playerData.trading = nil
            partnerData.trading = nil
            
            setElementData(player, "playerData", playerData)
            setElementData(playerData.trading.partner, "playerData", partnerData)
            
            outputChatBox("✅ Trade thanh cong!", player, 0, 255, 0)
            outputChatBox("✅ Trade thanh cong!", playerData.trading.partner, 0, 255, 0)
        else
            outputChatBox("✅ Da confirm trade. Cho partner confirm.", player, 255, 255, 100)
            outputChatBox(string.format("✅ %s da confirm trade.", getPlayerName(player)), playerData.trading.partner, 255, 255, 100)
        end
        
    elseif action == "cancel" then
        if not playerData.trading then
            outputChatBox("❌ Ban khong dang trade.", player, 255, 100, 100)
            return
        end
        
        local partner = playerData.trading.partner
        playerData.trading = nil
        setElementData(player, "playerData", playerData)
        
        if isElement(partner) then
            local partnerData = getElementData(partner, "playerData") or {}
            partnerData.trading = nil
            setElementData(partner, "playerData", partnerData)
            outputChatBox(string.format("❌ %s da cancel trade.", getPlayerName(player)), partner, 255, 100, 100)
        end
        
        outputChatBox("❌ Da cancel trade.", player, 255, 100, 100)
    end
end)

-- Show player stats
addCommandHandler("stats", function(player, cmd, playerIdOrName)
    local targetPlayer = player
    if playerIdOrName then
        targetPlayer = getPlayerFromNameOrId(playerIdOrName)
        if not targetPlayer then
            outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
            return
        end
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    local targetName = getPlayerName(targetPlayer)
    
    outputChatBox(string.format("📊 ===== STATS OF %s =====", targetName), player, 255, 255, 0)
    outputChatBox(string.format("• Money: $%d", targetData.money or 0), player, 255, 255, 255)
    outputChatBox(string.format("• Level: %d", targetData.level or 1), player, 255, 255, 255)
    outputChatBox(string.format("• Admin Level: %d", targetData.adminLevel or 0), player, 255, 255, 255)
    outputChatBox(string.format("• Job: %s", targetData.job or "Unemployed"), player, 255, 255, 255)
    outputChatBox(string.format("• Gang: %s", targetData.gang and targetData.gang > 0 and "Gang "..targetData.gang or "None"), player, 255, 255, 255)
    outputChatBox(string.format("• Family: %s", targetData.family and targetData.family > 0 and "Family "..targetData.family or "None"), player, 255, 255, 255)
    
    if targetPlayer == player then
        outputChatBox(string.format("• House: %s", targetData.house and targetData.house > 0 and "House "..targetData.house or "None"), player, 255, 255, 255)
        outputChatBox(string.format("• Vehicle: %s", targetData.vehicle and targetData.vehicle > 0 and "Vehicle "..targetData.vehicle or "None"), player, 255, 255, 255)
    end
end)

-- Invite to group/event
addCommandHandler("invite", function(player, cmd, playerIdOrName, inviteType)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerIdOrName or not inviteType then
        outputChatBox("Su dung: /invite [player_id] [event/party/race]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    if targetPlayer == player then
        outputChatBox("❌ Ban khong the invite chinh minh.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    
    if inviteType == "event" then
        targetData.eventInvite = {
            from = player,
            type = "event",
            time = getRealTime().timestamp
        }
        
        outputChatBox(string.format("🎉 Da invite %s den event.", getPlayerName(targetPlayer)), player, 255, 255, 100)
        outputChatBox(string.format("🎉 %s da invite ban den event. Su dung /join event.", getPlayerName(player)), targetPlayer, 255, 255, 100)
        
    elseif inviteType == "party" then
        targetData.partyInvite = {
            from = player,
            type = "party",
            time = getRealTime().timestamp
        }
        
        outputChatBox(string.format("🎊 Da invite %s den party.", getPlayerName(targetPlayer)), player, 255, 255, 100)
        outputChatBox(string.format("🎊 %s da invite ban den party. Su dung /join party.", getPlayerName(player)), targetPlayer, 255, 255, 100)
        
    elseif inviteType == "race" then
        targetData.raceInvite = {
            from = player,
            type = "race",
            time = getRealTime().timestamp
        }
        
        outputChatBox(string.format("🏁 Da invite %s den race.", getPlayerName(targetPlayer)), player, 255, 255, 100)
        outputChatBox(string.format("🏁 %s da invite ban den race. Su dung /join race.", getPlayerName(player)), targetPlayer, 255, 255, 100)
    end
    
    setElementData(targetPlayer, "playerData", targetData)
end)

-- Join invited event
addCommandHandler("join", function(player, cmd, joinType)
    local playerData = getElementData(player, "playerData") or {}
    
    if not joinType then
        outputChatBox("Su dung: /join [event/party/race]", player, 255, 255, 255)
        return
    end
    
    if joinType == "event" then
        if not playerData.eventInvite then
            outputChatBox("❌ Ban khong co event invite.", player, 255, 100, 100)
            return
        end
        
        local invite = playerData.eventInvite
        playerData.eventInvite = nil
        playerData.inEvent = true
        setElementData(player, "playerData", playerData)
        
        outputChatBox("🎉 Da join event!", player, 0, 255, 0)
        if isElement(invite.from) then
            outputChatBox(string.format("🎉 %s da join event.", getPlayerName(player)), invite.from, 0, 255, 0)
        end
        
    elseif joinType == "party" then
        if not playerData.partyInvite then
            outputChatBox("❌ Ban khong co party invite.", player, 255, 100, 100)
            return
        end
        
        local invite = playerData.partyInvite
        playerData.partyInvite = nil
        playerData.inParty = invite.from
        setElementData(player, "playerData", playerData)
        
        outputChatBox("🎊 Da join party!", player, 0, 255, 0)
        if isElement(invite.from) then
            outputChatBox(string.format("🎊 %s da join party cua ban.", getPlayerName(player)), invite.from, 0, 255, 0)
        end
        
    elseif joinType == "race" then
        if not playerData.raceInvite then
            outputChatBox("❌ Ban khong co race invite.", player, 255, 100, 100)
            return
        end
        
        local invite = playerData.raceInvite
        playerData.raceInvite = nil
        playerData.inRace = true
        setElementData(player, "playerData", playerData)
        
        outputChatBox("🏁 Da join race!", player, 0, 255, 0)
        if isElement(invite.from) then
            outputChatBox(string.format("🏁 %s da join race.", getPlayerName(player)), invite.from, 0, 255, 0)
        end
    end
end)

-- Report player
addCommandHandler("report", function(player, cmd, playerIdOrName, ...)
    if not playerIdOrName then
        outputChatBox("Su dung: /report [player_id] [reason]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = getPlayerFromNameOrId(playerIdOrName)
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    if targetPlayer == player then
        outputChatBox("❌ Ban khong the report chinh minh.", player, 255, 100, 100)
        return
    end
    
    local reason = table.concat({...}, " ")
    if not reason or reason == "" then
        outputChatBox("Su dung: /report [player_id] [reason]", player, 255, 255, 255)
        return
    end
    
    local reporterName = getPlayerName(player)
    local targetName = getPlayerName(targetPlayer)
    
    -- Send to all admins
    local adminCount = 0
    for _, admin in ipairs(getElementsByType("player")) do
        local adminData = getElementData(admin, "playerData")
        if adminData and (adminData.adminLevel or 0) > 0 then
            outputChatBox(string.format("⚠️ REPORT: %s reported %s for: %s", reporterName, targetName, reason), admin, 255, 100, 100)
            adminCount = adminCount + 1
        end
    end
    
    if adminCount > 0 then
        outputChatBox(string.format("✅ Report gui den %d admins.", adminCount), player, 0, 255, 0)
    else
        outputChatBox("❌ Khong co admin nao online.", player, 255, 100, 100)
    end
end)

outputDebugString("[AMB] Player interaction system loaded - 9 commands")
