-- ================================
-- AMB MTA:SA - Business & Economy System
-- Mass migration of business and economy commands
-- ================================

-- Business chat command
addCommandHandler("b", function(player, cmd, ...)
    local playerData = getElementData(player, "playerData") or {}
    
    -- Check if player has business
    if not playerData.business or playerData.business <= 0 then
        outputChatBox("❌ Ban khong co business nao.", player, 255, 100, 100)
        return
    end
    
    local message = table.concat({...}, " ")
    if not message or message == "" then
        outputChatBox("Su dung: /b [tin nhan]", player, 255, 255, 255)
        return
    end
    
    local playerName = getPlayerName(player)
    local businessID = playerData.business
    local rank = playerData.businessRank or 1
    
    -- Send to all business members
    for _, targetPlayer in ipairs(getElementsByType("player")) do
        local targetData = getElementData(targetPlayer, "playerData")
        if targetData and targetData.business == businessID then
            outputChatBox(string.format("💼 [BIZ] %s (R%d): %s", playerName, rank, message), targetPlayer, 255, 255, 100)
        end
    end
    
    outputDebugString("[BUSINESS CHAT] " .. playerName .. ": " .. message)
end)

-- Buy business command
addCommandHandler("buybiz", function(player, cmd, bizID)
    if not bizID then
        outputChatBox("Su dung: /buybiz [business_id]", player, 255, 255, 255)
        return
    end
    
    local businessID = tonumber(bizID)
    if not businessID then
        outputChatBox("❌ Business ID khong hop le.", player, 255, 100, 100)
        return
    end
    
    local playerData = getElementData(player, "playerData") or {}
    local playerMoney = playerData.money or 0
    
    -- Check if player already owns a business
    if playerData.business and playerData.business > 0 then
        outputChatBox("❌ Ban da co business roi.", player, 255, 100, 100)
        return
    end
    
    -- Sample business data (would be from database)
    local businesses = {
        [1] = {name = "24/7 Store", price = 50000, type = "store"},
        [2] = {name = "Gas Station", price = 100000, type = "gas"},
        [3] = {name = "Restaurant", price = 150000, type = "food"},
        [4] = {name = "Car Dealership", price = 300000, type = "vehicles"},
        [5] = {name = "Bank", price = 500000, type = "bank"}
    }
    
    local business = businesses[businessID]
    if not business then
        outputChatBox("❌ Business khong ton tai.", player, 255, 100, 100)
        return
    end
    
    if playerMoney < business.price then
        outputChatBox(string.format("❌ Ban can $%d de mua business nay.", business.price), player, 255, 100, 100)
        return
    end
    
    -- Buy business
    playerData.money = playerMoney - business.price
    playerData.business = businessID
    playerData.businessRank = 10 -- Owner rank
    setElementData(player, "playerData", playerData)
    
    outputChatBox(string.format("✅ Ban da mua %s voi gia $%d!", business.name, business.price), player, 0, 255, 0)
    
    outputDebugString("[BUSINESS] " .. getPlayerName(player) .. " bought business " .. businessID)
end)

-- Sell business command
addCommandHandler("sellbiz", function(player, cmd, playerIdOrName, price)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.business or playerData.business <= 0 then
        outputChatBox("❌ Ban khong co business nao.", player, 255, 100, 100)
        return
    end
    
    if playerData.businessRank ~= 10 then -- Not owner
        outputChatBox("❌ Chi owner moi co the ban business.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /sellbiz [player_id] [price]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local sellPrice = tonumber(price) or 0
    if sellPrice <= 0 then
        outputChatBox("❌ Gia ban khong hop le.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.business and targetData.business > 0 then
        outputChatBox("❌ Nguoi choi da co business roi.", player, 255, 100, 100)
        return
    end
    
    if (targetData.money or 0) < sellPrice then
        outputChatBox("❌ Nguoi choi khong co du tien.", player, 255, 100, 100)
        return
    end
    
    -- Create invitation
    targetData.invites = targetData.invites or {}
    targetData.invites.business = {
        businessID = playerData.business,
        businessName = "Business " .. playerData.business,
        seller = getPlayerName(player),
        price = sellPrice
    }
    setElementData(targetPlayer, "playerData", targetData)
    
    outputChatBox(string.format("✅ Da gui loi moi ban business cho %s voi gia $%d.", getPlayerName(targetPlayer), sellPrice), player, 0, 255, 0)
    outputChatBox(string.format("💼 %s muon ban business cho ban voi gia $%d. Su dung /accept business.", getPlayerName(player), sellPrice), targetPlayer, 255, 255, 100)
end)

-- Business vault commands
addCommandHandler("bdeposit", function(player, cmd, amount)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.business or playerData.business <= 0 then
        outputChatBox("❌ Ban khong co business nao.", player, 255, 100, 100)
        return
    end
    
    if not amount then
        outputChatBox("Su dung: /bdeposit [so_tien]", player, 255, 255, 255)
        return
    end
    
    local depositAmount = tonumber(amount)
    if not depositAmount or depositAmount <= 0 then
        outputChatBox("❌ So tien khong hop le.", player, 255, 100, 100)
        return
    end
    
    local playerMoney = playerData.money or 0
    if playerMoney < depositAmount then
        outputChatBox("❌ Ban khong co du tien.", player, 255, 100, 100)
        return
    end
    
    -- Deposit to business vault
    playerData.money = playerMoney - depositAmount
    playerData.businessVault = (playerData.businessVault or 0) + depositAmount
    setElementData(player, "playerData", playerData)
    
    outputChatBox(string.format("✅ Da gui $%d vao vault business.", depositAmount), player, 0, 255, 0)
    outputChatBox(string.format("💰 Vault hien tai: $%d", playerData.businessVault), player, 255, 255, 100)
end)

addCommandHandler("bwithdraw", function(player, cmd, amount)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.business or playerData.business <= 0 then
        outputChatBox("❌ Ban khong co business nao.", player, 255, 100, 100)
        return
    end
    
    if (playerData.businessRank or 0) < 8 then -- Need high rank to withdraw
        outputChatBox("❌ Ban can rank 8+ de rut tien.", player, 255, 100, 100)
        return
    end
    
    if not amount then
        outputChatBox("Su dung: /bwithdraw [so_tien]", player, 255, 255, 255)
        return
    end
    
    local withdrawAmount = tonumber(amount)
    if not withdrawAmount or withdrawAmount <= 0 then
        outputChatBox("❌ So tien khong hop le.", player, 255, 100, 100)
        return
    end
    
    local vaultMoney = playerData.businessVault or 0
    if vaultMoney < withdrawAmount then
        outputChatBox("❌ Vault khong co du tien.", player, 255, 100, 100)
        return
    end
    
    -- Withdraw from business vault
    playerData.businessVault = vaultMoney - withdrawAmount
    playerData.money = (playerData.money or 0) + withdrawAmount
    setElementData(player, "playerData", playerData)
    
    outputChatBox(string.format("✅ Da rut $%d tu vault business.", withdrawAmount), player, 0, 255, 0)
    outputChatBox(string.format("💰 Vault con lai: $%d", playerData.businessVault), player, 255, 255, 100)
end)

-- Business invite command
addCommandHandler("binvite", function(player, cmd, playerIdOrName)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.business or playerData.business <= 0 then
        outputChatBox("❌ Ban khong co business nao.", player, 255, 100, 100)
        return
    end
    
    if (playerData.businessRank or 0) < 7 then -- Need high rank to invite
        outputChatBox("❌ Ban can rank 7+ de moi nguoi.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /binvite [player_id]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.business and targetData.business > 0 then
        outputChatBox("❌ Nguoi choi da co business roi.", player, 255, 100, 100)
        return
    end
    
    -- Create invitation
    targetData.invites = targetData.invites or {}
    targetData.invites.business = {
        businessID = playerData.business,
        businessName = "Business " .. playerData.business,
        inviter = getPlayerName(player)
    }
    setElementData(targetPlayer, "playerData", targetData)
    
    outputChatBox(string.format("✅ Da moi %s vao business.", getPlayerName(targetPlayer)), player, 0, 255, 0)
    outputChatBox(string.format("💼 %s moi ban vao business. Su dung /accept business.", getPlayerName(player)), targetPlayer, 255, 255, 100)
end)

-- Business uninvite command
addCommandHandler("buninvite", function(player, cmd, playerIdOrName)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.business or playerData.business <= 0 then
        outputChatBox("❌ Ban khong co business nao.", player, 255, 100, 100)
        return
    end
    
    if (playerData.businessRank or 0) < 7 then -- Need high rank to uninvite
        outputChatBox("❌ Ban can rank 7+ de kick nguoi.", player, 255, 100, 100)
        return
    end
    
    if not playerIdOrName then
        outputChatBox("Su dung: /buninvite [player_id]", player, 255, 255, 255)
        return
    end
    
    local targetPlayer = false
    for _, p in ipairs(getElementsByType("player")) do
        if getElementData(p, "playerID") == tonumber(playerIdOrName) then
            targetPlayer = p
            break
        end
    end
    
    if not targetPlayer then
        outputChatBox("❌ Khong tim thay nguoi choi.", player, 255, 100, 100)
        return
    end
    
    local targetData = getElementData(targetPlayer, "playerData") or {}
    if targetData.business ~= playerData.business then
        outputChatBox("❌ Nguoi choi khong o trong business cua ban.", player, 255, 100, 100)
        return
    end
    
    if (targetData.businessRank or 0) >= (playerData.businessRank or 0) then
        outputChatBox("❌ Ban khong the kick nguoi co rank cao hon hoac bang.", player, 255, 100, 100)
        return
    end
    
    -- Remove from business
    targetData.business = nil
    targetData.businessRank = nil
    setElementData(targetPlayer, "playerData", targetData)
    
    outputChatBox(string.format("✅ Da kick %s khoi business.", getPlayerName(targetPlayer)), player, 0, 255, 0)
    outputChatBox(string.format("❌ Ban da bi kick khoi business boi %s.", getPlayerName(player)), targetPlayer, 255, 100, 100)
end)

-- Business members command
addCommandHandler("bmembers", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.business or playerData.business <= 0 then
        outputChatBox("❌ Ban khong co business nao.", player, 255, 100, 100)
        return
    end
    
    local businessID = playerData.business
    local members = {}
    
    -- Find all online members
    for _, p in ipairs(getElementsByType("player")) do
        local pData = getElementData(p, "playerData")
        if pData and pData.business == businessID then
            table.insert(members, {
                name = getPlayerName(p),
                rank = pData.businessRank or 1,
                online = true
            })
        end
    end
    
    if #members == 0 then
        outputChatBox("❌ Khong co thanh vien nao online.", player, 255, 100, 100)
        return
    end
    
    outputChatBox("💼 ===== BUSINESS MEMBERS =====", player, 255, 255, 100)
    for _, member in ipairs(members) do
        local status = member.online and "ONLINE" or "OFFLINE"
        outputChatBox(string.format("• %s (Rank %d) - %s", member.name, member.rank, status), player, 255, 255, 255)
    end
    outputChatBox("============================", player, 255, 255, 100)
end)

-- Quit business command
addCommandHandler("quitbiz", function(player)
    local playerData = getElementData(player, "playerData") or {}
    
    if not playerData.business or playerData.business <= 0 then
        outputChatBox("❌ Ban khong co business nao.", player, 255, 100, 100)
        return
    end
    
    if playerData.businessRank == 10 then -- Owner cannot quit
        outputChatBox("❌ Owner khong the quit business. Hay ban business cho nguoi khac.", player, 255, 100, 100)
        return
    end
    
    local businessID = playerData.business
    local playerName = getPlayerName(player)
    
    -- Remove from business
    playerData.business = nil
    playerData.businessRank = nil
    setElementData(player, "playerData", playerData)
    
    outputChatBox("✅ Ban da roi khoi business.", player, 0, 255, 0)
    
    -- Notify other business members
    for _, p in ipairs(getElementsByType("player")) do
        local pData = getElementData(p, "playerData")
        if pData and pData.business == businessID and p ~= player then
            outputChatBox(string.format("📢 %s da roi khoi business.", playerName), p, 255, 255, 100)
        end
    end
end)

outputDebugString("[AMB] Business & economy system loaded - 10 commands")
